#!/usr/bin/env python3
"""Re-runnable URL parity audit: live Nuxt site vs the local Hugo build.

Builds the authoritative inventory of the live site's indexed URLs (from its
sitemap) and diffs them against what the Hugo build serves out of ./public,
categorizing every old URL as 1:1 / needs-301 / gone.

Usage (from repo root):
    hugo --gc --minify --cleanDestinationDir   # produce a clean ./public first
    python3 docs/url-parity/audit.py           # diff + refresh the snapshots

The --cleanDestinationDir flag matters: Hugo does not purge ./public on its own,
so a stale build leaves orphaned pages that read as false "extra" URLs.

Outputs (written next to this script):
    live-urls.txt     sorted live inventory (paths, no host)
    hugo-urls.txt     sorted Hugo build inventory (real pages, trailing slash)
    hugo-aliases.txt  Hugo's auto-generated "page/1" alias redirect stubs

Exit code is non-zero if any live URL would 404 on Hugo, so this doubles as a
pre-cutover gate for the verification issue (#173).
"""

import os
import re
import sys
import urllib.request

SITEMAP_URL = "https://ofreport.com/sitemap.xml"
HOST = "https://ofreport.com"
HERE = os.path.dirname(os.path.abspath(__file__))
PUBLIC = os.path.join(HERE, "..", "..", "public")


def norm(path):
    """Collapse the trailing-slash difference (Nuxt sitemap omits it; Hugo adds it)."""
    return path if path == "/" else path.rstrip("/")


def fetch_live_paths():
    req = urllib.request.Request(SITEMAP_URL, headers={"User-Agent": "url-parity-audit"})
    with urllib.request.urlopen(req, timeout=30) as resp:
        xml = resp.read().decode("utf-8")
    locs = re.findall(r"<loc>(.*?)</loc>", xml)
    return sorted({loc.replace(HOST, "") for loc in locs})


def scan_hugo_build():
    """Walk ./public. Each index.html is a served URL; tiny meta-refresh stubs are aliases."""
    if not os.path.isdir(PUBLIC):
        sys.exit("ERROR: ./public not found. Run `hugo --gc --minify --cleanDestinationDir` first.")
    pages, aliases = set(), {}
    for dirpath, _, filenames in os.walk(PUBLIC):
        if "index.html" not in filenames:
            continue
        rel = os.path.relpath(dirpath, PUBLIC)
        url = "/" if rel == "." else "/" + rel.replace(os.sep, "/") + "/"
        html = open(os.path.join(dirpath, "index.html"), encoding="utf-8", errors="replace").read()
        m = re.search(r"http-equiv=[\"']?refresh[\"']?[^>]*url=([^\"'>\s]+)", html, re.I)
        if m and len(html) < 1500:  # alias stubs are a single tiny <head>
            aliases[url] = m.group(1).replace(HOST, "")
        else:
            pages.add(url)
    return sorted(pages), aliases


def write(name, lines):
    with open(os.path.join(HERE, name), "w") as f:
        f.write("\n".join(lines) + "\n")


def main():
    live = fetch_live_paths()
    pages, aliases = scan_hugo_build()

    write("live-urls.txt", live)
    write("hugo-urls.txt", pages)
    write("hugo-aliases.txt", [f"{k} -> {v}" for k, v in sorted(aliases.items())])

    live_n = {norm(p) for p in live}
    page_n = {norm(p) for p in pages}
    alias_n = {norm(k) for k in aliases}

    one_to_one = live_n & page_n
    via_alias = (live_n - page_n) & alias_n
    missing = live_n - page_n - alias_n
    extra = page_n - live_n - {norm(v) for v in aliases.values()}

    print(f"Live URLs (sitemap)      : {len(live)}")
    print(f"Hugo pages / aliases     : {len(pages)} / {len(aliases)}")
    print(f"  1:1 direct match       : {len(one_to_one)}")
    print(f"  resolved via alias     : {len(via_alias)}")
    print(f"  MISSING (404 risk)     : {len(missing)}")
    for m in sorted(missing):
        print(f"      - {m}")
    print(f"  extra Hugo pages       : {len(extra)}")
    for e in sorted(extra):
        print(f"      + {e}")

    return 1 if missing else 0


if __name__ == "__main__":
    sys.exit(main())

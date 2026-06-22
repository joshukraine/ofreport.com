#!/usr/bin/env python3
"""Re-runnable URL parity VERIFICATION gate — live HTTP resolution on the preview.

This is the third stage of the §2 URL-parity pipeline (audit → redirects →
verify) and the complement to audit.py:

    audit.py   structural diff — live sitemap vs. the local ./public build.
               Proves the right pages EXIST. No network calls to the new site.
    verify.py  behavioral gate — fires real HTTP requests at the deployed Hugo
               site and proves every old URL RESOLVES (200 directly, or via a
               single 301 to a 200), with no 404s and no redirect chains.

Built to be re-run as the final pre-cutover check (epic #150 §7 step 7): point
it at the deploy preview before launch, then at the production domain on cutover
day. Output is greppable and the exit code is non-zero on any failure, so a
clean run is unambiguous.

Usage (from repo root):
    python3 docs/url-parity/verify.py                          # default: deploy preview
    python3 docs/url-parity/verify.py https://ofreport.com     # cutover-day check

Input:
    live-urls.txt — the authoritative old-URL inventory captured by audit.py
                    (373 URLs: 223 blog permalinks, 25 tag roots, pagination,
                    static pages). Re-run audit.py first if the live site changed.

What "resolves cleanly" means here:
    Netlify normalizes a missing trailing slash with its own 301 (`/contact`
    -> `/contact/`). That hop is cosmetic — same page, just the slash — so it is
    NOT counted against the "single 301" budget. Only a redirect to a DIFFERENT
    page (e.g. `/blog/page/1` -> `/blog/`) counts as a content hop. A URL passes
    when it ends in 200 with at most one content hop; it fails on a 404, a
    multi-hop chain, a redirect loop, or any other non-200 final status. This
    mirrors the 347 (1:1) / 26 (needs-301) / 0 (gone) split in report.md.
"""

import concurrent.futures
import http.client
import os
import re
import sys
import urllib.error
import urllib.request
from urllib.parse import urljoin, urlparse, urlsplit

DEFAULT_BASE = "https://ofreport-dev.netlify.app"
HERE = os.path.dirname(os.path.abspath(__file__))
INVENTORY = os.path.join(HERE, "live-urls.txt")
THREADS = 12
TIMEOUT = 25
MAX_HOPS = 5  # cap the chain walk so a redirect loop terminates as a failure
REDIRECT_CODES = (301, 302, 307, 308)
USER_AGENT = "url-parity-verify"


# --- HTTP -------------------------------------------------------------------

def fetch_once(url):
    """One HEAD request that does NOT follow redirects. Returns (status, location|None).

    Uses http.client directly so a 3xx is just a normal response we can read the
    Location off of — no redirect handler, no treating redirects as errors. A
    network/timeout error returns status 0.
    """
    parts = urlsplit(url)
    conn_cls = http.client.HTTPSConnection if parts.scheme == "https" else http.client.HTTPConnection
    path = parts.path or "/"
    if parts.query:
        path += "?" + parts.query
    conn = conn_cls(parts.netloc, timeout=TIMEOUT)
    try:
        conn.request("HEAD", path, headers={"User-Agent": USER_AGENT})
        resp = conn.getresponse()
        loc = resp.getheader("Location") if resp.status in REDIRECT_CODES else None
        return resp.status, loc
    except Exception:
        return 0, None
    finally:
        conn.close()


def fetch_body(url):
    """GET that DOES follow redirects (for the feed/sitemap). Returns (status, text)."""
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
            return resp.status, resp.read().decode("utf-8", "replace")
    except urllib.error.HTTPError as e:
        return e.code, ""
    except Exception:
        return 0, ""


# --- Resolution & classification --------------------------------------------

def resolve(base, path):
    """Walk the redirect chain for base+path. Returns [(path, status, loc_path|None), ...]."""
    chain = []
    url = base + path
    seen = set()
    for _ in range(MAX_HOPS + 1):
        status, loc = fetch_once(url)
        cur_path = urlparse(url).path or "/"
        loc_path = urlparse(urljoin(url, loc)).path if loc else None
        chain.append((cur_path, status, loc_path))
        if status in REDIRECT_CODES and loc and url not in seen:
            seen.add(url)
            url = urljoin(url, loc)
            continue
        break
    return chain


def content_hops(chain):
    """Redirect hops that change the page — trailing-slash normalization excluded."""
    return sum(
        1
        for cur, status, loc in chain
        if status in REDIRECT_CODES and loc and cur.rstrip("/") != loc.rstrip("/")
    )


def classify(chain):
    """Bucket a resolved chain. ok_* pass the gate; fail_* fail it."""
    final = chain[-1][1]
    if final in REDIRECT_CODES:
        return "fail_loop"  # still redirecting after MAX_HOPS
    if final == 200:
        hops = content_hops(chain)
        if hops == 0:
            return "ok_direct"    # 1:1 (possibly after a cosmetic slash 301)
        if hops == 1:
            return "ok_redirect"  # single content 301 -> 200
        return "fail_chain"       # 2+ content redirects
    if final == 404:
        return "fail_404"
    return "fail_status"          # 0 (network error), 5xx, etc.


def chain_str(chain):
    """Render a chain compactly for the failure listing, e.g. /a ->301 /b ->200."""
    parts = [chain[0][0]]
    for _, status, loc in chain:
        parts.append(f"->{status}" + (f" {loc}" if loc else ""))
    return " ".join(parts)


# --- Inventory --------------------------------------------------------------

def load_inventory():
    if not os.path.isfile(INVENTORY):
        sys.exit(f"ERROR: {INVENTORY} not found. Run audit.py first to capture the inventory.")
    with open(INVENTORY, encoding="utf-8") as f:
        return [line.strip() for line in f if line.strip()]


# --- Report -----------------------------------------------------------------

def main():
    base = (sys.argv[1] if len(sys.argv) > 1 else DEFAULT_BASE).rstrip("/")
    paths = load_inventory()

    print("URL parity verification — live HTTP resolution gate")
    print(f"Base      : {base}")
    print(f"Inventory : {len(paths)} URLs ({os.path.relpath(INVENTORY)})")
    print(f"Probing {len(paths)} URLs + /feed.xml + /sitemap.xml ...\n")

    # Resolve the whole inventory concurrently.
    with concurrent.futures.ThreadPoolExecutor(max_workers=THREADS) as pool:
        results = dict(zip(paths, pool.map(lambda p: resolve(base, p), paths)))
    verdicts = {p: classify(chain) for p, chain in results.items()}

    one_to_one = [p for p, v in verdicts.items() if v == "ok_direct"]
    via_301 = [p for p, v in verdicts.items() if v == "ok_redirect"]
    failures = sorted(p for p, v in verdicts.items() if v.startswith("fail"))

    print("Resolution buckets:")
    print(f"  1:1 (200, direct / slash-normalized) : {len(one_to_one)}")
    print(f"  single 301 -> 200                    : {len(via_301)}")
    print(f"  FAILURES                             : {len(failures)}")

    # SEO-critical confirmations (counts come from report.md / the migrated set).
    blog = [p for p in paths if re.fullmatch(r"/blog/[^/]+", p)]
    tags = [p for p in paths if re.fullmatch(r"/tags/[^/]+", p)]
    blog_ok = [p for p in blog if not verdicts[p].startswith("fail")]
    tags_ok = [p for p in tags if not verdicts[p].startswith("fail")]

    feed_status, feed_body = fetch_body(f"{base}/feed.xml")
    feed_ok = feed_status == 200 and ("<rss" in feed_body or "<feed" in feed_body)

    sitemap_ok, sitemap_notes = check_sitemap(base, results)

    print("\nSEO-critical confirmations:")
    print(report_line(len(blog_ok) == len(blog) == 223,
                      f"blog permalinks : {len(blog_ok)}/{len(blog)} resolve (expect 223)"))
    print(report_line(len(tags_ok) == len(tags) == 25,
                      f"tag pages       : {len(tags_ok)}/{len(tags)} resolve (expect 25)"))
    print(report_line(feed_ok, f"/feed.xml       : {feed_status} ({'XML feed' if feed_ok else 'NOT a feed'})"))
    print(report_line(sitemap_ok, f"/sitemap.xml    : {sitemap_notes}"))

    if failures:
        print(f"\nFAILING URLs ({len(failures)}):")
        for p in failures:
            print(f"  [{verdicts[p]}] {chain_str(results[p])}")

    passed = (
        not failures
        and len(blog_ok) == len(blog) == 223
        and len(tags_ok) == len(tags) == 25
        and feed_ok
        and sitemap_ok
    )
    print()
    if passed:
        print("RESULT: PASS — every old URL resolves 1:1 or via a single 301 to 200.")
        return 0
    print("RESULT: FAIL — see failures above.")
    return 1


def report_line(ok, text):
    return f"  [{'PASS' if ok else 'FAIL'}] {text}"


def check_sitemap(base, results):
    """The new sitemap must be 200, list only resolving URLs, and exclude /thank-you."""
    status, body = fetch_body(f"{base}/sitemap.xml")
    if status != 200:
        return False, f"{status} (not reachable)"

    locs = re.findall(r"<loc>(.*?)</loc>", body)
    sm_paths = sorted({urlparse(loc).path for loc in locs})

    # /thank-you is the one new noindex page; it must not be in the sitemap.
    has_thank_you = any(p.rstrip("/") == "/thank-you" for p in sm_paths)

    # Every listed URL must resolve to 200 (reuse the inventory result when we
    # already probed it; probe the rest). Catches stale or broken sitemap entries.
    broken = []
    for p in sm_paths:
        chain = results.get(p) or resolve(base, p)
        if classify(chain).startswith("fail"):
            broken.append(p)

    ok = not has_thank_you and not broken
    notes = f"{status}, {len(sm_paths)} URLs, all resolve" if not broken else f"{status}, {len(broken)} broken entries"
    if has_thank_you:
        notes += "; /thank-you LEAKED into sitemap"
    elif not broken:
        notes += "; /thank-you excluded"
    return ok, notes


if __name__ == "__main__":
    sys.exit(main())

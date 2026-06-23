#!/usr/bin/env python3
"""og-check.py — verify Open Graph / Twitter Card metadata (issue #183).

Why this exists:
  The launch gate (#150 §6) requires the social-card metadata to render
  correctly before cutover. The PRD asserts it; this proves it. For one
  representative URL per meta variation it confirms a complete OG + Twitter
  card is emitted and that every `og:image` resolves 200 at exactly 1200x630.

Why it is checkable on the preview:
  `og:url` and `<link rel=canonical>` come from `.Permalink` (baseURL =
  https://ofreport.com), so the cards reference the *production* domain even on
  the deploy preview — what we validate here is what production will serve.
  `og:image` runs through the Cloudinary `og` preset (c_fill,h_630,w_1200),
  which forces 1200x630 regardless of source aspect ratio.

Gotcha (why we parse instead of regex values):
  Hugo's minifier leaves attribute names and space-free values unquoted —
  e.g. `<meta name=robots content="index,follow">`,
  `<link rel=canonical href=https://ofreport.com/>`. A naive `name="robots"`
  regex yields false negatives. Each tag's attributes are parsed
  quote-agnostically below.

Usage:  python3 docs/og-check.py     # exits non-zero on failure
"""
import re
import struct
import sys
import urllib.request

BASE = "https://ofreport-dev.netlify.app"
URLS = [
    "/",                                            # homepage      — website, fallback image
    "/blog/2026-05-27-teaching-serving-standing/",  # article       — own cover
    "/blog/2008-10-10-new-ofr-posted/",             # cover-less     — fallback image
    "/tags/newsletter/",                            # tag page      — website, fallback image
    "/family/",                                     # static page   — own cover
]
KEYS = ["og:type", "og:title", "og:url", "og:image",
        "og:image:width", "og:image:height", "twitter:card", "twitter:image"]
ATTR = re.compile(r'([\w:-]+)\s*=\s*(?:"([^"]*)"|\'([^\']*)\'|([^\s">]+))')
UA = {"User-Agent": "og-check"}


def get(url):
    return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=30)


def attrs(tag):
    return {k.lower(): (a or b or c or "") for k, a, b, c in ATTR.findall(tag)}


def jpeg_dims(b):
    i = 2
    while i < len(b) - 9:
        if b[i] != 0xFF:
            i += 1
            continue
        if 0xC0 <= b[i + 1] <= 0xCF and b[i + 1] not in (0xC4, 0xC8, 0xCC):
            h, w = struct.unpack(">HH", b[i + 5:i + 9])
            return f"{w}x{h}"
        i += 2 + struct.unpack(">H", b[i + 2:i + 4])[0]
    return "?"


def main():
    seen, ok = {}, True
    for path in URLS:
        html = get(BASE + path).read().decode("utf-8", "replace")
        meta = {}
        for m in re.finditer(r"<meta\b([^>]*)>", html):
            a = attrs(m.group(1))
            key = a.get("property") or a.get("name")
            if key and "content" in a:
                meta.setdefault(key, a["content"])
        canon = next((attrs(m.group(0)).get("href")
                      for m in re.finditer(r"<link\b[^>]*>", html)
                      if attrs(m.group(0)).get("rel") == "canonical"), None)
        print(f"\n{path}")
        print(f"   {'canonical':<16} {canon or '— MISSING'}")
        print(f"   {'robots':<16} {meta.get('robots', '— MISSING')}")
        for k in KEYS:
            v = meta.get(k)
            if not v:
                ok = False
            print(f"   {k:<16} {(v[:78] + '…') if v and len(v) > 78 else (v or '— MISSING')}")
        img = meta.get("og:image")
        if img and img not in seen:
            r = get(img)
            seen[img] = (r.status, jpeg_dims(r.read()))

    print("\nog:image — status / pixels (must be 200 / 1200x630):")
    for url, (status, dims) in seen.items():
        bad = status != 200 or dims != "1200x630"
        ok = ok and not bad
        print(f"   [{status}] {dims} {'✗' if bad else '✓'}  {url}")

    print("\nRESULT:", "PASS ✅" if ok else "FAIL ❌")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()

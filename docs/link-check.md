# Site-wide Link Check

**Issue:** #168 (launch-readiness epic #150 §3)
**Tool:** [`lychee`](https://github.com/lycheeverse/lychee) (config in `lychee.toml`)
**Last run:** 2026-06-23 — ✅ **0 broken internal links; outbound failures triaged.**

A re-runnable pre-cutover gate that crawls the built site and verifies every link
resolves. Internal links are the hard gate (zero tolerance); outbound links are
triaged (best-effort — some hosts bot-block automated requests, some legacy links
are dead with no live equivalent).

## How to run

```bash
brew install lychee                          # one-time
hugo --gc --minify --cleanDestinationDir     # produce a clean ./public
lychee --root-dir "$PWD/public" public       # auto-loads lychee.toml; exits non-zero on failure
```

`--root-dir` resolves Hugo's root-relative links (`/blog/…`) against `./public`
as local files; everything else is checked over the network. A clean run prints
`0 Errors` and exits `0`.

## Scope

| Class | Treatment |
| --- | --- |
| **Internal navigation/content** (`/blog/…`, pages, tags) | **Hard gate** — every link must resolve to a real file in the build. |
| **Outbound / external** | Triaged — fixed, repointed, or accepted with a note (see below). |
| **`ofreport.com`** (self/canonical) | Excluded — verified by the URL-parity gate (`docs/url-parity/verify.py`, #173); checking it here would hit the live Nuxt site. |
| **`res.cloudinary.com`** (our image CDN) | Excluded — bulk automated HEADs get throttled (non-deterministic "connection failed"; the images are live). Cover images have a dedicated gate, `scripts/probe-covers.rb` (#166). |

> **Coverage boundary:** because our Cloudinary CDN is excluded, this gate does
> not re-verify every figure-image derivative. Cover images are covered by
> `probe-covers.rb`; a typo'd inline figure public ID would not be caught here.

## Result (2026-06-23)

```text
🔍 16182 Total  🔗 3830 Unique  ✅ 12710 OK  🚫 0 Errors  👻 3472 Excluded
```

**Internal links:** clean. The only internal "errors" in the first pass were six
protocol-relative (`//host`) legacy media URLs that `--root-dir` mis-resolved as
local files; they are live and were normalized to explicit `https://` (below).

## Outbound triage

### Fixed / repointed (in content)

| Was | Now | Where |
| --- | --- | --- |
| `//d21…cloudfront.net/…` (audio + 4 images) | `https://…` (protocol-relative → explicit) | `2012-07-03-patient-faith`, `2016-12-31-translators` |
| `//platform.instagram.com/…embeds.js` | `https://…` | `2017-06-13-bible-first-kids` |
| `…euroteamoutreach.org/index.php?p=cmo` (CMO links) | `https://cmoproject.org/` | `2011-11-08-life-is-colorful`, `2015-02-09-welcome-kathryn-grace` |
| `mises.org/library/law-0` (dead audio variant) | `mises.org/library/law` (the live "Read online" target) | `2008-12-03-have-you-read-the-law` |
| `kelsie.me` (footer; broken TLS cert) | `https://kelsiesteele.substack.com/` ("Kelsie's Substack") | `hugo.toml` footer (site-wide) |

### Accepted with a note (`lychee.toml` exclude list)

- **Not actually broken:** Vimeo embed players (401 to crawlers, play when embedded); `ford.co.uk` (HTTP/2 quirk); the `you-monster-gif` Cloudinary lightbox (animated-GIF derivative exceeds Cloudinary's `w_1600` pixel budget — the figure itself displays fine).
- **Dead legacy links, no live equivalent:** old Euro Team Outreach PHP paths (`?p=bftv`, `?p=ereport`, `?p=contact`, `/cmo/download_*.php`, `/zhylavy/`, and the `?p=cmo` app-download link); `picasaweb.google.com`, `lmgtfy.com`, `generation-impact.com`, `hispower.org`, `libertarium.ru`, `pysannya.com`, `kadebloomukraine.com`, `covid19.gov.ua`, `mealtrain.com/9wlnd5`, `jsua.co/jan-2021-invitation`, a removed `travel.state.gov` COVID page, an `unsplash.com/@yirage` attribution, and two reorganized `militaryland.net` report URLs.

### Open follow-up

- **`nogreaterjoy.org/shop/ministry-gift-ukraine-ge-printing/`** — a "Donate Now" button on `2025-04-23-before-the-curtain-closes` (404; product page gone). Accepted in the exclude list for now; **needs the current NoGreaterJoy giving URL** to repoint (it is a live donation CTA).

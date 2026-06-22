# URL Parity Report — Nuxt → Hugo

**Issue:** #171 (launch-readiness epic #150 §2, audit stage)
**Date:** 2026-06-22
**Verdict:** ✅ **Full parity. 0 of 373 live URLs would 404 on Hugo.** One new page (`/thank-you`) and one cosmetic redirect cleanup (`page/1`) are the only follow-ups for the redirect-map issue (#172).

This is the **audit** stage of the 3-issue §2 pipeline (audit → redirects → verify). It proves URL parity rather than asserting it, and names the exact redirect set #172 must implement. It makes **no template or redirect changes**.

---

## Method

1. **Live inventory** — fetched `https://ofreport.com/sitemap.xml` (the Nuxt site's own, Google-submitted sitemap; `robots.txt` points at it). 373 URLs.
2. **Crawl cross-check** — probed URLs a sitemap can omit (`/feed.xml`, `/rss`, `/robots.txt`, `/sitemap.xml`, `/index.xml`) and scraped the live homepage's internal links. Nothing indexable surfaced outside the sitemap (details below).
3. **Hugo inventory** — clean build (`hugo --gc --minify --cleanDestinationDir`) then walked `./public`: every `index.html` is a served URL; tiny meta-refresh stubs are aliases. 348 pages + 26 aliases.
4. **Diff** — normalized away the trailing-slash difference and categorized every live URL (`docs/url-parity/audit.py`).
5. **Empirical redirect tests** — `curl` against the live Hugo preview (`ofreport-dev.netlify.app`) and the live Nuxt site to confirm *actual* Netlify behavior rather than assuming it.

Re-run any time with `python3 docs/url-parity/audit.py` (after a clean build). It exits non-zero if any live URL would 404. The snapshots (`live-urls.txt`, `hugo-urls.txt`, `hugo-aliases.txt`) are committed alongside this report.

`audit.py` proves the right pages **exist** (static `./public` diff). The companion **`verify.py`** proves every old URL **resolves** by firing real HTTP requests at the deployed site — see "Verification (#173)" below.

---

## Live inventory (373 URLs)

| Category | Count | Pattern |
| --- | --- | --- |
| Blog posts | 223 | `/blog/{slug}` |
| Blog index | 1 | `/blog` |
| Blog pagination | 28 | `/blog/page/1` … `/blog/page/28` |
| Tags index | 1 | `/tags` |
| Tag roots | 25 | `/tags/{tag}` |
| Tag pagination | 87 | `/tags/{tag}/page/N` |
| Home | 1 | `/` |
| Static pages | 7 | `/archives` `/contact` `/donate` `/family` `/ministry` `/podcast` `/subscribe` |
| **Total** | **373** | |

The blog count (223) matches the migrated content set exactly. The 25 tags in the sitemap are the full live tag set (the `[taxonomies]` config and Hugo build produce the same 25 — note `CLAUDE.md`'s "26 tags" is slightly stale).

---

## Categorization — every old URL

| Bucket | Count | Notes |
| --- | --- | --- |
| **1:1** | 347 | Same path resolves on Hugo (after Netlify's automatic trailing-slash 301 — see below). All posts, tag roots, static pages, home, both indexes, and `page/2…N`. |
| **needs-301** | 26 | The `page/1` URLs (`/blog/page/1` + 25 `/tags/{tag}/page/1`). Already resolved to their list root via Hugo's automatic aliases; a cleaner server-side 301 is the one open decision for #172. |
| **gone** | 0 | Nothing was intentionally dropped. |
| **404 risk** | 0 | No live URL is unreachable on Hugo. |

**Extra Hugo URL (new, not on the live site): 1 — `/thank-you`.** This is the contact-form confirmation page (the Nuxt site processed its form via an AWS Lambda and had no such page). It is currently in Hugo's sitemap and lacks a `noindex` — see Recommendations.

---

## Trailing-slash analysis (the stated risk — resolves to a non-issue)

The issue flagged a mismatch: the Nuxt sitemap lists **no** trailing slash (`/contact`) while Hugo uses `/contact/`. Empirically, **both sites behave identically** — the slash form is canonical on each, and the no-slash form 301s to it:

| Request | Old Nuxt site | New Hugo/Netlify |
| --- | --- | --- |
| `/contact` | **301 → `/contact/`** | **301 → `/contact/`** |
| `/contact/` | 200 | 200 |
| `/blog` | **301 → `/blog/`** | **301 → `/blog/`** |
| `/blog/{slug}` | 301 → `/blog/{slug}/` | 301 → `/blog/{slug}/` |

So the sitemap's no-slash paths were *already* 301-redirecting on the live Nuxt site; Netlify's automatic "pretty URLs" normalization reproduces that behavior on Hugo with no configuration. **No trailing-slash redirect rules are needed — and none should be added** (manual rules would only risk redirect loops with Netlify's built-in normalization).

One incidental improvement: Nuxt served `/contact/` but declared its canonical as `/contact` (no slash) — self-contradictory. Hugo's canonical is `https://ofreport.com/contact/`, matching the served URL. Cleaner, and a net SEO positive.

---

## Pagination analysis (exact parity)

Both sites paginate at **8 items per page** (`[pagination] pagerSize = 8`), producing the **same page counts everywhere**:

- **Blog:** 28 pages on both. Nuxt: `/blog/page/1…28`. Hugo: `/blog/` (page 1) + `/blog/page/2…28`, with `/blog/page/1` as an alias to `/blog/`.
- **Tags:** every tag's max page number is identical (verified tag-by-tag): `family` 13, `ministry` 13, `photos` 9, `newsletter` 8, `cmo` 5, `ukraine` 5, `bible-first` 4, `podcast` 4, `abs` 3, `good-and-evil` 3, … down to 16 single-page tags. No tag gained or lost a page.

### How `page/1` resolves today (and why the existing redirect is a no-op)

Hugo's paginator **automatically** emits an alias for every `page/1` → its list root (26 stubs: 1 blog + 25 tags — this is built-in Hugo behavior, not configured anywhere in `layouts/`). Each stub is a 0-second meta-refresh:

```html
<link rel=canonical href=https://ofreport.com/tags/cmo/>
<meta http-equiv=refresh content="0; url=https://ofreport.com/tags/cmo/">
```

**Finding:** the existing `netlify.toml` rule `/blog/page/1 → /blog/ (301)` **never fires.** Traced on the live preview:

```text
/blog/page/1  →[301]→  /blog/page/1/  →[200]→  (alias stub, meta-refresh to /blog/)
```

Netlify normalizes the trailing slash first, then serves Hugo's `page/1/index.html` (which exists), so the **non-forced** redirect is shadowed by the file. The 25 tag `page/1` URLs were never covered by a server rule at all — they rely entirely on the meta-refresh aliases. Meta-refresh at 0 seconds is treated by Google as a 301-equivalent, so this is *functional* and *SEO-acceptable today*, but it is a 200-with-client-redirect rather than a clean server 301.

---

## Crawl cross-check (non-sitemap URLs)

| URL | Live status | Parity note |
| --- | --- | --- |
| `/feed.xml` | 200 | ✅ Hugo emits `/feed.xml` (`baseName = "feed"`). RSS URL preserved — Mailchimp continuity intact. |
| `/sitemap.xml` | 200 | ✅ Hugo emits its own. |
| `/robots.txt` | 200 | ✅ `enableRobotsTXT = true`. |
| `/rss`, `/rss.xml`, `/feed`, `/index.xml` | 404 | No alternate feed URLs exist to preserve. |
| `/404` | 200 (soft) | Nuxt soft-404; Hugo + Netlify serve a real 404 (custom `404.html`, #169). Improvement. |

The homepage's only other internal references are `_nuxt/*` build bundles (retire with Nuxt) and static assets (`favicon-*.png`, `apple-touch-icon.png`, `site.webmanifest`, `safari-pinned-tab.svg`). Those are assets, not indexed pages — out of scope here; covered by the site-wide link check (#168).

---

## The redirect set #172 must implement

1. **Trailing slash → nothing.** Netlify's automatic normalization already 301s no-slash → slash, matching the old site. Do **not** add manual rules.

2. **`page/1` (26 URLs) → one decision.** Pick A or B:

   - **Option A (recommended): clean server-side 301s.** Add forced redirects so the 26 `page/1` URLs return a real 301 to their list root, and drop the dead rule. Must use the trailing-slash form and `force = true` to win over both the alias file and Netlify's normalization:

     ```toml
     [[redirects]]
       from = "/blog/page/1/"
       to = "/blog/"
       status = 301
       force = true

     # …and one per tag, e.g.:
     [[redirects]]
       from = "/tags/:tag/page/1/"
       to = "/tags/:tag/"
       status = 301
       force = true
     ```

     (Confirm whether Netlify's `:tag` placeholder covers all 25 in one rule, or whether 25 explicit rules are needed — verify in #172.) Remove the current ineffective `/blog/page/1 → /blog/` rule.

   - **Option B: accept the Hugo aliases.** Leave the meta-refresh stubs as the `page/1` redirect mechanism and delete the dead `netlify.toml` rule so config doesn't imply a 301 that isn't happening. Less work; slightly weaker SEO signal.

   Recommendation: **A** — the project already committed to a `netlify.toml` redirect for `page/1`; making it actually work (and extending it to tags) is the consistent finish.

3. **`/thank-you` → add `noindex`, exclude from sitemap.** Not a redirect, but it is the one new indexable URL. A form-confirmation page should not be indexed or sitemapped. Best handled in #172 (or a small cleanup issue) alongside the redirect work.

---

## Acceptance criteria (#171 — audit)

- [x] Authoritative old-URL inventory captured (sitemap + crawl) and committed — `live-urls.txt` (373).
- [x] Every old URL categorized (1:1 / needs-301 / gone) — 347 / 26 / 0; 0 would 404.
- [x] Pagination and trailing-slash behavior explicitly analyzed and documented — both verified empirically.
- [x] Report names the exact redirect set the redirect-map issue must implement — see above.

---

## Verification (#173) — live resolution gate

The audit above *predicts* parity from a static diff. `verify.py` *proves* it by
firing real HTTP requests at the deployed Hugo site and asserting every old URL
ends in a `200` — directly, or via a **single** `301` — with no `404`s, no
redirect chains, and no loops. Built to be re-run as the final pre-cutover check
(epic #150 §7 step 7).

### How to run

```bash
python3 docs/url-parity/verify.py                       # default: deploy preview
python3 docs/url-parity/verify.py https://ofreport.com  # cutover-day check
```

It reads the `live-urls.txt` inventory, follows each URL's redirect chain
hop-by-hop, and exits non-zero on any failure so a clean run is unambiguous.

### What counts as a clean resolve

Netlify normalizes a missing trailing slash with its own `301` (`/contact` →
`/contact/`). That hop is cosmetic — same page — so it does **not** count against
the "single 301" budget; only a redirect to a *different* page does. This makes
the buckets line up with the audit's 347 / 26 / 0 split:

- **1:1** — `200`, direct or after the cosmetic slash `301` (347 URLs).
- **single 301** — one content redirect → `200`; the `page/1` set (26 URLs).
  Netlify applies the forced `page/1/ → list-root` rule *and* the slash
  normalization in one hop, so e.g. `/blog/page/1` → `301` → `/blog/` is a clean
  single redirect, not a chain.
- **FAIL** — a `404`, a 2+ hop content chain, a loop, or any non-`200` final
  status.

### Result (deploy preview, 2026-06-22)

```text
Resolution buckets:
  1:1 (200, direct / slash-normalized) : 347
  single 301 -> 200                    : 26
  FAILURES                             : 0

SEO-critical confirmations:
  [PASS] blog permalinks : 223/223 resolve (expect 223)
  [PASS] tag pages       : 25/25 resolve (expect 25)
  [PASS] /feed.xml       : 200 (XML feed)
  [PASS] /sitemap.xml    : 200, 258 URLs, all resolve; /thank-you excluded

RESULT: PASS — every old URL resolves 1:1 or via a single 301 to 200.
```

The new sitemap lists 258 URLs (real pages only — no `page/1` aliases, no
`/thank-you`, no stale Nuxt-only paths); every one resolves `200`.

### Acceptance criteria (#173 — verify)

- [x] Every old URL resolves 1:1 or via a single `301` → `200` on the preview — 347 / 26 / 0.
- [x] `/blog/:slug/`, `/tags/{tag}/`, and `/feed.xml` confirmed resolving — 223, 25, and the feed all `PASS`.
- [x] `sitemap.xml` reflects the new structure (no stale Nuxt-only URLs) — 258 real-page URLs, all resolve, `/thank-you` excluded.
- [x] Script is documented and re-runnable for the cutover-day check (§7 step 7) — `verify.py`, accepts a base-URL argument.

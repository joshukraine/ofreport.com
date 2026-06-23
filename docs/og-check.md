# OG / Social Card Verification

**Issue:** #183 (launch-readiness epic #150 §6)
**Script:** [`docs/og-check.py`](og-check.py)
**Last run:** 2026-06-23 — ✅ **PASS** — all 5 representative URL types emit complete, valid OG + Twitter cards; every `og:image` resolves `200` at exactly 1200×630.

A re-runnable pre-cutover gate that proves the Open Graph / Twitter Card metadata renders into valid social cards — mirroring the link-check (#168), URL-parity (#173), and integrations (#179) gates. `layouts/partials/seo.html` is the single source of truth for these tags.

## Why this is checkable on the preview

`og:url` and `<link rel=canonical>` are built from `.Permalink` (i.e. `baseURL = https://ofreport.com`), so even on `ofreport-dev.netlify.app` the cards reference the **production** domain — what we validate here is exactly what production will serve. `og:image` runs through the Cloudinary `og` preset (`c_fill,f_auto,h_630,q_auto,w_1200`), which forces 1200×630 regardless of source aspect ratio. Only the `robots` tag differs by environment (see the note below).

## How to run

```bash
python3 docs/og-check.py     # exits non-zero on failure
```

The script fetches each representative URL, parses every `<meta>`/`<link>` tag's attributes quote-agnostically (see the gotcha below), and HEADs + measures each unique `og:image`.

## Coverage — one representative URL per meta variation

| URL | `og:type` | `og:image` source |
| --- | --- | --- |
| `/` (homepage) | `website` | site fallback (`params.ogImage`) |
| `/blog/2026-05-27-teaching-serving-standing/` | `article` | the post's own `cover` |
| `/blog/2008-10-10-new-ofr-posted/` (cover-less) | `article` | **fallback** — exercises the cover-less path |
| `/tags/newsletter/` | `website` | site fallback |
| `/family/` | `website` | the page's own `cover` |

## Result (2026-06-23) — ✅ PASS

Every URL emits a complete card:

- **`og:type`** correct per page type — `article` for blog posts, `website` everywhere else.
- **`og:title`, `og:description`, `og:url`, `og:site_name`** all present; **`twitter:card=summary_large_image`** with `twitter:title` + `twitter:image`.
- **`canonical` + `og:url`** point at the **production** domain (`https://ofreport.com/…`) on every page.
- **3 distinct `og:image`s** (the site fallback, the article cover, the family cover) each resolve `200` and measure **exactly 1200×630** — matching the `og:image:width`/`height` meta. The Cloudinary `og` preset is doing its job; no source aspect ratio leaks through to distort the card.
- **Cover-less fallback confirmed:** `/blog/2008-10-10-new-ofr-posted/` (one of the 98 cover-less posts) falls back to `params.ogImage` for `og:image` — no card is image-less.

A visual card mock for the homepage + article, built from the live OG values, was rendered in-browser and confirmed undistorted — the fallback image fills the 1.91:1 frame cleanly and the article cover is sharp, with title/description/domain composing as expected.

## Gotcha for re-runners — minified attributes

Hugo's minifier leaves attribute **names** (and space-free values) unquoted in the served HTML — e.g. `<meta name=robots content="index,follow">` and `<link rel=canonical href=https://ofreport.com/>`. A naive `name="robots"` / `rel="canonical"` regex yields **false negatives**: the tag is present, the quotes are not. `og-check.py` parses each tag's attributes quote-agnostically to avoid this.

## Note — `robots=index,follow` on the preview (expected)

The probe shows `index,follow` on `ofreport-dev` because its `main` builds run with `HUGO_ENVIRONMENT=production` (pinned in `netlify.toml`, which overrides UI env). This is the **documented interim SEO note in #150 §6** — risk is low (every page's `canonical` consolidates to `ofreport.com`) and the dev site is deleted at cutover. It is not an OG-card concern; it appears in the probe output only because `robots` shares the SEO partial.

## Optional account-side confirm (Joshua)

The technical card is proven above; this is the final platform-rendered look. The social debuggers are login-gated, so they're Joshua's to run if desired:

- [ ] Facebook Sharing Debugger / LinkedIn Post Inspector / X Card Validator on `/` + one article — confirm the rendered preview matches.

## References

- Partial: `layouts/partials/seo.html`; image preset: `layouts/partials/cloudinary-url.html`
- Epic: #150 §6 (Production config & SEO)
- Prior gates this mirrors: #168 (link-check), #173 (URL-parity), #179 (integrations)

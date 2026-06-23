# Lighthouse Audit

**Issue:** #184 (launch-readiness epic #150 §6; PRD Phase 16)
**Last run:** 2026-06-23 — ✅ **Accessibility 100 / Best Practices 100 on all page types; contrast meets WCAG AA; blog-list CLS 0.231 → ~0.** SEO 100 except the two list pages (the "Read more" pattern, accepted below).

A pre-cutover gate that audits representative pages with Lighthouse, records a baseline, and fixes or triages the findings — mirroring the link-check (#168), URL-parity (#173), integrations (#179), and OG-card (#183) gates.

## How to run

```bash
# One page (mobile is the form factor that surfaced the issues; add --preset=desktop for desktop):
npx lighthouse https://ofreport-dev.netlify.app/ \
  --only-categories=performance,accessibility,best-practices,seo \
  --form-factor=mobile --output=json --output-path=home.json --quiet \
  --chrome-flags="--headless=new"
```

Representative pages: `/` · `/blog/2026-05-27-teaching-serving-standing/` (heaviest — cover + figures + GLightbox) · `/blog/` · `/tags/newsletter/` · `/tags/`.

> **Measure deterministic categories against a production-config build.** Accessibility / Best-Practices / SEO / CLS are stable; run them against `ofreport-dev` (or a local `HUGO_ENVIRONMENT=production hugo --minify` build served over HTTP) so robots is `index,follow`. **Mobile *performance* scores are high-variance** (simulated throttling + remote Cloudinary images + edge-cache warmth) — take the median of 3–5 runs and don't read a single run as signal.

## Results — before → after

Accessibility / Best Practices / SEO are deterministic (measured on production-config builds). Performance is reported separately because of the variance note above.

| Page | Accessibility | Best Practices | SEO |
| --- | --- | --- | --- |
| Homepage | 96 → **100** | 100 | 100 |
| Article (heaviest) | 97 → **100** | 100 | 100 |
| Blog list | 95 → **100** | 100 | 92 (accepted) |
| Tag term (`/tags/newsletter/`) | 95 → **100** | 100 | 92 (accepted) |
| Tags index (`/tags/`) | 95 → **100** | 100 | 100 |

**Performance:** desktop is excellent across the board (**90–100**, no regressions). Mobile is throttle/network-dominated; the homepage shows the expected win from the LCP changes (**80 → 96, LCP 3.7 s → 2.5 s**). The headline mobile improvement is deterministic: **blog-list CLS 0.231 → ~0** (eliminated). Single-run mobile *scores* on the list/tag pages swing ±10 between the warm main site and a cold deploy-preview, so no absolute mobile score delta is claimed there.

## Fixes applied

### Accessibility — contrast to WCAG AA (the main finding)

`color-contrast` failed on every page. Two distinct causes, both fixed (CHANGELOG 2026-06-23):

- **Inline text links** were blue-600 (#1992d4), ~3.3:1 on the page gray — below AA's 4.5:1. Darkened to **blue-800** (#0b69a3, ~5.5:1) site-wide via the prose `--tw-prose-links` token + the `text-blue-600` utilities in eight templates; hover deepens to blue-900.
- **Article tag pills** were `bg-blue-600` + `opacity-50` + white text = **1.82:1** (the opacity fade was the killer). Now solid **blue-800** (~5.7:1), hover blue-900. The tags-index pills (`text-blue-700` on `bg-blue-50`, ~3.9:1) darkened to blue-800.

This is a deliberate divergence from the original Nuxt site's lighter link blue — accessibility over pixel-parity — logged in `docs/prd/CHANGELOG.md`.

### Performance — blog-list LCP / CLS

- **Cloudinary `preconnect`** in `<head>`: every image/cover loads from `res.cloudinary.com`, so the connection is opened ahead of the LCP cover fetch.
- **Featured cover loads eagerly + `fetchpriority="high"`** (`article-card.html`): the first, above-the-fold card is the LCP candidate, so lazy-loading it was an anti-pattern. Grid cards below stay lazy. This — plus reserving the featured image's space — drops **blog-list CLS from 0.231 to ~0**.

## Triaged — accepted with rationale

- **SEO `link-text` "Read more" (blog list + tag pages, SEO 92).** Each card's footer has a generic "Read more" link that Lighthouse flags as non-descriptive (it keys off *visible* anchor text, an SEO signal — an `aria-label` doesn't satisfy it). **Accepted:** every card already carries a **descriptive title link** (the `<h2>`) to the same URL, so search engines have good per-article anchor text regardless; "Read more" is a deliberate UI convention. We still added `aria-label="Read more: {title}"` so screen-reader users hear the article context (a real a11y improvement even though it doesn't flip this SEO heuristic).
- **`image-aspect-ratio` (homepage, desktop only — Best Practices 96 → otherwise 100).** One decorative newsletter thumbnail (`w-[100px]`) trips the heuristic. Cosmetic, single image, no layout impact; left as-is.

## Note — SEO `noindex` on deploy-previews (expected)

A PR **deploy-preview** (`deploy-preview-NNN--…`) builds with `HUGO_ENVIRONMENT=preview`, so `robots` is `noindex,nofollow` and Lighthouse docks the SEO category. That is by design (`layouts/partials/seo.html`); the main `ofreport-dev` build and production are `index,follow`. Always read SEO from an `index,follow` build (main preview or a local production build) — the figures above are from such builds.

## References

- Templates: `layouts/partials/article-card.html`, `layouts/blog/single.html`, `layouts/taxonomy/`; tokens: `assets/css/main.css`
- Deviation log: `docs/prd/CHANGELOG.md` (2026-06-23, link + tag-pill colors)
- Epic: #150 §6 (Production config & SEO); PRD Phase 16
- Prior gates this mirrors: #168, #173, #179, #183

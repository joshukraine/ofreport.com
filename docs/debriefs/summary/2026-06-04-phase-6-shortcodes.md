# Debrief: Phase 6 — Shortcodes

- **Project:** OFReport.com Hugo Rebuild
- **Date:** 2026-06-04
- **Scope:** PRD Phase 6 (Shortcodes) — feature-complete
- **PRs:** #45, #46, #47, #48 (all merged)
- **Issues:** #41, #42, #43, #44 (all closed)
- **PRD refs:** `05-shortcodes.md`, `06-content-migration.md`

## Summary

Built the four custom Hugo shortcodes that article content is composed from — `button`, `svg`, `callout`, `figure` — in simplest-first order so each introduced one new Hugo concept and the last composed the rest. These are the migration targets for the legacy Vue components (`<article-button>`, `<article-svg>`, `<article-callout>`, `<article-image>`), so Phase 6 is a prerequisite for the Phase 15 content migration. All four merged; production build is 29 pages, 0 errors. Phase 6 is complete.

## Key Architecture Decisions

- **Shared pattern:** `.Get` named params, `errorf` (+ `.Position`) for missing required params, Tailwind-styled output. Established in `button.html`, reused across all four.
- **`button`:** normalizes Hugo's bool-vs-string `external=true` with `printf "%v"`; external links get an icon + visually-hidden "(opens in a new tab)" note.
- **`svg`:** `resources.Get` + `.Content | safeHTML` inline; missing param → `errorf` (fail), missing file → `warnf` (tolerate — Phase 8 logos don't exist yet).
- **`callout`:** first paired shortcode; `.Page.RenderString (dict "display" "block") .Inner` for block markdown; `[&>:first-child]:mt-0 / [&>:last-child]:mb-0` resets prose margins for even box padding.
- **`figure`:** one `src` → two sized Cloudinary URLs (display `figure` w_768 / lightbox `lightbox` w_1600); `not-prose` to match the cover figure; centered caption; lightbox-compatible markup (GLightbox itself is Phase 13).
- **Most significant call (altitude):** moved bare-public-ID → full-URL expansion *into* `cloudinary-url.html` (rather than the figure shortcode). Completes the shared helper's contract (it previously silently no-op'd on a public ID), removes Cloudinary URL-format knowledge from the shortcode, and is backward-compatible (full URLs skip the branch; existing cover callers unchanged).

## Test Coverage

- **No unit suite** (static site); verification = production build + manual inspection of rendered HTML. Each shortcode exercised via a temporary draft (all variants), then the draft removed — sample content folded into acceptance criteria, not committed.
- **Build:** `hugo --gc --minify` → 29 pages, 0 errors, 427ms.
- A real bug was caught by reading output: the `button` `external` bool/string mismatch (rendered without `target`/`rel`), fixed pre-PR.
- **Gaps:** no committed content uses the shortcodes yet, so the minifier hasn't seen them on a real page (first exercise = Phase 15); GLightbox open-behavior untestable until Phase 13.

## Process Notes

- Ran `/code-review medium` on every shortcode (all `[]`, no findings) and `/simplify` on `callout` (inlined a single-use var) and `figure` (the public-ID altitude move).
- One PRD deviation (figure display preset `w_768` vs. the issue's uncapped `article`) logged in `CHANGELOG.md`, then **folded back** into `05-shortcodes.md §"Figure/Image Shortcode"` at the phase boundary; CHANGELOG reset.

## Follow-Up Items

- **Phase 13 (Lightbox):** load GLightbox CSS/JS in `partials/glightbox.html` (currently a stub) to activate the `figure` markup.
- **Reuse watch:** the PDF download icon + `target/rel` pattern now appears 2× (`callout`, `article-card.html`). At a 3rd occurrence, extract a `partials/pdf-link.html`.
- **Carried from Phase 5:** issue #35 (Netlify staging), issue #11 (footer Twitter/X icon + GitHub URL); stale local branches to clean up.
- **Next:** `/plan-phase 7` (Tag Taxonomy).

# Debrief: Phase 5 — Single Article Template

**Project:** OFReport.com Hugo Rebuild
**Date:** 2026-02-13
**Scope:** PRD Phase 5 (Single Article Template)
**PRs:** #27, #28, #32, #33, #34
**Issues:** #25, #26, #29, #30, #31 (all closed)

## Summary

Built the single article template — the most important page on the site, used
by all 219 articles after migration. Delivered cover image with Cloudinary
optimization, author/date/reading time meta line, tag badges (linked to
taxonomy pages), Tailwind Typography for prose content, and previous/next
article navigation. Also linked tag badges on article cards from Phase 4. Two
bug fixes from Phase 4 cleanup were included (#25 nested quotes, #26 card
spacing). All PRs passed CI. Phase 5 is complete.

## Key Architecture Decisions

- **Tailwind Typography plugin** (`@tailwindcss/typography`) for article
  content rather than custom prose styles — covers dozens of markdown edge
  cases out of the box with minimal configuration.
- **Cloudinary `article` preset** uses `q_auto:best` (higher quality than card
  presets) since the cover image is hero-sized and above the fold.
- **`loading="eager"`** on cover images (vs. `lazy` on cards) — prevents
  visible pop-in for the primary visual element.
- **Hugo naming aliases** for prev/next (`$older`/`$newer`) to clarify the
  counterintuitive `.NextInSection`/`.PrevInSection` semantics.
- **Direct URL construction** for tag links (`/tags/{{ . | urlize }}/`) rather
  than `.GetPage` — simpler, works before tag pages exist (Phase 7), and the
  URL structure is stable.
- **`relative z-10`** on article card tag badges to make them independently
  clickable above the full-card link overlay (same pattern as the PDF link).

## Test Coverage

- Hugo production build: 29 pages, 0 errors (232ms)
- CI: all 5 PRs passed (Hugo Build + Markdown Lint)
- Prev/next navigation verified across full article set
- Tag badge click targets verified on article cards (z-index stacking)
- Gap: tag links render via the unstyled `_default/list.html` placeholder
  until Phase 7 (HTTP 200, not a 404), visual testing is manual only

## Follow-Up Items

- Issue #35 created: early Netlify staging deployment before Phase 6
- Issue #11 (open): footer minor improvements (Twitter/X icon, GitHub URL)
- Deferred to later phases: cover image lightbox (13), PDF callout (6),
  Mailchimp form (12), tag pages (7)
- 8 stale local branches should be cleaned up

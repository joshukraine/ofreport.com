# Debrief: Phase 4 — Blog Listing with Pagination

**Project:** OFReport.com Hugo Rebuild
**Date:** 2026-02-11
**Scope:** PRD Phase 4 (Blog Listing with Pagination)
**PRs:** #21, #22, #23, #24
**Issues:** #16, #17, #18, #19, #20 (all closed)

## Summary

Built the blog listing page — the first content-facing feature of the site.
Delivered a Cloudinary URL builder partial (5 named presets), 12 sample blog
articles for development, an article preview card partial (featured/regular
variants), the blog section listing template with page-1 featured card + grid
layout, and a reusable pagination partial with windowed page numbers (current
+/- 2 with ellipsis). The blog listing correctly paginates 12 articles across
2 pages with proper Previous/Next navigation. All four PRs passed CI. Phase 4
is complete.

## Key Architecture Decisions

- **Preset-based Cloudinary URLs** — named presets (`featured`, `regular`,
  `article`, `og`, `rss`) defined in the partial, not config. Keeps image
  logic co-located with template code.
- **Single `return` pattern** in Cloudinary partial — required for Go 1.24
  compatibility where the built-in `return` (0 args) shadows Hugo's `return`
  (1 arg). All future returning partials should use this pattern.
- **One article card partial, two variants** — `featured` boolean controls
  layout (horizontal vs vertical). Shared structure is ~90% identical so a
  single partial avoids duplication.
- **Section-specific blog template** at `layouts/blog/list.html` rather than
  overloading `_default/list.html`. Prevents blog-specific logic from
  affecting taxonomy pages.
- **Featured article in the paginated set** — page 1 shows `pagerSize` total
  articles (1 featured + 7 grid) for consistent page sizes across all pages.
- **Windowed pagination** — current +/- 2 with ellipsis. Scales to 28+ pages.
  Page numbers hidden on mobile (Previous/Next arrows only).

## Test Coverage

- Hugo production build: 17 pages, 0 errors (~220ms)
- Markdown lint: 31 files, 0 errors
- CI: all 4 PRs passed (Hugo build + markdownlint)
- One expected warning: missing `single.html` for blog articles (Phase 5)
- Gap: windowed pagination verified by mental trace, not yet tested with 28+
  page data

## Follow-Up Items

- Issue #11 (open): footer Twitter/X icon and GitHub URL fixes
- Phase 5 (single article template) is next — article links currently 404
- Tag badges are styled but not linked (deferred to Phase 7)
- Pagination windowing should be spot-checked after content migration (Phase 15)

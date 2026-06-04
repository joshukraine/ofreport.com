# OFReport.com Hugo Rebuild — PRD Changelog

This file tracks material deviations from the PRD discovered during implementation. It is the record of the "never silently deviate" rule. See `~/.claude/docs/prd-workflow/spec-driven-development.md` §2–§3 for the deviation threshold and workflow.

## Format

Each entry records one deviation or decision:

```text
### YYYY-MM-DD — [file changed]

**What changed:** One-sentence description of the change.

**Why:** The rationale — what was wrong, what was discovered, or what prompted the pivot.

**Category:** Correction | Discovery | Pivot
```

**Categories:**

- **Correction** — The PRD was wrong or inconsistent.
- **Discovery** — Implementation revealed something the PRD didn't anticipate.
- **Pivot** — A deliberate decision to change direction.

## Guidelines

- **Newest entries first** — add new entries at the top of the Entries section.
- Log when the PR is created, not after it's merged.
- The "why" is required — a change without rationale is not useful.
- Skip typo fixes and formatting corrections.
- At natural breakpoints (end of a phase, or 10+ accumulated entries), fold changes back into the PRD files themselves during a sync session.

---

## Entries

### 2026-06-04 — `layouts/shortcodes/figure.html`, `layouts/partials/cloudinary-url.html`

**What changed:** The figure shortcode serves its inline display image from a new width-capped `figure` Cloudinary preset (`w_768`) and its lightbox link from a new larger `lightbox` preset (`w_1600`), instead of the uncapped `article` preset named in the issue #44 technical note (`05-shortcodes.md`).

**Why:** The `article` preset is width-uncapped (it serves the full original), which contradicts the established convention of ~768px inline body images — confirmed by Joshua against the current Nuxt blog — that keeps article bodies from loading huge files. "Display = article + a larger lightbox" was self-contradictory, since `article` is already full-size. A capped display (`w_768`, covering the `max-w-2xl` ≈ 672px article column) plus a larger lightbox (`w_1600`) is the correct click-to-zoom pattern. The cover image (handled separately in `blog/single.html`) is unaffected.

**Category:** Correction

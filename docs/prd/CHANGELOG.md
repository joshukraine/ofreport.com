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

### 2026-06-06 — `docs/prd/01-architecture.md` §"RSS Feed", `docs/prd/ROADMAP.md` Phase 9

**What changed:** The custom RSS feed sends a curated excerpt (`<description>`) plus a single cover-image `<enclosure>` per item, rather than the full HTML-rendered article the PRD called for ("include HTML-rendered description/content").

**Why:** The existing Nuxt feed already runs successfully on an excerpt-only model, and excerpts are the better fit here on three counts: they drive readers back to the site (where the donate/subscribe CTAs, podcast, and lightbox galleries live), they keep emails under Gmail's ~102KB clipping threshold, and they avoid the broken-image problem of image-heavy posts in email (email clients can't lazy-load, so a 20-image post would either block or eager-load every image). The "Read more" link is added in the Mailchimp campaign via the `RSSITEM:URL` merge tag, keeping the feed itself clean.

**Category:** Pivot

### 2026-06-04 — `docs/prd/03-site-structure.md`, `docs/prd/ROADMAP.md`

**What changed:** Renamed the Phase 7 taxonomy templates from `taxonomy/tags.html` / `taxonomy/tag.html` to `taxonomy/taxonomy.html` (all-tags index) and `taxonomy/term.html` (single-tag list).

**Why:** The original names don't match Hugo's template lookup. `tags.html` (plural) is never looked up and would silently fall through to `_default/list.html`; `tag.html` (singular) is ambiguous because it matches both the `taxonomy` and `term` page kinds, so one file can't reliably render both the index and the per-tag pages. `taxonomy.html` (taxonomy kind) and `term.html` (term kind) are the correct, unambiguous Hugo names.

**Category:** Correction

<!--
  Folded into the PRD on 2026-06-04 (end of Phase 6):
  - figure shortcode sizing (figure `w_768` display / `lightbox` `w_1600`, not the
    uncapped `article` preset) → 05-shortcodes.md "Figure/Image Shortcode" Notes.
-->

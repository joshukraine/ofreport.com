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

### 2026-06-21 — `scripts/migrate.rb` (new)

**What changed:** Added the Ruby migration script (issue #126) covering frontmatter transforms, the six `<article-*>` → shortcode conversions, and the tag fix. Several details depart from or refine the spec in `06-content-migration.md`:

- **`basename` / `iso8601Date` removal is a no-op.** Spec step 2 says to remove these fields; neither is present in any of the 223 source files, so the script does not handle them. Confirmed and skipped.
- **`<article-image>` drops `width` / `height` / `border`.** The Hugo `figure` shortcode is responsive-by-preset and only accepts `src` / `caption` / `alt`, so those Vue props are not carried over (a design decision baked into the shortcode when it was built). `alt` falls back to `caption` inside the shortcode.
- **`<article-button>` drops `margin`; `<article-svg>` drops `alt` / `margin` and cannot wrap a `link`.** The target shortcodes don't expose those knobs. The single `<article-svg link=…>` instance (`2019-12-23-kade-to-ukraine`) is flagged by the report for manual review.
- **`<article-callout :link="{…}">` becomes a markdown link line** appended inside the callout body (the new `callout` shortcode has no `link` param). External links therefore lose `target="_blank"`.
- **Missing-`preview` fallback** (1 file, `2008-12-23-in-him-was-life`): `description` is generated from the first body paragraph (markdown-stripped, truncated on a word boundary) and flagged.
- **`image:` → `cover:`** (1 file, `2012-11-04-today-fly`): the key is renamed per spec, but the value is a legacy WordPress relative path, not a Cloudinary URL — flagged for the legacy cleanup issue. Its `date` also carried a time component (`2012-11-04 20:43:37`), so dates are normalized to `YYYY-MM-DD`.
- **Re-runnability guard = skip-if-exists** (per Joshua's 2026-06-21 decision), with `--force` to re-migrate all and `--dry-run` to validate without writing. A normal re-run writes only new (late-arriving) files and never clobbers existing ones, so post-migration hand-edits are safe; the trade-off is that an upstream correction to an already-migrated post needs `--force`.

This PR commits the **script + this entry only** — it does not yet write the 223 articles into `content/blog/`. The source bodies still contain unconverted raw HTML (`<img>`/`<nuxt-link>`/`<iframe>`; 142 files flagged by the script's report), which is the next issue's scope. Committing clean content once, after that pass, keeps `main` shippable.

**Why:** "Never silently deviate" — these mappings are forced by the existing shortcode signatures rather than the spec's prose, and the two frontmatter outliers + the legacy-HTML residue needed documented, deliberate choices. The deferred content drop was confirmed with Joshua.

**Category:** Discovery

### 2026-06-21 — `docs/prd/00-overview.md`, `docs/prd/06-content-migration.md`, `docs/prd/07-deployment.md`, `docs/prd/README.md`, `docs/prd/ROADMAP.md`, `CLAUDE.md`, `README.md`

**What changed:** Corrected the article count from 219 → 223 and the date range from 2008–2025 → 2008–2026 across all PRD and project docs (issue #125, Phase 15 pre-flight). Also recorded that the lone file in the Nuxt repo's `content/drafts/` is the `COPY-ME-YYYY-MM-DD-catchy-article-title.md` authoring scaffold (Lorem ipsum, not real content) and is therefore excluded from the migration.

**Why:** Four new posts landed on the live Nuxt site after the PRD's counts were written (the latest is dated 2026-05-27). A `git pull` of the source repo (`../ofreport.com-nuxt2/`) confirmed **223** published articles in `content/articles/` — nothing newer than the local clone — spanning **October 2008 to May 2026**. The "5 static pages" and "26 source tags" figures were re-verified and remain accurate (the 26 tags include both `good and evil` and `good-and-evil`, which the migration consolidates, yielding 25). Migration scope is now locked at 223 articles.

**Category:** Correction

### 2026-06-13 — `layouts/partials/page-shell-open.html`, `layouts/partials/page-shell-close.html`, `layouts/_default/{single,contact,subscribe,archives}.html`

**What changed:** Extracted the shared static-page "shell" (the faded `bgImage` background wrapper + centered page `<h1>`) into a `page-shell-open.html` / `page-shell-close.html` partial pair that `single`, `contact`, `subscribe`, and `archives` now consume (issue #92). In doing so, the shared `<h1>` standardized on the `text-center`-first class order used by 3 of the 4 layouts, which reorders the class attribute on pages rendered through `single.html` (`ministry`, `donate`, `thank-you`, `podcast`).

**Why:** Issue #92 set "rendered HTML is byte-equivalent" as the bar, but `single.html`'s `<h1>` already listed its utility classes in a different order than the other three layouts, so a single shared header cannot be byte-identical to all four at once. Standardizing on the majority order changes only one layout's output, and the change is a pure class **reorder** (identical class set) — verified visually inert since Tailwind applies utility CSS by stylesheet source order, not class-attribute order. A full recursive `public/` diff confirmed every other page (including the byte-identical `contact`/`subscribe`/`archives`) is unchanged. Chose a partial pair over a `baseof` block because `family.html` shares Hugo's default `type = "page"` but uses a divergent cover-hero design that a type-level base block would wrongly wrap.

**Category:** Discovery

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

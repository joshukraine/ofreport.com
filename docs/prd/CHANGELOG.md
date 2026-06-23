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

### 2026-06-23 — `assets/css/main.css`, link + tag-pill colors across `layouts/`

**What changed:** Darkened the inline text-link color site-wide from blue-600 (#1992d4) to blue-800 (#0b69a3), with hover deepening to blue-900 — via the prose `--tw-prose-links` token plus the explicit `text-blue-600` link utilities in eight templates (index, subscribe, archives, callout, taxonomy term, pagination, `_default/list`, article-card). Also restyled the two tag-pill variants: article pills (`bg-blue-600` + `opacity-50` + white text → solid `bg-blue-800`, hover `bg-blue-900`) and tags-index pills (`text-blue-700` / `text-blue-700/60` → `text-blue-800`). Following design review, content text links also gained a consistent affordance — **underlined at rest, underline removed on hover** — applied site-wide to inline/content links (prose, "Archives"/"Unsubscribe", "Download PDF", archives PDF links, `_default/list`, "View all tags", blog-card "Read more") but **not** to blog-card title links, tag pills, or the pagination widget.

**Why:** The Lighthouse pre-cutover audit (#184) flagged the link color at ~3.3:1 and the faded article tag pills at 1.82:1 — both below WCAG AA (4.5:1). The original Nuxt site used the lighter blue-600, and the rebuild reproduced it during the design-parity pass, so this is a deliberate divergence from pixel-parity in favor of accessibility. blue-800 is already the site's button/nav blue, so the palette stays cohesive. Accessibility rose to 100 on all five audited page types. The underline affordance is a second deliberate divergence (the original had no link underlines): with the blue darkened close to the body text, the resting underline — not color — now carries link-ness, and its removal on hover is the interactive feedback.

**Category:** Pivot

### 2026-06-23 — `layouts/_default/rss.xml`, `hugo.toml`

**What changed:** Hardened the RSS feed for Mailchimp RSS-to-email (issue #180), refining the 2026-06-06 excerpt-only model. Three template changes plus one build-config change: (1) each item now carries a `<content:encoded>` CDATA block — an email-safe cover `<img>` sized by width only (`width="600"` + inline `height:auto`, delivered via the `og` preset's uniform 1200×630 / 1.91:1 fill) followed by the excerpt — while `<description>` stays the plain-text excerpt; (2) `<pubDate>` and `<lastBuildDate>` emit at **noon UTC** (`… 12:00:00 +0000`) instead of the stored midnight-UTC stamp; (3) the `<enclosure>` `type` is derived from the cover's file extension instead of being hardcoded `image/jpeg`; (4) `[minify] disableXML = true` added to `hugo.toml` so production builds preserve the literal `<![CDATA[…]]>` wrapper (the tdewolff XML minifier would otherwise rewrite it as entity-encoded HTML).

**Why:** Two warts followed the feed over from the legacy Nuxt site. The cover image rendered stretched in email because the feed offered it only as an `<enclosure>`, leaving sizing to Mailchimp's image block (fixed width *and* height onto a non-matching ratio); the width-only `<img>` in `content:encoded` can't distort, and the fixed 1.91:1 `og` ratio keeps every email uniform and retina-crisp at the 600px display width. The publish date displayed one day early because posts are date-only, so Hugo stamps them midnight UTC, which reads as the previous evening anywhere west of UTC (all of the Americas); noon UTC keeps the displayed day correct everywhere from the Americas to Ukraine without editing 223 posts' frontmatter (a site `timeZone` was rejected — pointing it at Kyiv shifts the stamp *backward*, worse). The hardcoded `image/jpeg` was inaccurate for the two `.png` covers in the current feed window. CDATA is preserved (over the minifier's equivalent entity-encoding) because it is the more robustly-interpreted form for HTML inside `content:encoded` across RSS/Mailchimp consumers; `disableXML` leaves HTML/CSS/JS minification untouched and only ships `feed.xml`/`sitemap.xml` with whitespace preserved (both valid, negligible after gzip).

**Category:** Pivot

### 2026-06-22 — `docs/prd/03-site-structure.md`, `docs/prd/appendix.md`, `docs/prd/ROADMAP.md`, `CLAUDE.md`

**What changed:** Descoped `authors.json` from the migration. The PRD listed it as a data file to migrate (`appendix.md` envisioned author name/bio/avatar accessed via `site.Data.authors`), but it is not being brought over to the Hugo site. `archives.json` migration is unaffected (done, byte-identical to the Nuxt source).

**Why:** The data file's original purpose was to render each byline as a live link to that author's homepage/profile. The blog has three authors — Joshua and Kelsie Steele (the site owners) and Raphaël Villeneuve (a single guest post years ago, who has no link). Self-linking the owners' bylines to `/contact` is redundant, and the richer author-profile capability the PRD imagined (bio/avatar blocks) is premature abstraction for this author set. Nothing in the Hugo build reads the file: the byline renders from the frontmatter `author` string (`.Params.author`) as plain text in `single.html` / `article-card.html`, with no `site.Data.authors` lookup anywhere, and the file was never copied into `data/`. So this is a clean descope, not a removal of working functionality — an authors data file is trivial to add back if the author base ever grows.

**Category:** Pivot

### 2026-06-22 — `layouts/partials/cloudinary-url.html`, `content/blog/2012-11-04-today-fly.md`

**What changed:** Graceful-display pass for no-cover / small-image legacy articles (issue #135). Verification found the requirement was already met by the templates, which faithfully ported the original Nuxt site's `v-if="cover"` guards: the single-article hero and preview-card image both omit cleanly when `cover` is absent (no broken hero, no 404), OG/Twitter fall back to `params.ogImage`, and the RSS `<enclosure>` is omitted. The documented no-cover fallback is therefore **omit** (parity with the original), not a neutral default header. Two hardening changes applied: (1) the display Cloudinary presets (`featured`, `regular`, `hero`) switched from `c_scale` to `c_limit` so an intrinsically small image is never upscaled; (2) the one broken relative-path cover (`2012-11-04-today-fly`) repointed to its CloudFront URL so it loads via Cloudinary fetch.

**Why:** #135 framed the no-cover fallback as an open choice (omit vs. neutral default). The original site omits, all 124 real covers are large Cloudinary-native images (no small/legacy covers exist), and inline figures already use `c_limit` — so the existing behavior already satisfies every acceptance criterion. Choosing "omit" keeps parity and avoids introducing a default-cover asset to maintain. The `c_scale → c_limit` guard is a zero-cost correctness improvement (identical output for the large covers we have) that makes "no upscale" provably hold if a small cover ever appears. The `today-fly` cover was a migration gap — a relative WordPress path the script left unconverted because it lived in `cover:` frontmatter rather than a body `<img>`.

**Category:** Discovery

### 2026-06-22 — `docs/prd/07-deployment.md`, `docs/prd/ROADMAP.md`

**What changed:** Settled the legacy repo's post-launch name as `ofreport.com-nuxt` (the PRD's `07-deployment.md` previously gave `ofreport.com-legacy` as an illustrative example). Added a pointer from `ROADMAP.md` Phase 16 to the new Launch Readiness Epic (#150).

**Why:** Launch planning produced a concrete cutover runbook (#150), and the repo-rename dance there needs an exact name rather than an example. `ofreport.com-nuxt` names the predecessor stack explicitly. The ROADMAP pointer keeps the epic as the single source of truth for launch *execution* while the PRD remains the spec and Phase 16 stays the high-level phase marker — avoiding two competing task lists.

**Category:** Correction

**What changed:** Excluded `content/blog/**` from markdown linting. The 223-article migration baseline (issue #136) committed raw script output, which trips 141 markdownlint errors (heading-increment, ordered-list prefixes, emphasis style, trailing whitespace) inherited from the legacy WordPress→Middleman→Nuxt content.

**Why:** Issue #136 mandates a machine-generated-only baseline with zero hand-edits (per-article fixes are deferred to #129), but the CI `lint:md` gate lints `**/*.md` and blocked the merge. Doc-style rules like heading-increment and ordered-list-prefix are the wrong scope for prose, and the largest error bucket (heading-increment) is content-semantic and not mechanically fixable. Excluding migrated blog prose unblocks CI without editing the baseline; re-enabling lint for blog content (if wanted) can be folded into the #129 quality pass.

**Category:** Discovery

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

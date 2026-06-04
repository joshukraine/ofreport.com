# Debrief: Phase 5 — Single Article Template

**Project:** OFReport.com Hugo Rebuild
**Date:** 2026-02-13
**Scope:** PRD Phase 5 (Single Article Template) — [`04-templates.md`](../docs/prd/04-templates.md)
**PRs:** #32, #33, #34 (+2 bug-fix PRs from Phase 4 cleanup: #27, #28)
**Issues closed:** #25, #26, #29, #30, #31

---

## 1. What We Built (and Why It Matters)

Phase 5 delivers the **single article page** — the most important template on
the site. Every one of the 219 articles that will be migrated renders through
this template. It's the page readers land on from search, social shares, and
RSS clicks.

**What shipped:**

- **Single article template** (`layouts/blog/single.html`) — cover image with
  Cloudinary optimization, caption, article title, author/date/reading time
  meta line, tag badges, prose-styled article content, and previous/next
  navigation.
- **Tailwind Typography plugin** (`@tailwindcss/typography`) — provides the
  `prose` class for rendering markdown content with good defaults.
- **Previous/next article navigation** — chronological nav at the bottom of
  each article, with arrow indicators and hover states.
- **Linked tag badges** — tag badges on both article cards and single articles
  are now `<a>` links pointing to `/tags/{tag}/`. These resolve (HTTP 200) to
  the unstyled `_default/list.html` placeholder until the styled tag pages
  arrive in Phase 7.
- **Two Phase 4 bug fixes** — nested quote issue in article card date
  formatting (#25) and missing gap between cover image and tags (#26).

**What was intentionally deferred:**

| Item | Deferred to | Reason |
|------|-------------|--------|
| Cover image lightbox | Phase 13 (GLightbox) | Needs GLightbox JS loaded first |
| PDF download callout | Phase 6 (Shortcodes) | The `callout` shortcode doesn't exist yet |
| Mailchimp signup form | Phase 12 | Separate integration concern |
| Tag taxonomy pages | Phase 7 | Tag links render via the unstyled `_default/list.html` placeholder until then (HTTP 200, not a 404) |

These deferrals are all correct. Each depends on infrastructure that hasn't
been built yet. The single template has clean extension points for all of them.

**Where we are in the bigger picture:** Phases 1-5 are complete. The site now
has a working layout, navigation, blog listing with pagination, and individual
article pages. You can browse the blog end-to-end. The remaining phases add
features (shortcodes, taxonomies, static pages) and integrations (RSS, SEO,
forms, analytics) on top of this foundation.

---

## 2. Architecture & Design Decisions

### Single template layout (`layouts/blog/single.html`)

The template follows the PRD's top-to-bottom layout specification exactly:
cover image → caption → title → meta → tags → content → prev/next nav. A few
choices worth explaining:

**Cloudinary preset: `article`** (line 7). The single article uses
`q_auto:best` (highest quality) while card previews use `q_auto` (standard).
This is deliberate — the cover image is the hero element on the article page
and renders at full width, so the quality bump is worth the bandwidth. On cards,
the image is small enough that standard quality is indistinguishable.

**`loading="eager"` on the cover image** (line 13). Card images use
`loading="lazy"`, but the cover image is above the fold on every article page,
so eager loading avoids a visible pop-in on page load.

**Prose styling approach** (line 53):

```go-html-template
<div class="mt-10 max-w-2xl prose prose-gray prose-a:text-blue-700 prose-a:hover:text-blue-900">
  {{ .Content }}
</div>
```

We use Tailwind's `@tailwindcss/typography` plugin with the `prose` class
rather than writing custom styles for every markdown element. The modifier
classes (`prose-gray`, `prose-a:text-blue-700`) customize link colors to match
the site's blue accent. This gives us well-typeset headings, paragraphs, lists,
blockquotes, code blocks, and tables out of the box.

The `max-w-2xl` constrains the content column to a comfortable reading width
(~672px) while the outer container is `max-w-3xl` (~768px). This creates a
subtle narrowing effect for the prose content while giving the cover image and
title more breathing room.

**Alternative considered:** Writing custom prose styles with `@apply` in
`main.css`. Rejected because `@tailwindcss/typography` is well-maintained,
covers dozens of edge cases (nested lists, table alignment, code block
overflow), and saves significant effort. The 12KB size impact is negligible.

### Previous/next navigation (`single.html` lines 57-87)

**Hugo naming is counterintuitive:** `.NextInSection` returns the *older*
article (next chronologically going backward), and `.PrevInSection` returns the
*newer* article. We alias these for clarity:

```go-html-template
{{- $older := .NextInSection -}}
{{- $newer := .PrevInSection -}}
```

The nav uses a two-column layout on desktop (`sm:flex-row sm:justify-between`)
and stacks vertically on mobile. When only one direction exists (first or last
article), an empty `<div class="flex-1">` spacer keeps the remaining link
properly aligned. This avoids the newer article jumping to the left side when
there's no older article.

**Hover state pattern:** Both links use `group` / `group-hover:text-blue-700`
so that hovering anywhere on the link block (label + title) triggers the color
change, not just the text directly under the cursor.

### Tag badge linking strategy

Two files, two slightly different approaches:

**Article card** (`partials/article-card.html` line 26-31): Tags need
`relative z-10` because the card has a full-surface click overlay
(`<span class="absolute inset-0">`) that makes the entire card clickable. Without
`z-10`, tag clicks would be intercepted by the overlay and navigate to the article
instead. This is the same pattern used by the PDF download link in the card footer.

**Single article** (`blog/single.html` line 42-47): No `z-10` needed here —
there's no overlay to compete with. Tags are straightforward links.

Both use the same URL construction: `{{ "/tags/" | relURL }}{{ . | urlize }}/`.
The `relURL` pipe ensures correct behavior if the site is served from a
subdirectory (unlikely but defensive), and `urlize` handles Hugo's standard
URL normalization for tag names (lowercase, hyphens for spaces).

**Why not `.GetPage`?** The PRD mentioned `.GetPage` as an option. We chose
direct URL construction because: (a) tag taxonomy pages don't exist yet, so
`.GetPage` would return nil, (b) the URL structure (`/tags/{urlized-tag}/`) is
stable and defined in `hugo.toml`, and (c) direct construction is simpler and
more readable. When tag pages are built in Phase 7, these URLs will resolve
correctly without any changes here.

---

## 3. Test Coverage & Quality

This is a Hugo static site — no unit test framework. Coverage comes from build
verification and visual inspection.

**Build status:**

```text
Build:    29 pages, 0 errors, 232ms
CI:       Hugo Build pass, Markdown Lint pass (all 3 PRs)
Warnings: 0
```

**What we verified:**

- All 12 sample articles render as individual pages with correct cover images,
  metadata, and content
- Previous/next navigation chains correctly across all articles (first article
  shows only "Next", last shows only "Previous", middle articles show both)
- Tag badge links point to correct `/tags/{tag}/` URLs
- Tag badges are independently clickable on article cards (not intercepted by
  the full-card overlay)
- PDF link on article cards still functions alongside tag links
- Prose content renders with proper typography (headings, paragraphs, links)

**Verification commands:**

```bash
# Production build
hugo --gc --minify

# Dev server with drafts
hugo server -D

# Check a specific article
# Visit http://localhost:1313/blog/2024-06-15-language-learning-journey/
```

**Coverage gaps:**

- No automated visual regression testing — all styling verification is manual
- Prev/next navigation should be spot-checked after content migration (Phase
  15) with 219 articles to ensure correct ordering at scale
- Tag links resolve to the unstyled `_default/list.html` placeholder, not a
  404 — the styled tag pages come in Phase 7

---

## 4. Product Tour — Try It Yourself

Start the dev server:

```bash
hugo server -D
```

### Story 1: Browse the blog and click into an article

1. Visit **http://localhost:1313/blog/**
2. You'll see the blog listing from Phase 4 — featured article at top, grid
   below
3. Click any article title (e.g., "Language Learning Journey")
4. You land on the single article page. Notice:
   - **Cover image** renders full-width with rounded corners (articles that
     have a `cover` frontmatter field)
   - **Title** in large serif font
   - **Meta line** shows author, formatted date, and reading time (e.g.,
     "Joshua Steele · June 15, 2024 · 1 min read")
   - **Tag badges** appear below the meta line as blue pills
   - **Article content** is typeset with the prose plugin — clean paragraphs,
     good line height, blue links
5. Scroll to the bottom — you'll see **Previous/Next navigation** with arrow
   indicators and article titles

### Story 2: Navigate between articles using prev/next

1. From any article, scroll to the bottom
2. Click **"Next"** (the newer article) — notice the arrow indicator and hover
   state (text turns blue on hover)
3. On the newest article (first chronologically), you'll see only a
   **"Previous"** link — the Next link is absent, and Previous stays
   right-aligned on desktop
4. Navigate to the oldest article — you'll see only **"Next"** with no
   Previous link

### Story 3: Click a tag badge from an article card

1. Go back to **http://localhost:1313/blog/**
2. On any article card, hover over a **tag badge** (e.g., "newsletter",
   "family") — notice it highlights with a lighter blue background
3. **Click the tag badge** — it navigates to `/tags/{tag}/`, which renders via
   the unstyled `_default/list.html` placeholder (the styled tag page arrives
   in Phase 7)
4. **Important:** notice the tag badge is independently clickable even though
   the entire card is also clickable. The tag and the card are separate click
   targets. Compare this to clicking the card's title or image, which navigates
   to the article.

### Story 4: Click a tag badge from the single article page

1. Visit **http://localhost:1313/blog/2024-07-30-july-ministry-report/**
2. Below the meta line, you'll see tag badges (e.g., "newsletter")
3. Hover — same blue highlight effect
4. Click — navigates to `/tags/newsletter/`, rendered by the unstyled
   `_default/list.html` placeholder for now

### Story 5: Article without a cover image

1. Visit **http://localhost:1313/blog/2024-06-15-language-learning-journey/**
2. This article has no `cover` field in its frontmatter
3. Notice the page starts directly with the title — no broken image, no empty
   space. The `{{ with .Params.cover }}` conditional cleanly skips the entire
   figure block.

---

## Follow-Up Items

- **Issue #35 created**: Early Netlify staging deployment — deploy to
  `*.netlify.app` before Phase 6 so all future work can be verified in a real
  environment
- **Issue #11 (open)**: Footer minor improvements (Twitter/X icon, GitHub URL)
  — standalone housekeeping, not phase-gated
- **Phase 5 items deferred to later phases**: cover image lightbox (Phase 13),
  PDF callout (Phase 6), Mailchimp form (Phase 12), tag pages (Phase 7)
- **ROADMAP.md**: Phase 5 checkboxes updated and committed
- **Stale local branches**: 8 merged branches still exist locally — recommend
  cleanup

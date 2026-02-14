# Debrief: Phase 4 — Blog Listing with Pagination

**Project:** OFReport.com Hugo Rebuild
**Date:** 2026-02-11
**Scope:** PRD Phase 4 (Blog Listing with Pagination)
**PRs:** #21, #22, #23, #24
**Issues:** #16, #17, #18, #19, #20 (all closed)

---

## 1. What We Built (and Why It Matters)

Phase 4 delivers the blog listing page — the first real "product surface" of the
site. Up until now, the work was infrastructure (scaffolding, CSS pipeline,
header/footer). This phase makes the site look like a blog for the first time.

**What shipped:**

- **Cloudinary URL builder** (`partials/cloudinary-url.html`) — a reusable
  partial that injects Cloudinary transformation parameters into image URLs.
  Five presets: `featured`, `regular`, `article`, `og`, and `rss`.
- **12 sample blog articles** in `content/blog/` — realistic test data with
  varied frontmatter (some have PDFs, some don't; different tag combinations;
  different authors). These give us something to paginate against and catch
  rendering edge cases.
- **Article preview card** (`partials/article-card.html`) — the card component
  used on listing pages. Supports a `featured` variant (horizontal layout on
  desktop) and a `regular` variant (vertical stack). Shows cover image, date,
  tags, title, description, author, and optional PDF download link.
- **Blog listing template** (`blog/list.html`) — the section list page with
  page-1-specific behavior (featured card + 2-column grid) and page-2+
  behavior (all grid, no featured).
- **Pagination partial** (`partials/pagination.html`) — windowed page numbers
  with Previous/Next arrows. Adapts to any page count using a current ± 2
  window with ellipsis. Reusable for tag listing pages in Phase 7.

**What was deferred (intentionally):**

- **Tag badge links** — the tag badges on article cards are styled but not
  linked. Linking them requires tag taxonomy pages, which is Phase 7. This
  avoids broken links in the meantime.
- **Image alt text** — currently uses the page title as `alt` for cover images.
  A dedicated `coverAlt` frontmatter field could improve accessibility but
  isn't part of the current content model.

**Where we are in the bigger picture:** Phases 1–4 are now complete (4 of 16).
The foundation and first content-facing feature are done. Phase 5 (single
article template) is next — that's where individual articles become readable.

---

## 2. Architecture & Design Decisions

### Cloudinary URL Partial (`partials/cloudinary-url.html`)

**What it does:** Takes a Cloudinary `src` URL and a `preset` name, returns a
URL with the appropriate transformation parameters inserted.

**Key decision — preset-based, not parameter-based:** Rather than accepting
individual width/height/quality parameters, the partial uses named presets.
This means every call site says `"featured"` or `"og"` instead of juggling
transform strings. The presets are defined as a `dict` inside the partial.

*Why this over a config-driven approach?* We considered putting presets in
`hugo.toml` under `[params]`, but that adds indirection without real benefit —
the presets are tightly coupled to template contexts that won't change without
template changes. Keeping them in the partial means one file to read when
debugging image URLs.

**Go 1.24 compatibility fix:** Hugo v0.155+ ships with Go 1.24, which added a
built-in `return` template action (0 args) that shadows Hugo's `return`
function (1 arg). The original implementation used multiple `return` statements
(early returns for guard clauses). This was refactored to use a single
`$result` variable with one `return` at the end. This is the safe pattern going
forward for any Hugo partial that returns a value.

### Article Card (`partials/article-card.html`)

**Design pattern — Tailwind Plus adapted:** The card layout follows Tailwind
Plus blog card patterns: absolute-positioned span for full-card click target,
`z-10` on the PDF link so it's independently clickable, `inset-ring` for
subtle image border overlay.

**Two variants via a single partial:** Rather than separate `featured-card.html`
and `regular-card.html` partials, we use a `featured` boolean parameter. The
conditional classes are straightforward (`lg:flex-row` vs `flex-col`), and
keeping one partial means one place to update when card design changes. If the
variants diverge significantly in the future, splitting would be appropriate,
but right now the shared structure is ~90% identical.

**Cloudinary preset selection:** Featured cards use `w_740` (wider for the
horizontal layout), regular cards use `w_610`. These widths match the grid
column widths at the `max-w-4xl` container. The presets are selected via
`cond $featured "featured" "regular"` — a single line that maps the boolean
to the right preset name.

**Graceful degradation:** Every piece of frontmatter is wrapped in `with` or
`range` guards. An article without a cover image, tags, author, or PDF all
render cleanly without broken markup. This matters because the 219 articles
being migrated have inconsistent frontmatter.

### Blog Listing (`blog/list.html`)

**Section template vs. default:** This lives at `layouts/blog/list.html`
(section-specific) rather than `layouts/_default/list.html`. This was a fix
caught during PR #23 review — the original implementation put blog-specific
logic in the default template, which would have broken taxonomy pages.
`_default/list.html` now has a simple generic list (title + links) that serves
as the fallback for non-blog sections.

**Pagination approach:** We use `.Paginate .Pages` which gives Hugo control
over the paginated set. The featured article on page 1 is part of the
paginated collection (it's `index $paginator.Pages 0`), meaning page 1 shows
`pagerSize` articles total (1 featured + 7 grid). An alternative approach —
paginating `after 1 .Pages` to exclude the featured item — was considered but
rejected because it creates an inconsistent page size (page 1 would have 9
articles, pages 2+ would have 8).

### Pagination (`partials/pagination.html`)

**Windowed page numbers:** With 219 articles and pagerSize 8, the site will have
~28 pages. Showing all 28 page numbers would be noisy. The window approach
(current ± 2 with ellipsis) scales gracefully:

- Page 1: **[1]** 2 3 ... 28
- Page 15: 1 ... 13 14 **[15]** 16 17 ... 28
- Page 28: 1 ... 26 27 **[28]**

**Reusability:** The partial receives the page context (`.`) and accesses
`.Paginator` internally. This is the standard Hugo convention — any list
template can call `{{ partial "pagination.html" . }}` without needing to
pre-compute or pass the paginator object. Tag listing pages in Phase 7 will
just work.

**Mobile-first:** Page numbers are hidden on mobile (`hidden md:flex`).
Mobile users get Previous/Next arrows only, which is sufficient and avoids
cramped layouts. The arrows use SVG icons from Heroicons.

**Dead branch cleanup:** Copilot review caught two unreachable code paths in
the first/last page rendering blocks. These were `if eq $current 1` and
`if eq $current $total` checks inside blocks whose guard conditions made those
states impossible. Removed in a follow-up commit for cleaner code.

---

## 3. Test Coverage & Quality

This is a Hugo static site — there's no test suite in the traditional sense.
Quality verification relies on:

**Build verification:**

```bash
hugo --gc --minify    # Production build — should complete with 0 errors
```

Current output: 17 pages, 1 paginator page, ~220ms. One expected warning about
missing `single.html` (blog articles have no single template yet — that's
Phase 5).

**Markdown linting:**

```bash
npx markdownlint-cli2 "content/**/*.md" "docs/**/*.md" "*.md"
```

Current output: 31 files, 0 errors.

**CI:** Both checks (Hugo build + markdownlint) run on every push/PR via
GitHub Actions. All 4 PRs in this phase passed CI.

**Manual verification performed:**

- Page 1 renders featured card + grid with correct Cloudinary presets
- Page 2 renders all-grid with Previous link, no Next (only 12 articles = 2
  pages)
- Articles without cover images, PDFs, or tags render without broken markup
- PDF download links point to correct CloudFront URLs
- Pagination hidden entirely when filtering to a single page of results

**Coverage gaps:**

- No visual regression testing — layout correctness is verified manually
- No automated accessibility testing (the pagination has `aria-label` and
  `aria-current`, but no automated audit)
- Windowed pagination logic was verified by mental trace through scenarios,
  not with actual 28+ page data (we only have 12 articles currently)

---

## 4. Product Tour — Try It Yourself

Start the dev server:

```bash
hugo server -D
```

### Story: Browse the blog listing

1. Visit **http://localhost:1313/blog/**
2. You should see the page title "Blog" at the top
3. The **first article** ("Winter Ministry Update") appears as a featured card
   — on desktop (`lg:` breakpoint), it has a horizontal layout with the image
   on the left and text on the right
4. Below the featured card, the **remaining 7 articles** appear in a 2-column
   responsive grid (single column on mobile, 2 columns on `md:`)
5. Each card shows: cover image, date, tag badges, title, description, author
   name, and (for some) a PDF download icon
6. Scroll to the bottom — you should see pagination: **[1] 2** and a "Next"
   arrow. There is no "Previous" link on page 1.

### Story: Navigate to page 2

1. Click "Next" or click "2" in the pagination
2. You should land at **http://localhost:1313/blog/page/2/**
3. Page 2 shows the remaining 4 articles in a 2-column grid — no featured card
4. Pagination now shows "Previous" arrow + **1 [2]** — no "Next" link since
   this is the last page
5. Click "Previous" to go back to page 1

### Story: Check mobile responsiveness

1. On the blog listing page, open browser DevTools and toggle device toolbar
   (or resize to < 768px)
2. The article grid collapses to a single column
3. Pagination page numbers disappear — only Previous/Next arrows remain
4. The featured card's image stacks above the text (no horizontal layout)

### Story: Verify Cloudinary image optimization

1. On the blog listing, right-click any cover image and "Copy image address"
2. The URL should contain Cloudinary transformation parameters:
   - Featured card: `c_scale,f_auto,q_auto,w_740`
   - Regular cards: `c_scale,f_auto,q_auto,w_610`
3. These widths match the grid column sizes for optimal loading

### Story: Check edge cases

1. Find an article card with a PDF icon (e.g., "July Ministry Report") — click
   the PDF icon. It should open a CloudFront URL in a new tab.
2. Find an article without tags — the tag badges area should be empty but the
   card layout should remain clean (no extra whitespace or broken elements)
3. Click any article title — it will 404 because `single.html` doesn't exist
   yet. This is expected and will be resolved in Phase 5.

---

## 5. Follow-Up Items

- **Issue #11** (open): Footer minor improvements (Twitter/X icon, GitHub URL).
  Low priority, can be addressed anytime.
- **Phase 5 next**: Single article template. The 12 sample articles currently
  404 when clicked — this is the natural next step.
- **`cloudinary-url.html` return pattern**: The single-return-statement pattern
  used here should be applied to any future partials that return values, due
  to the Go 1.24 `return` shadowing issue. Worth noting in CLAUDE.md if it
  comes up again.
- **Tag badge links**: Deferred to Phase 7. The badges are styled but not
  clickable. No broken links in the meantime.
- **Pagination at scale**: The windowed logic has been verified by tracing
  through scenarios but not with real 28-page data. When content migration
  (Phase 15) adds all 219 articles, worth spot-checking pagination behavior.

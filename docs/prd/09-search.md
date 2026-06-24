# Client-Side Search

---

## Goal

Give readers — and the author — a fast, in-UI way to find articles across the
full archive (200+ posts, 2008–2026) by title **and** body content. Today the
only way to locate an old article is to open the source in an editor and grep,
which creates real friction when re-sharing or revisiting a topic written about
years ago. Search closes that gap with a polished, design-native ⌘K command
palette.

This is a **post-launch enhancement**. The site is live on Hugo
(→ See [`ROADMAP.md`](./ROADMAP.md) "Phase 16: Deployment"); search adds no
architectural changes and is fully additive.

---

## Decision: Pagefind

**Selected tool:** [Pagefind](https://pagefind.app) — a fully static,
self-hosted search library that indexes the built site at deploy time and
serves search entirely client-side.

**Why Pagefind fits this site:**

- **Free and self-hosted.** No account, no API keys, no recurring cost, and no
  reader queries leaving the site — consistent with the privacy-friendly posture
  taken elsewhere (Umami over Google Analytics). Aligns with the legacy free
  Netlify plan.
- **Indexes full body content**, which is the capability that actually solves
  the "I know I wrote about this somewhere" problem. Title-only search would not.
- **Scales cleanly at this size.** Pagefind splits its index into chunks and
  loads only the slices a given query needs, so the browser never downloads the
  whole index. 200+ posts is comfortably within its sweet spot.
- **Auto-generates highlighted excerpts** for result snippets — no custom
  excerpt logic required.
- **Build-time only.** One CLI command after `hugo`; no server-side component,
  no change to the hosting model.

### Alternatives considered

| Option | Why not |
| --- | --- |
| **Algolia** (the developer's initial candidate) | Best-in-class UX, but its strengths only pay off at scale (tens of thousands of records, high query volume). At ~200 posts it adds an external dependency, an account, two API keys to manage, a build-time index push, possible future billing (free tier has caps + a mandatory "Search by Algolia" attribution and has been re-priced repeatedly), and reader queries leaving the site. The cost/complexity is real; the benefit is unused. |
| **Lunr.js / Fuse.js** (JSON index + in-browser JS) | Self-hosted and simple, but the entire index loads up front. Fine for titles; gets heavy when indexing full body across 200+ posts. Pagefind's chunked index supersedes this approach for our case. |
| **Google Programmable Search** | Free and zero-maintenance, but injects ads on the free tier, offers little styling control, depends on Google's crawl, and the UX is generic — incompatible with the design-parity bar held throughout the rebuild. |

---

## Functional Requirements

- Search **MUST** index the full body text, title, and tags of all blog
  articles, and **MUST NOT** index static pages, tag listings, pagination, or
  other non-article pages (see "Indexing Design" below).
- The search interface **MUST** be a ⌘K-style command palette that opens as an
  overlay, with results appearing as the user types (no page reload).
- The palette **MUST** be reachable by (a) a visible magnifying-glass button in
  the site header — the only affordance for touch/no-keyboard users — and (b) the
  `⌘K` (macOS) / `Ctrl-K` (Windows/Linux) keyboard shortcut. It **SHOULD** also
  open on `/`, a near-universal blog/docs convention.
- Results **MUST** show the article title and a highlighted body excerpt, and
  **SHOULD** show the publish date. Selecting a result navigates to the article
  (`/blog/:slug/`).
- The palette **MUST** support full keyboard operation: `↑`/`↓` to move through
  results, `Enter` to open the focused result, `Esc` to close.
- The interface **MUST** be built natively with the site's Tailwind v4 + Alpine
  stack against Pagefind's JavaScript API — **not** Pagefind's prebuilt UI
  component — so it matches the site's typography, color, motion, and focus
  styling exactly (→ See [`02-design.md`](./02-design.md)). The visual
  implementation will be sourced from the developer's **Tailwind Plus "Command
  Palettes"** snippets per the project's Tailwind Plus workflow: snippets are
  read for markup structure and class patterns from the gitignored
  `docs/tailwind_plus/` directory, then rebuilt as a Hugo partial — never copied
  verbatim (→ See [`CLAUDE.md`](../../CLAUDE.md) "Tailwind Plus Workflow").
- On mobile, the palette **MUST** render as a full-screen sheet rather than a
  centered overlay.
- The Pagefind runtime and index **MUST** load lazily — only when the palette is
  first opened — so initial page load and the existing Lighthouse scores are
  unaffected (→ See [`ROADMAP.md`](./ROADMAP.md) "Phase 16", Lighthouse #184/#186).
- The interface **MUST** meet the accessibility bar held elsewhere (focus trap,
  dialog semantics, focus restoration — see "Accessibility" below).

---

## UX Specification

**Trigger affordances:**

- A magnifying-glass icon button in the header (`partials/header.html`), styled
  to match existing nav controls. Visible on every page, desktop and mobile.
- Global `⌘K` / `Ctrl-K` listener; `/` as a secondary focus shortcut (ignored
  when focus is already in a text input).

**Palette behavior:**

- Opens a centered modal overlay on desktop; a full-screen sheet on mobile.
- A single text input with a search icon and a visible `Esc`/close affordance.
- Search-as-you-type, **debounced**, via `pagefind.debouncedSearch()`.
- Results render as a selectable list: **title** (emphasized), a **highlighted
  excerpt** (Pagefind wraps matched terms in `<mark>`), and the **publish date**.
- Keyboard: `↑`/`↓` move the active result, `Enter` opens it, `Esc` closes the
  palette. Mouse/touch hover and click mirror keyboard selection.
- **Empty state** (before typing): a brief prompt (e.g., "Search 200+ articles
  by title or content"). A "recent/popular" list **MAY** be added later.
- **No-results state**: a friendly message confirming the query returned nothing.

---

## Indexing Design

Pagefind indexes the rendered HTML in `public/` after the Hugo build. Scoping is
controlled with HTML attributes on the templates, primarily in
`blog/single.html` (→ See [`04-templates.md`](./04-templates.md)).

- **`data-pagefind-body`** on the article content wrapper (the element
  containing the `<h1>` title and the rendered article body). This is the key
  mechanism: **once `data-pagefind-body` exists on any page, Pagefind indexes
  only pages that carry it** — which gives us "blog articles only" for free,
  with no glob configuration. Site chrome (header, footer, nav) lives outside
  this element in `baseof.html` and is never indexed.
- **`data-pagefind-ignore`** on in-article regions that are not article content
  — the previous/next navigation and the article-footer newsletter form — so
  their text never pollutes the index or the excerpts.
- **Title**: Pagefind defaults the title to the first `<h1>` on the page, which
  is the article title. No extra markup required.
- **Date (display + sort)**: capture the publish date as metadata for the result
  card, and `data-pagefind-sort="date"` on the date element to enable a future
  date-sort option.
- **Tags (future filtering)**: `data-pagefind-filter="tag"` on the tag elements.
  Captured now so tag-filtered search can be added later **without re-indexing
  the whole archive**. No tag-filter UI ships in v1.
- **Cover thumbnail (future-proofing)**: capture the cover image as metadata
  (`data-pagefind-meta="image[src]"`) so richer result cards remain possible
  later. Captured but not displayed in v1.

---

## Build & Deployment Integration

- Add `pagefind` as an npm dev dependency so the binary is available locally and
  on Netlify.
- **Netlify build command** changes from `npm install && hugo --gc --minify` to:

  ```bash
  npm install && hugo --gc --minify && npx pagefind --site public
  ```

  (→ See [`07-deployment.md`](./07-deployment.md) and `netlify.toml`.)
- Pagefind writes its runtime and chunked index to `public/pagefind/`. The
  palette loads it lazily on first open:

  ```javascript
  const pagefind = await import("/pagefind/pagefind.js");
  const search = await pagefind.debouncedSearch(query);
  if (search !== null) {
    for (const result of search.results) {
      const data = await result.data(); // { url, excerpt, meta: { title, date, ... } }
    }
  }
  ```

  (`debouncedSearch` returns `null` when a newer query has superseded this one —
  the handler no-ops in that case.)

> **CLI flag note:** Pagefind's flags have shifted across versions
> (`--source` → `--site`). The current flag is `--site`, verified against the
> live Pagefind docs; reconfirm at implementation time.

---

## Accessibility

Held to the same bar as the post-launch a11y work (→ See
[`ROADMAP.md`](./ROADMAP.md) "Phase 16", #190/#193):

- The palette is a modal dialog: `role="dialog"`, `aria-modal="true"`, a
  labelled input, and a **focus trap** while open.
- Results use listbox semantics (`role="listbox"` / `role="option"` with
  `aria-activedescendant`) so screen readers track the active result.
- Focus moves to the input on open and is **restored to the trigger** on close.
- All functionality is operable by keyboard alone.

---

## Performance

- The Pagefind runtime (~tens of KB gzipped) and all index chunks load **only on
  first palette open**, never on initial page load — initial-load metrics and
  Lighthouse scores are unaffected.
- Per-query, only the index chunks relevant to the search terms are fetched, so
  bandwidth stays low even as the archive grows.

---

## Local Development Workflow

Pagefind indexes the **built** `public/` directory, so search does not work
against a bare `hugo server` (which serves from memory). Local testing requires
a real build:

```bash
hugo --minify && npx pagefind --site public && npx serve public
```

Pagefind's own `--serve` preview is an alternative. This is a known ergonomics
wrinkle, not a blocker; it is documented so the dev loop is understood. Day-to-day
content authoring is unaffected — only search-UI work needs the extra step.

---

## Non-Goals (v1)

Captured here so scope stays bounded; each is a clean future addition:

- **Tag- or date-filtered search UI** (the index metadata is captured now to
  enable it later without re-indexing).
- **Date-sort toggle** in results.
- **Search analytics** (which terms readers search).
- **Indexing static pages** (family, ministry, podcast, etc.) — few in number
  and already one click away in the nav.
- **Recent/popular searches** empty state.

---

## Acceptance Criteria

- [ ] `npx pagefind --site public` runs in the Netlify build and emits
  `public/pagefind/`; the build succeeds on a deploy preview.
- [ ] Only blog articles are indexed (verified: static pages, tag listings, and
  pagination do not appear in results).
- [ ] Searching a term known to appear only in an article **body** (not its
  title) surfaces that article.
- [ ] The palette opens via the header icon, `⌘K`/`Ctrl-K`, and `/`.
- [ ] Results show title, highlighted excerpt, and date; selecting one navigates
  to the correct `/blog/:slug/`.
- [ ] Full keyboard operation works (`↑`/`↓`/`Enter`/`Esc`); focus is trapped
  while open and restored to the trigger on close.
- [ ] The palette renders as a full-screen sheet on mobile and a centered
  overlay on desktop, matching the site's design system.
- [ ] Lighthouse scores on article and listing pages are unchanged (search assets
  are not loaded until the palette opens).

---

## Implementation Plan

Each item is roughly one PR's worth of work (→ See [`ROADMAP.md`](./ROADMAP.md)
"Phase 17"):

1. **Indexing & build pipeline** — add the `pagefind` dependency, update the
   Netlify build command and document the local build step, add
   `data-pagefind-body` / `-ignore` / `-meta` / `-filter` / `-sort` attributes to
   `blog/single.html`, and verify the index generates and is scoped to blog
   articles only. No UI yet; verify via the generated index / `pagefind --serve`.
2. **Command palette UI** — header trigger (icon + `⌘K`/`Ctrl-K` + `/`), the
   Alpine-driven modal built from the Tailwind Plus Command Palette snippets,
   Pagefind JS API wiring (`debouncedSearch`), result rendering (title +
   excerpt + date), keyboard navigation, and the mobile full-screen sheet.
3. **Accessibility, polish & QA** — focus trap, dialog/listbox ARIA semantics,
   focus restoration, empty/no-results states, motion/transitions, cross-browser
   and mobile QA, and a Lighthouse re-check.

---

## References

- Pagefind documentation: <https://pagefind.app>
- Indexing attributes: <https://pagefind.app/docs/indexing>
- JavaScript search API: <https://pagefind.app/docs/api>
- Original deferral note: → See
  [`08-risks-and-future.md`](./08-risks-and-future.md) §1 "Search (Optional,
  Deferred)"

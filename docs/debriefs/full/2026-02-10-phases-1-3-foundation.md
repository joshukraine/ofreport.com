# OFReport.com Hugo Rebuild — Debrief

**Date:** 2026-02-10
**Scope:** Phases 1–3 + CI infrastructure (PRs #2, #4, #8, #9, #10, #13, #15)
**PRD Phases:** Phase 1 (Scaffolding), Phase 2 (Tailwind CSS), Phase 3 (Base Layout & Navigation)

---

## 1. What We Built (and Why It Matters)

Over the last three days (Feb 8–10), we took OFReport.com from an empty
repository to a fully functional Hugo site skeleton with a working Tailwind CSS
v4 pipeline, a polished header/footer with responsive navigation, and CI that
gates every PR. Seven merged PRs cover:

| PR | What | Phase |
|----|------|-------|
| #2 | Project scaffolding — hugo.toml, package.json, archetypes, gitignore, Netlify config | Phase 1 |
| #4 | Tailwind CSS v4 pipeline via `css.TailwindCSS` | Phase 2 |
| #8 | `<head>` partial, base layout, favicon suite, Google Fonts, theme colors | Phase 3 |
| #9 | Site header with responsive Alpine.js mobile menu | Phase 3 |
| #10 | Site footer with Bible verse, 3-column links, social icons, copyright | Phase 3 |
| #13 | PRD restructured from monolith into 8 modular documents | Docs |
| #15 | GitHub Actions CI — Hugo build + markdownlint on every push/PR | Infra |

**Where we are in the bigger picture:** Phases 1–3 of 16 are complete. The
foundation is laid — we have a build pipeline, styling system, layout shell,
and CI. Everything from here (Phase 4 onward) is building content templates
*inside* this shell: blog listings, article pages, shortcodes, taxonomies,
etc.

**What was intentionally deferred:**

- SEO partial (`seo.html`) — Phase 10. The `<head>` has title + description
  but not Open Graph, Twitter Cards, or canonical URLs yet.
- GLightbox and analytics — stub partials exist (`{{/* implemented in Phase
  13/14 */}}`), referenced from `baseof.html` so the template is complete and
  we won't need to touch it when those phases arrive.
- Content pages (family, ministry, etc.) — no content templates exist yet
  beyond `_default/list.html`, which is a minimal placeholder.

---

## 2. Architecture & Design Decisions

### 2.1 Tailwind CSS v4 with Hugo's Native Pipeline

**Decision:** Use Hugo's built-in `css.TailwindCSS` function instead of the
traditional PostCSS approach.

**Why:** Hugo v0.155+ has first-class Tailwind v4 support. This eliminates
`postcss.config.js`, `tailwind.config.js`, and the PostCSS pipe entirely. The
entire CSS pipeline is two files:

- `assets/css/main.css` — entry point with `@import "tailwindcss"`, `@source
  "hugo_stats.json"`, and a `@theme` block for custom colors/fonts
- `layouts/partials/css.html` — processes CSS with dev/prod branching
  (fingerprinting + SRI in production, plain `<link>` in dev)

The `@source "hugo_stats.json"` directive is the key innovation in Tailwind v4
— it tells Tailwind to read Hugo's build stats file for class purging instead
of scanning HTML files directly. This pairs with `[build.buildStats]` in
`hugo.toml` and the `templates.Defer` wrapper in `baseof.html:5-7` that
ensures `hugo_stats.json` is fully populated before CSS compilation runs.

**Rejected alternative:** PostCSS pipe with `tailwind.config.js`. That's the
Tailwind v3 approach and still works, but it's more config, more moving parts,
and doesn't take advantage of Tailwind v4's CSS-first configuration.

### 2.2 Custom Color Palette in CSS, Not Config

**Decision:** Define the blue palette and font families directly in
`assets/css/main.css` via `@theme {}` rather than a separate config file.

```css
@theme {
  --color-blue-900: #035388;
  --color-blue-dark: #024775;
  --color-blue-footer: #8bccf8;
  --font-header: "Lato", sans-serif;
  --font-serif: "Noto Serif", ui-serif, Georgia, ...;
  --font-fancy: "Mate SC", serif;
}
```

**Why:** Tailwind v4 is CSS-first. Putting theme tokens in CSS means:

1. No separate config file to maintain
2. Colors are colocated with the `@import "tailwindcss"` directive
3. Standard CSS custom properties — no framework lock-in for the color values

The blue palette (`#035388` as the primary, `#024775` for dark accents,
`#8bccf8` for footer text on dark backgrounds) was matched to the existing
OFReport.com site. Two custom semantic colors (`blue-dark`, `blue-footer`) go
beyond the standard 50–900 scale because the footer design needed specific
light-on-dark contrast ratios that didn't map cleanly to a numbered shade.

### 2.3 Base Layout & Deferred Partials

**File:** `layouts/_default/baseof.html` (19 lines)

The base template follows the PRD spec almost exactly:

```text
<html>
  <head>
    {{ partial "head.html" . }}
    {{ with templates.Defer }}
      {{ partial "css.html" . }}
    {{ end }}
  </head>
  <body>
    {{ partial "header.html" . }}
    <main>{{ block "main" . }}{{ end }}</main>
    {{ partial "footer.html" . }}
    {{ partial "glightbox.html" . }}   ← stub, Phase 13
    {{ partial "analytics.html" . }}   ← stub, Phase 14
    <script defer src="...alpinejs..."></script>
  </body>
</html>
```

**Key choice:** GLightbox and analytics partials are referenced now as stubs.
This means `baseof.html` is *done* — future phases just need to fill in the
partial contents, not touch the base template. This is deliberate: baseof is
the most coupled file in a Hugo site, and minimizing future edits to it
reduces merge conflicts and regression risk.

**Body classes:** `min-h-screen bg-gray-100 font-serif text-gray-900` — full
viewport height, light gray background, Noto Serif as the default body font.
The `font-serif` utility maps to our custom `--font-serif` theme token.

### 2.4 Header: Fixed Position + Alpine.js Mobile Menu

**File:** `layouts/partials/header.html` (70 lines)

**Design decisions:**

- **Fixed header** (`fixed top-0 z-50 w-full`) with `pt-16` on `<main>` to
  compensate. The existing OFReport.com uses a fixed header, so this
  preserves the familiar UX.
- **Alpine.js for mobile menu** rather than pure CSS `:checked` hack or
  separate Stimulus. Alpine keeps the interactivity declarative and inline —
  `x-data="{ mobileMenuOpen: false }"` on the `<header>`, `@click` on the
  burger, `x-show` with transitions on the dropdown. No separate JS file
  needed.
- **`x-cloak` for FOUC prevention** — Alpine content is hidden via
  `[x-cloak] { display: none !important; }` in main.css until Alpine
  initializes. Without this, you'd briefly see both the hamburger and close
  icons.
- **`@click.outside`** closes the mobile menu when tapping elsewhere —
  standard mobile UX pattern.
- **Active page highlighting** uses Hugo's `.IsMenuCurrent` to apply
  `text-blue-900` (desktop) or `bg-blue-50 text-blue-900` (mobile) to the
  current page's nav link.

**Breakpoint:** `lg:` (1024px) for the mobile/desktop switch. The header has 7
menu items, which gets crowded at the `md` breakpoint on some devices.

**Logo:** SVG loaded via `resources.Get "img/ofr-logo.svg"` and rendered as an
`<img>` tag rather than inlined. This allows the browser to cache the SVG
separately. The SVG was optimized (cleaned up from the original) — see commit
`cbdaef6`.

### 2.5 Footer: Bible Verse + 3-Column Links + Social Icons

**File:** `layouts/partials/footer.html` (103 lines)

The footer has four visual sections stacked vertically:

1. **Bible verse banner** — 1 Thessalonians 2:4 in Mate SC font (`font-fancy`),
   centered on dark blue background
2. **3-column link grid** — driven by three Hugo menus (`footer_col1`,
   `footer_col2`, `footer_col3`) defined in `hugo.toml:87-147`
3. **Social icons** — Facebook, Twitter/X, GitHub as inline SVGs with
   hover effects
4. **Copyright bar** — `© 2003–{{ now.Year }}` on darkest blue

**Why three separate menus instead of one?** Hugo menus don't support
column/group assignments natively. Using three menus (`footer_col1`,
`footer_col2`, `footer_col3`) with separate `{{ range }}` blocks is the
cleanest approach — each column is independently configurable in `hugo.toml`.
The alternative (one menu with `.Params.column`) adds conditional logic to the
template and makes the config harder to scan.

**External link handling:** Column 3 items have `[menus.footer_col3.params]
external = true`, which triggers `target="_blank" rel="noopener noreferrer"`.
Internal links in columns 1–2 use `pageRef` for Hugo's built-in page
resolution.

**Social icons as inline SVGs:** Yes, they're verbose (~6 lines each), but
they're colored via Tailwind (`fill-current text-blue-footer hover:text-blue-50`)
which wouldn't work with `<img>` tags. Only 3 icons, so the extra markup is
a reasonable tradeoff vs. adding an icon font dependency.

### 2.6 Head Partial: Fonts, Favicons, RSS Discovery

**File:** `layouts/partials/head.html` (31 lines)

- **Google Fonts** — Lato (headings), Noto Serif (body), Mate SC (decorative).
  Loaded via `preconnect` + single CSS link. These match the existing
  OFReport.com typography.
- **Favicon suite** — Full set generated for all platforms (apple-touch-icon,
  Android Chrome, Safari pinned tab, browserconfig.xml, webmanifest). Files
  live in `static/`.
- **RSS autodiscovery** — `<link rel="alternate" type="application/rss+xml">`
  using Hugo's output format system. This ensures feed readers find
  `/feed.xml` (custom basename for Mailchimp compatibility, configured in
  `hugo.toml:22-23`).

**Title logic:** Homepage shows just `titleSuffix` ("Joshua and Kelsie Steele —
Missionaries serving Christ in Ukraine"); all other pages show
`{{ .Title }} | {{ titleSuffix }}`. This matches the existing site's SEO
pattern.

### 2.7 Menu Configuration in hugo.toml

All navigation is centralized in `hugo.toml:57-147` using Hugo's menu system.
Four menus total:

| Menu | Items | Used by |
|------|-------|---------|
| `main` | 7 items (Family through Donate) | header.html |
| `footer_col1` | 4 items | footer.html column 1 |
| `footer_col2` | 4 items | footer.html column 2 |
| `footer_col3` | 4 items (all external) | footer.html column 3 |

This means adding/reordering nav items is a config-only change — no template
edits needed.

### 2.8 CI Pipeline

**File:** `.github/workflows/ci.yml` (48 lines)

Two parallel jobs:

1. **Hugo Build** — `npm ci` + `hugo --gc --minify`. If the site doesn't
   build, the PR is blocked.
2. **Markdown Lint** — `markdownlint-cli2` checking all `.md` files. Catches
   formatting issues in PRD docs and future content.

**Concurrency control:** `cancel-in-progress: true` grouped by workflow+ref,
so rapid pushes to a PR branch don't queue up stale builds.

**Hugo version pinned** to `0.155.2` in CI (via `peaceiris/actions-hugo@v3`).
Local is `0.155.3` (Homebrew) — minor patch difference, both work fine.

### 2.9 PRD Modularization

The original monolithic PRD was split into 8 documents:

```text
docs/prd/
├── 00-overview.md
├── 01-architecture.md
├── 02-design.md
├── 03-site-structure.md
├── 04-templates.md
├── 05-shortcodes.md
├── 06-content-migration.md
├── 07-deployment.md
├── 08-risks-and-future.md
├── appendix.md
└── ROADMAP.md
```

This was a documentation-only change (PR #13) but it matters for maintainability.
Each phase can now reference a specific document rather than scrolling through a
single massive file.

---

## 3. Test Coverage & Quality

### What We Have

This is a Hugo static site, so there's no traditional test suite (no unit
tests, no integration tests). Quality assurance is:

1. **Hugo production build** — `hugo --gc --minify` succeeds with zero
   warnings:

   ```text
   Pages: 7 | Static files: 10 | Total: 251ms
   ```

2. **Markdown lint** — `npm run lint:md` passes with 0 errors across 18
   files.

3. **CI gates** — Both checks run on every PR, blocking merge on failure.

### What's Intentionally Not Tested

- **Visual regression** — No screenshot comparison or end-to-end tests. At
  this stage the site has minimal content (a homepage with one paragraph).
  Visual testing becomes valuable in Phase 4+ when blog listings and article
  pages have real structure to validate.
- **Accessibility audit** — The templates use semantic HTML, ARIA labels on
  the mobile menu button, `aria-hidden="true"` on decorative SVGs, and
  `alt` text on the logo. But there's no automated axe/Lighthouse CI check
  yet.
- **Link checking** — Internal links point to pages that don't exist yet
  (e.g., `/family/`, `/ministry/`). This is expected — those content pages
  are Phase 8.

### Recommendations for Later

- **Add Lighthouse CI** in Phase 10 (SEO) or Phase 16 (Deployment) to catch
  performance/accessibility regressions.
- **Consider htmltest** for link validation once content is migrated (Phase
  15).

### Verify It Yourself

```bash
# Production build (should succeed with 0 warnings)
hugo --gc --minify

# Markdown lint (should show 0 errors)
npm run lint:md

# Dev server (starts on http://localhost:1313/)
hugo server -D
```

---

## 4. Product Tour — Try It Yourself

### Prerequisites

```bash
cd /Users/joshukraine/code/ofreport-hugo-rebuild/ofreport.com-hugo
npm install    # if not done already
hugo server -D
```

The dev server starts at **http://localhost:1313/**.

---

### Story 1: View the Homepage

1. Open **http://localhost:1313/** in your browser.
2. You should see:
   - **Fixed header** at the top with the OFReport logo on the left and 7
     navigation links on the right (Family, Ministry, Blog, Podcast,
     Archives, Contact, Donate).
   - **Main content area** with an `<h1>` "OFReport.com" and one paragraph
     of welcome text. This is the placeholder — Phase 4 will replace this
     with the blog listing.
   - **Footer** with dark blue background containing:
     - Bible verse in decorative Mate SC font
     - 3-column link grid
     - Social icons (Facebook, Twitter, GitHub)
     - Copyright bar at the very bottom
3. **Check typography:** The body text should be in Noto Serif (serif font).
   The navigation links and the heading should be in Lato (bold, uppercase,
   tracked wide). The Bible verse should be in Mate SC (small caps serif).
4. **Scroll the page** — the header should remain fixed at the top.

---

### Story 2: Test Responsive Navigation

1. On the homepage, **resize your browser** to below 1024px wide (or use
   DevTools responsive mode to simulate a mobile device).
2. The 7 navigation links should disappear, replaced by a **hamburger icon**
   (three horizontal lines) on the right side of the header.
3. **Click the hamburger.** A dropdown panel should slide down with all 7
   navigation links stacked vertically. The hamburger icon changes to an
   **X** (close icon).
4. **Click the X** or **click outside** the menu — the dropdown should
   slide back up with a smooth transition.
5. **Try both transitions:** Opening should feel like a quick ease-out (200ms),
   closing should be slightly faster (150ms ease-in). The menu should also
   translate vertically (slight upward slide on close).

---

### Story 3: Inspect the Footer

1. Scroll to the bottom of the page.
2. **Bible verse section:** Centered text in Mate SC font reading "But as we
   were allowed of God to be put in trust with the gospel..." with the
   reference "1 Thessalonians 2:4" kept on one line via `whitespace-nowrap`.
3. **Link grid:** Three columns of 4 links each. The first two columns are
   internal site links; the third column is external links (ETO, Bible
   First, CMO, kelsie.me).
4. **External links:** Right-click one of the column 3 links and inspect it —
   it should have `target="_blank"` and `rel="noopener noreferrer"`.
   Internal links in columns 1–2 should NOT have these attributes.
5. **Social icons:** Three circular-ish icons in a row — Facebook, Twitter,
   GitHub. Hover over each one — they should transition from the muted blue
   (`blue-footer`) to near-white (`blue-50`).
6. **Copyright:** At the very bottom, dark blue bar with "© 2003–2026 Joshua
   and Kelsie Steele". The year should be the current year (dynamically
   generated by Hugo's `{{ now.Year }}`).

---

### Story 4: Verify the Build Pipeline

1. **Open DevTools** → Sources (or Network) tab.
2. Look for the CSS file being loaded. In dev mode, it should be a plain
   `<link>` tag without integrity attributes.
3. **Check that Tailwind classes are working:** Inspect the `<body>` — it
   should have classes `min-h-screen bg-gray-100 font-serif text-gray-900`
   and those styles should be applied.
4. **Run a production build in terminal:**

   ```bash
   hugo --gc --minify
   ```

   Then inspect `public/` — the CSS file should have a fingerprinted filename
   (hash in the URL) and the `<link>` tag in the HTML should include
   `integrity="sha256-..."`.

---

### Story 5: View Page Source / Head Contents

1. On the homepage, **View Source** (Cmd+Option+U).
2. Check the `<head>`:
   - `<title>` should be just "Joshua and Kelsie Steele — Missionaries
     serving Christ in Ukraine" (homepage uses only the suffix).
   - `<meta name="description">` should have the site description.
   - Google Fonts preconnect links should appear.
   - Favicon links (apple-touch-icon, 32x32, 16x16, webmanifest, etc.)
     should all be present.
   - RSS autodiscovery `<link rel="alternate" type="application/rss+xml">`
     should point to `/feed.xml`.
3. **Navigate to a non-homepage URL** — the blog section at
   http://localhost:1313/blog/ — and view source again. The `<title>` should
   now be "Blog | Joshua and Kelsie Steele — Missionaries serving Christ in
   Ukraine".

---

### Story 6: Check Navigation Active State

1. Visit **http://localhost:1313/blog/**.
2. In the desktop header, the "Blog" link should appear in darker blue
   (`text-blue-900`) while other links are gray (`text-gray-600`).
3. On mobile, open the hamburger — the "Blog" link should have a light blue
   background (`bg-blue-50`) to indicate it's the active page.
4. Navigate to the homepage — no nav link should be highlighted (the
   homepage isn't in the main menu).

---

## Follow-Up Items

These are things I noticed during this review that are worth flagging:

1. **Issue #11 is still open** — "footer minor improvements (Twitter/X icon,
   GitHub URL)". The footer currently uses the old Twitter circular icon, not
   the X rebrand. The GitHub URL points to the old repo. This is a known
   minor issue tracked for cleanup.

2. **Hugo version mismatch** — Local is 0.155.3, CI pins 0.155.2. Not a
   problem today, but worth aligning eventually. Consider using
   `.hugo-version` or `netlify.toml` as the single source of truth.

3. **ROADMAP.md checkboxes are all unchecked** — Even though Phases 1–3 are
   complete, the roadmap items haven't been checked off. This is a minor doc
   sync issue worth cleaning up.

4. **`_default/list.html` is a placeholder** — It works for the homepage and
   blog index, but it's intentionally minimal. Phase 4 will replace it with
   the real blog listing template. Worth noting so it's not forgotten.

5. **Alpine.js loaded via CDN** — Currently using
   `cdn.jsdelivr.net/npm/alpinejs@3`. The `package.json` also lists
   `alpinejs` as a devDependency, suggesting a potential future move to
   bundling it locally via Hugo's js.Build. For now the CDN approach is fine
   and simpler.

# OFReport.com Hugo Rebuild — Roadmap

This document tracks implementation progress across build phases. Each item
links to the relevant PRD document for full requirements.

**Progress key:** `[ ]` Not started · `[~]` In progress · `[x]` Complete · `[—]` Deferred / descoped

## Phase Overview

| Phase | Name | Dependencies | Status |
| ----- | ---- | ------------ | ------ |
| 1 | Project Scaffolding & Configuration | — | Complete |
| 2 | Tailwind CSS v4 Integration | Phase 1 | Complete |
| 3 | Base Layout & Navigation | Phase 2 | Complete |
| 4 | Blog Listing with Pagination | Phase 3 | Complete |
| 5 | Single Article Template | Phase 3 | Complete |
| 6 | Shortcodes | Phase 5 | Complete |
| 7 | Tag Taxonomy | Phase 4 | Complete |
| 8 | Static Pages | Phase 3 | Complete |
| 9 | RSS Feed | Phase 5 | Complete |
| 10 | SEO & Meta Tags | Phase 3 | Complete |
| 11 | Contact Form (Netlify Forms) | Phase 8 | Complete |
| 12 | Newsletter Integration | Phase 3 | Complete |
| 13 | Lightbox Integration | Phase 6 | In progress |
| 14 | Analytics | Phase 3 | Not started |
| 15 | Content Migration | Phase 6 | Not started |
| 16 | Deployment | Phase 15 | Not started |

---

## Phase 1: Project Scaffolding & Configuration

- [x] Hugo project initialized (`hugo new site`)
- [x] `hugo.toml` configured (see [`03-site-structure.md`](./03-site-structure.md))
- [x] Content directory structure created (see [`03-site-structure.md`](./03-site-structure.md))
- [x] `package.json` with npm dependencies
- [x] `.gitignore` configured (see [`07-deployment.md`](./07-deployment.md))
- [x] Git repo initialized and first commit

**Key learning:** Hugo project structure, `hugo.toml` config, content organization

## Phase 2: Tailwind CSS v4 Integration

- [x] Tailwind CSS v4 installed and configured (see [`01-architecture.md`](./01-architecture.md))
- [x] `assets/css/main.css` entry point created
- [x] `partials/css.html` with `css.TailwindCSS` pipeline
- [x] `buildStats` and cache busters in `hugo.toml`
- [x] Verified: Tailwind classes render in dev server

**Key learning:** `css.TailwindCSS`, Hugo asset pipeline, `buildStats`

## Phase 3: Base Layout & Navigation

- [x] `baseof.html` base template (see [`04-templates.md`](./04-templates.md))
- [x] `partials/head.html` — meta, CSS, favicons
- [x] `partials/header.html` — site header with Alpine.js mobile menu (see [`01-architecture.md`](./01-architecture.md))
- [x] `partials/footer.html` — footer with links, social icons, copyright
- [x] Alpine.js loaded and functional

**Key learning:** Go templates, partials, base template inheritance

## Phase 4: Blog Listing with Pagination

- [x] `blog/list.html` — featured article + grid layout (see [`04-templates.md`](./04-templates.md))
- [x] `partials/article-card.html` — preview card component
- [x] `partials/pagination.html` — pagination navigation
- [x] Page 1 vs. page 2+ behavior working
- [x] Pagination URLs: `/blog/`, `/blog/page/2/`, etc.

**Key learning:** Hugo's pagination system, list templates, `range`/`where` functions

## Phase 5: Single Article Template

- [x] `blog/single.html` — full article page (see [`04-templates.md`](./04-templates.md))
- [x] Cover image with Cloudinary optimization
- [x] Meta line: author, date, reading time (see [`08-risks-and-future.md`](./08-risks-and-future.md))
- [x] Tag badges linked to tag pages
- [x] Previous/next article navigation
- [x] `partials/cloudinary-url.html` — URL builder (see [`01-architecture.md`](./01-architecture.md))

**Key learning:** Single page templates, frontmatter access, date formatting

## Phase 6: Shortcodes

- [x] `figure.html` — image with caption + lightbox (see [`05-shortcodes.md`](./05-shortcodes.md))
- [x] `callout.html` — highlighted box with optional CTA
- [x] `button.html` — styled CTA link
- [x] `svg.html` — inline SVG from assets
- [x] All shortcodes tested with sample content

**Key learning:** Custom shortcodes for images, callouts, buttons

## Phase 7: Tag Taxonomy

- [x] `taxonomy/taxonomy.html` — all tags listing with article counts
- [x] `taxonomy/term.html` — articles filtered by tag with pagination
- [x] Tag badges link to tag pages
- [x] Tag URLs: `/tags/`, `/tags/{tag}/`, `/tags/{tag}/page/2/`

**Key learning:** Hugo taxonomies, taxonomy list/term templates

## Phase 8: Static Pages

- [x] Family page (`/family/`)
- [x] Ministry page (`/ministry/`) with SVG logos
- [x] Podcast page (`/podcast/`) with Buzzsprout embed
- [x] Archives page (`/archives/`) using `data/archives.json`
- [x] Donate page (`/donate/`)
- [x] Subscribe page (`/subscribe/`) with Mailchimp form

**Key learning:** Content sections, page-specific templates

## Phase 9: RSS Feed

- [x] Custom RSS template at `/feed.xml` (see [`01-architecture.md`](./01-architecture.md))
- [x] Cover images with Cloudinary transformations (cover `<enclosure>`, `w_560` rss preset)
- [x] Curated excerpt in feed items (excerpt model, not full HTML — see [`CHANGELOG.md`](./CHANGELOG.md), 2026-06-06)
- [—] Mailchimp compatibility verified (deferred — needs a live, publicly-pollable feed; verify during Phase 16 deploy)

**Key learning:** Custom RSS template, Hugo output formats

## Phase 10: SEO & Meta Tags

- [x] `partials/seo.html` — Open Graph, Twitter Cards (see [`04-templates.md`](./04-templates.md))
- [x] Title template with suffix
- [x] Canonical URLs
- [x] Robots meta (production vs. non-production) — `seo.html` logic + Netlify per-context env wiring (preview/branch deploys render noindex)
- [x] Sitemap at `/sitemap.xml` — verified Hugo's default output; no custom template needed
- [x] Favicons (apple-touch-icon, Android Chrome, Safari pinned tab)

**Key learning:** Head partial, Open Graph, Twitter Cards, sitemap

## Phase 11: Contact Form (Netlify Forms)

- [x] `partials/contact-form.html` (see [`01-architecture.md`](./01-architecture.md))
- [x] Contact page (`/contact/`)
- [x] Thank-you page (`/thank-you/`)
- [x] Honeypot spam prevention
- [x] Form submission tested on Netlify

**Key learning:** Static form handling, Netlify integration

## Phase 12: Newsletter Integration

- [x] `partials/mailchimp-form.html` (see [`01-architecture.md`](./01-architecture.md))
- [x] Form placed on homepage, article footer, `/subscribe/` page
- [x] Styled with Tailwind to match site design

**Key learning:** Mailchimp embedded forms

## Phase 13: Lightbox Integration

- [x] GLightbox CSS/JS loaded (see [`01-architecture.md`](./01-architecture.md))
- [x] `partials/glightbox.html` — conditional loading on article pages
- [x] Figure shortcode outputs lightbox-compatible HTML
- [x] Tested with actual Cloudinary images
- [ ] Article cover image is lightbox-enabled (cover joins the figure gallery — #109)

**Key learning:** GLightbox setup, shortcode enhancement

## Phase 14: Analytics

- [ ] `partials/analytics.html` — swappable analytics partial (see [`01-architecture.md`](./01-architecture.md))
- [ ] Conditional loading (production only)
- [ ] Analytics tool selected and configured

**Key learning:** Privacy-friendly analytics partial

## Phase 15: Content Migration

- [ ] Ruby migration script written (see [`06-content-migration.md`](./06-content-migration.md))
- [ ] All 219 articles converted
- [ ] Frontmatter transformed (preview → description, slug added, etc.)
- [ ] Vue components converted to Hugo shortcodes
- [ ] Duplicate tag consolidated (`good-and-evil`)
- [ ] Validation pass: no remaining `<article-` patterns
- [ ] Legacy WordPress articles reviewed and fixed
- [ ] Static pages created
- [ ] Data files migrated (`authors.json`, `archives.json`)

**Key learning:** Migration scripting, validation, content testing

## Phase 16: Deployment

- [ ] `netlify.toml` configured (see [`07-deployment.md`](./07-deployment.md))
- [ ] Redirects for SEO continuity
- [ ] Security headers
- [ ] Deploy preview tested
- [ ] Production deployment
- [ ] DNS/domain verified (no changes needed)
- [ ] Lighthouse audit passed
- [ ] Old repo archived

**Key learning:** Netlify configuration, redirects, final testing

---

## Future / Unscheduled

Items that are out of scope for the initial rebuild but may be added later
(see [`08-risks-and-future.md`](./08-risks-and-future.md)):

- Comments system (Disqus, giscus, etc.)
- Dark mode
- Multilingual content
- CMS integration (Decap CMS)
- Image migration to local (Hugo page bundles)
- Client-side search (Pagefind)

> **Adding new features:** Create a new numbered PRD document (e.g.,
> `09-search.md`) and add an entry here under the appropriate phase or
> under Future.

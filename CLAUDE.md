# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OFReport.com is a missionary family blog (Joshua and Kelsie Steele) being rebuilt from Nuxt.js 2 to Hugo. The site has 219 blog articles spanning 2008–2025, 5+ static pages, and 26 tags. Full requirements are in the `docs/prd/` directory (start with `README.md`; see `ROADMAP.md` for build phases).

## Development Approach

This project follows **developer-directed, AI-assisted** development. The developer (Joshua) directs all decisions and seeks to understand each step. **Explain Hugo concepts and rationale before generating code.** Present options with trade-offs and let the developer choose. See `docs/prd/00-overview.md` for details.

## Development Workflow

All work flows through GitHub Issues. The full pipeline is:

1. **Plan**: When discussing new features or multi-step work, the output of planning
   should be one or more GitHub issues. Each issue needs a clear title, description,
   and acceptance criteria. Create the issues before starting implementation.
2. **Implement**: Use `/resolve-issue <number>` to implement each issue on a feature
   branch with a structured workflow.
3. **Pull Request**: Use `/create-pr --issue <number>` to open a PR linking to the
   resolved issue.
4. **Merge**: PRs should pass build verification (`hugo --gc --minify`) before merging.

Additional conventions:

- Commit messages use Conventional Commits format but do NOT reference issue numbers.
  Issue linking happens in the PR description via "Closes #N".
- Small, unrelated housekeeping changes (typos, README updates) can be committed
  directly to main without an issue or PR.

## Build Commands

```bash
# Dev server (with live reload and drafts)
hugo server -D

# Production build
hugo --gc --minify

# Install npm dependencies (Tailwind CSS, Alpine.js)
npm install

# Create new blog post
hugo new content blog/YYYY-MM-DD-slug-title.md
```

## Tech Stack

- **Hugo** static site generator with Go templates
- **Tailwind CSS v4** via Hugo's built-in `css.TailwindCSS` pipe (not PostCSS)
- **Alpine.js** for minimal interactivity (mobile menu, dropdowns)
- **Cloudinary** for all image hosting/transforms (cloud name: `dnkvsijzu`)
- **GLightbox** for image lightbox on article pages
- **Netlify** for hosting, forms, and deployment
- **Mailchimp** for newsletter signup (inline forms only)

## Architecture

### Content Model

- Blog articles live in `content/blog/` with YAML frontmatter
- Static pages (`family.md`, `ministry.md`, etc.) live in `content/` root
- Data files (`authors.json`, `archives.json`) in `data/`
- Tag taxonomy is the only taxonomy (`[taxonomies] tag = "tags"`)

### Article Frontmatter Schema

```yaml
---
title: "Article Title"
date: 2024-06-13
author: "Joshua Steele"
description: >-
  Plain text summary for listings and meta tags.
tags:
  - newsletter
  - ministry
cover: "https://res.cloudinary.com/dnkvsijzu/..."
caption: "Photo caption text"
pdf: "OFR-Jul-Aug-2025.pdf"
slug: "2024-06-13-original-slug"
---
```

### URL Structure (SEO-critical — do not change)

- Articles: `/blog/:slug/` (configured via `[permalinks] blog = "/blog/:slug/"`)
- Tags: `/tags/{tag}/` (Hugo default taxonomy URL)
- RSS: `/feed.xml` (custom baseName, required for Mailchimp compatibility)

### Template Hierarchy

- `layouts/_default/baseof.html` — base template with head, header, main block, footer
- `layouts/blog/list.html` — blog listing with featured first article + 2-column grid
- `layouts/blog/single.html` — article page with cover image, meta, content, prev/next nav
- `layouts/taxonomy/` — tag listing and individual tag pages
- `layouts/partials/` — reusable components (head, header, footer, css, seo, cloudinary-url, etc.)
- `layouts/shortcodes/` — figure (image+lightbox), callout, button, svg

### Tailwind CSS v4 Integration

Uses Hugo's `css.TailwindCSS` function with deferred template execution. Requires:

- `[build.buildStats]` enabled in `hugo.toml` for class purging
- `assets/css/main.css` as entry point with `@import "tailwindcss"` and `@source "hugo_stats.json"`
- `layouts/partials/css.html` partial with `templates.Defer` in the `<head>`
- npm packages: `tailwindcss` and `@tailwindcss/cli`

### Cloudinary Image Handling

All images are on Cloudinary — no local image processing. The `partials/cloudinary-url.html` partial constructs optimized URLs with context-specific transformations:

- Article display: `c_scale,f_auto,q_auto:best`
- OG/social: `c_fill,f_auto,h_630,q_auto,w_1200`
- RSS: `c_scale,f_auto,q_auto,w_560`
- Preview cards: `c_scale,f_auto,q_auto,w_740` (featured) / `w_610` (regular)

### Key Site Parameters (`hugo.toml [params]`)

- `cloudinaryBase` — `https://res.cloudinary.com/dnkvsijzu`
- `pdfBase` — `https://d21yo20tm8bmc2.cloudfront.net/ofr/` (newsletter PDFs on CloudFront)
- `titleSuffix` — appended to page titles for SEO

## Shortcodes

| Shortcode | Usage |
|-----------|-------|
| `figure`  | `{{</* figure src="..." caption="..." alt="..." */>}}` — Cloudinary image with GLightbox |
| `callout` | `{{</* callout pdf="file.pdf" */>}}Content{{</* /callout */>}}` — highlighted box with optional PDF link |
| `button`  | `{{</* button href="..." text="..." */>}}` — styled CTA link |
| `svg`     | `{{</* svg name="logo-name" */>}}` — inline SVG from `assets/img/` |

## Tailwind Plus Workflow

The developer has a Tailwind Plus subscription. Licensed snippets go in `docs/tailwind_plus/` (gitignored) as design references. Read snippets for design patterns and Tailwind class usage, then build Hugo templates using those patterns — never copy verbatim.

## Content Migration

A Ruby migration script will convert 219 articles from the Nuxt source repo. Key transformations:

- Vue components (`<article-image>`, `<article-callout>`, etc.) → Hugo shortcodes
- `preview` frontmatter → `description` (markdown stripped)
- Tag `good and evil` → `good-and-evil`
- Add explicit `slug` field from filename

## Deployment

Netlify config in `netlify.toml`. Build command: `npm install && hugo --gc --minify`. Hugo version pinned in the Netlify environment config.

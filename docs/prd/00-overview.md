# OFReport.com — Hugo Rebuild: Project Overview

**Version:** 1.1
**Date:** February 8, 2026
**Author:** Joshua Steele (with Claude AI assistance)
**Source Reference:** [Hugo Migration Brief](../hugo-migration-brief.md)

---

## Purpose

Rebuild [OFReport.com](https://ofreport.com), a missionary family blog
documenting 17 years of ministry work in Ukraine, from Nuxt.js 2 to Hugo. The
site has 219 blog articles, 5 static pages, and 26 tags spanning October 2008
to August 2025.

---

## Goals

- **Preserve all existing content** — 219 articles, static pages, PDFs, images,
  and PDF newsletter archives
- **Preserve key URL structures** for SEO continuity (`/blog/{slug}/`,
  `/tags/{tag}/`)
- **Embrace Hugo idioms** — build the site in whatever way is natural for Hugo,
  not as a port of the Nuxt architecture
- **Simplify** — reduce JavaScript dependency and overall complexity
- **Use modern tooling** — Tailwind CSS v4, privacy-friendly analytics, current
  best practices
- **Refresh the design** — preserve the general identity and structure while
  improving spacing, typography, and visual polish
- **Enable learning** — the developer should understand every file and concept
  in the finished site (see Development Approach below)

---

## Non-Goals

- Line-by-line replication of the Nuxt site's code or architecture
- Adding a CMS or admin interface
- Multilingual support (may be added later; Hugo supports it natively)
- Complete visual redesign (refresh, not revolution)

---

## Development Approach

### Developer-Directed, AI-Assisted

This project uses Claude Code as a development tool, but the developer (Joshua)
directs all decisions and seeks to understand each step. The philosophy is
**learning-focused pair programming**, not autonomous code generation.

**Principles:**

- **Explain before building.** Claude Code should explain Hugo concepts, Go
  template syntax, and architectural rationale before generating code. The
  developer should understand _why_ something is built a certain way.
- **Incremental progress.** Build one feature or template at a time. Verify
  understanding before moving to the next step.
- **No black boxes.** Every file in the project should be understood by the
  developer. If something is unclear, pause and explain.
- **Developer makes decisions.** When there are multiple valid approaches, Claude
  Code presents options with trade-offs and lets the developer choose.
- **Teach Hugo idioms.** Use this project as an opportunity to learn Hugo's
  content model, templating system, taxonomy features, and build pipeline.

### Tailwind Plus Workflow

The developer has a Tailwind Plus (UI Components) subscription. Licensed
component snippets are used as design references, not copied verbatim into the
codebase.

**Workflow:**

1. A `docs/tailwind_plus/` directory exists in the project root (gitignored)
2. When building a UI element (e.g., navigation, article cards, footer), Claude
   Code may request a reference snippet from Tailwind Plus
3. The developer pastes the relevant Tailwind Plus example into an HTML file in
   `docs/tailwind_plus/` (e.g., `docs/tailwind_plus/navbar-example.html`)
4. Claude Code reads the snippet to understand the design patterns, spacing,
   and Tailwind class usage
5. Claude Code then builds the actual Hugo template (in Go template syntax)
   using those patterns as a reference — not a direct copy

**Important:** The `docs/tailwind_plus/` directory must be listed in
`.gitignore` since Tailwind Plus components are licensed and must not be
committed to the repository.

---

## PRD Structure

This PRD is split across multiple files for easier navigation:

| File                                                   | Focus                                           |
| ------------------------------------------------------ | ----------------------------------------------- |
| `00-overview.md`                                       | Project goals, development approach (this file) |
| [`01-architecture.md`](./01-architecture.md)           | Architectural decisions                         |
| [`02-design.md`](./02-design.md)                       | Design philosophy and visual identity           |
| [`03-site-structure.md`](./03-site-structure.md)       | Content organization, URLs, Hugo configuration  |
| [`04-templates.md`](./04-templates.md)                 | Layout and template specifications              |
| [`05-shortcodes.md`](./05-shortcodes.md)               | Hugo shortcode specifications                   |
| [`06-content-migration.md`](./06-content-migration.md) | Migration script, legacy articles, checklist    |
| [`07-deployment.md`](./07-deployment.md)               | Source control, Netlify config, deployment      |
| [`08-risks-and-future.md`](./08-risks-and-future.md)   | New features, risks, out-of-scope items         |
| [`ROADMAP.md`](./ROADMAP.md)                           | Build phases and progress tracking              |
| [`appendix.md`](./appendix.md)                         | Reference links and existing data files         |

The [Hugo Migration Brief](../hugo-migration-brief.md) documents the existing
Nuxt site and serves as a reference for understanding the current content,
features, and user experience.

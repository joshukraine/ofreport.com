# OFReport.com Hugo Rebuild — Product Requirements Document

This directory contains the modular PRD for the OFReport.com Hugo rebuild. Each file is a self-contained specification that can be referenced independently during implementation.

The [Hugo Migration Brief](../hugo-migration-brief.md) documents the existing Nuxt site and serves as a reference for understanding the current content, features, and user experience.

## How to Use This PRD

**For Claude Code / AI-assisted implementation:** Reference the specific PRD section relevant to your current task. Start here to find the right file, then consult the referenced section for requirements.

**For human reviewers:** Read `00-overview.md` for context, then dive into the feature spec that matters to you.

## File Index

| File | Contents | Consult When... |
| --- | --- | --- |
| `CHANGELOG.md` | Material deviations from the PRD discovered during implementation | Recording or reviewing a "never silently deviate" decision |
| `ROADMAP.md` | Build phases and progress tracking | Planning a phase, checking what's next, marking work complete |
| `00-overview.md` | Project goals, non-goals, development approach | Onboarding to the project, understanding scope and the AI-assisted workflow |
| `01-architecture.md` | Architectural decisions (Tailwind pipeline, Cloudinary, RSS, forms) | Wiring up the asset pipeline, image handling, or an integration |
| `02-design.md` | Design philosophy and visual identity | Making styling, typography, or layout decisions |
| `03-site-structure.md` | Content organization, URL structure, Hugo configuration | Adding content types, touching `hugo.toml`, or changing URLs |
| `04-templates.md` | Layout and template specifications | Building or editing a layout, partial, or list/single template |
| `05-shortcodes.md` | Hugo shortcode specifications | Implementing or changing a shortcode (figure, callout, button, svg) |
| `06-content-migration.md` | Migration script, legacy articles, validation checklist | Migrating the 219 Nuxt articles or debugging converted content |
| `07-deployment.md` | Source control, Netlify config, deployment | Configuring Netlify, redirects, headers, or the production deploy |
| `08-risks-and-future.md` | New features, risks, out-of-scope items | Scoping a future enhancement or weighing a known risk |
| `appendix.md` | Reference links and existing data files | Looking up a source reference or data file detail |

## Conventions

- **"MUST", "SHALL", "REQUIRED"** — non-negotiable for MVP launch.
- **"SHOULD"** — expected for MVP unless a specific technical constraint prevents it.
- **"MAY"** — nice to have; implement if straightforward, otherwise defer.
- **"TBD"** — explicitly unresolved; document with context and resolution guidance.
- **Cross-references** use the format `→ See 04-templates.md §3 "Section Heading"` to point to other PRD sections — always include the filename and quoted heading. (Existing files also use inline Markdown links; new cross-references should follow the `→ See` form.)

### Numbering divergence

This PRD numbers files from `00-` and phases from Phase 1, rather than the current workflow template's `01-` files and Phase 0 foundation. This is an intentional divergence retained from the project's original structure — renumbering would churn every cross-reference and debrief for no functional gain. New files and phases continue the existing sequence.

![OFReport.com][screenshot]

# OFReport.com (Hugo Rebuild)

[![Netlify Status](https://api.netlify.com/api/v1/badges/69a46dc9-827c-4b08-8b75-0164feb31dce/deploy-status)](https://app.netlify.com/projects/ofreport/deploys)

A missionary family blog by Joshua and Kelsie Steele, documenting 25 years of ministry work in Ukraine. The site was rebuilt from Nuxt.js 2 to [Hugo](https://gohugo.io/) in 2026 and is live at **[ofreport.com](https://ofreport.com)**.

> [!NOTE]
> Looking for the previous version? The original **Nuxt.js 2** site lives in [joshukraine/ofreport.com-nuxt](https://github.com/joshukraine/ofreport.com-nuxt) (archived, read-only).

## Tech Stack

- **Hugo** - Static site generator with Go templates
- **Tailwind CSS v4** - Utility-first CSS via Hugo's built-in `css.TailwindCSS`
- **Alpine.js** - Lightweight JS for mobile menu and dropdowns
- **GLightbox** - Lightbox for article images
- **Cloudinary** - Image hosting and transformation (no local images)
- **Mailchimp** - Newsletter signup (inline forms)
- **Umami** - Cookieless, privacy-focused analytics
- **Netlify** - Hosting, forms, and deployment

## Getting Started

```bash
# Install dependencies
npm install

# Run dev server (with drafts)
hugo server -D

# Production build
hugo --gc --minify
```

Requires [Hugo](https://gohugo.io/installation/) (extended edition) and [Node.js](https://nodejs.org/) 20 or newer (production builds run on Node 22).

## Project Structure

```text
content/          # Markdown content (blog posts, static pages)
layouts/          # Go templates (base, partials, shortcodes)
assets/css/       # Tailwind CSS entry point
assets/img/       # Site images (logo SVG)
static/           # Favicons, webmanifest, browserconfig
data/             # Structured data files (authors, archives)
docs/             # PRD and project documentation
```

## Documentation

Project documentation lives in [`docs/`](docs/):

- **[Product requirements (PRD)](docs/prd/)** — full requirements and phase-by-phase build history (start with [`00-overview.md`](docs/prd/00-overview.md); [`ROADMAP.md`](docs/prd/ROADMAP.md) tracks the build phases)
- **Quality & launch checks** — repeatable verification procedures:
  - [Lighthouse audit](docs/lighthouse-check.md) — performance & accessibility
  - [Link check](docs/link-check.md) — broken-link sweep
  - [OG / social card check](docs/og-check.md) — Open Graph / social preview verification
  - [Integrations check](docs/integrations-check.md) — third-party launch integrations
- **[URL parity audit](docs/url-parity/report.md)** — Nuxt → Hugo redirect and URL verification
- **[Hugo learning notes](docs/hugo-learning/)** — annotated notes captured during the build

## Status

The Hugo rebuild is **complete** — OFReport.com went live on the new codebase in June 2026.

## License

The source code in this repository is licensed under the [MIT License](LICENSE).

Site **content** — blog articles, photographs, and other written material — is copyright © 2001–2026 Joshua and Kelsie Steele. All rights reserved, and may not be reused without permission.

[screenshot]: https://res.cloudinary.com/dnkvsijzu/image/upload/bo_1px_solid_rgb:e2e8f0,c_scale,f_auto,q_auto,w_1000/v1782237895/screenshots/ofreport.com-hugo-2026_vtr69j.png

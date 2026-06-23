# OFReport.com (Hugo Rebuild)

A missionary family blog by Joshua and Kelsie Steele, documenting 17 years of
ministry work in Ukraine. This is a ground-up rebuild from Nuxt.js 2 to
[Hugo](https://gohugo.io/).

The site includes 223 blog articles (2008-2026), 5 static pages, and 26 tags.

> [!NOTE]
> Looking for the previous version? The original **Nuxt.js 2** site lives in
> [joshukraine/ofreport.com-nuxt](https://github.com/joshukraine/ofreport.com-nuxt)
> (archived, read-only).

## Tech Stack

- **Hugo** - Static site generator with Go templates
- **Tailwind CSS v4** - Utility-first CSS via Hugo's built-in `css.TailwindCSS`
- **Alpine.js** - Lightweight JS for mobile menu and dropdowns
- **Cloudinary** - Image hosting and transformation (no local images)
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

Requires [Hugo](https://gohugo.io/installation/) (extended edition) and
[Node.js](https://nodejs.org/) 22 LTS.

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

## Status

The Hugo rebuild is **complete** — OFReport.com went live on the new codebase in June 2026.

Full requirements and the phase-by-phase build history are in the [`docs/prd/`](docs/prd/) directory (start with [`00-overview.md`](docs/prd/00-overview.md); see [`ROADMAP.md`](docs/prd/ROADMAP.md) for build phases).

## License

Content is copyright Joshua and Kelsie Steele. All rights reserved.

# Site Structure

---

## Content Organization

```text
ofreport.com/
├── archetypes/
│   └── blog.md                  # Template for new blog posts
├── assets/
│   ├── css/
│   │   └── main.css             # Tailwind CSS entry point
│   └── img/                     # SVGs and other asset images
├── content/
│   ├── blog/                    # Blog articles (Hugo section)
│   │   ├── _index.md            # Blog listing page config
│   │   ├── 2008-10-01-slug.md
│   │   ├── ...
│   │   └── 2025-08-01-slug.md
│   ├── family.md                # Static page
│   ├── ministry.md              # Static page
│   ├── podcast.md               # Static page
│   ├── archives.md              # PDF archive page
│   ├── donate.md                # Donation page
│   ├── contact.md               # Contact form page
│   ├── subscribe.md             # Newsletter signup page
│   └── thank-you.md             # Contact form success page
├── data/
│   └── archives.json            # PDF archive listing by year
├── docs/
│   └── tailwind_plus/           # Tailwind Plus reference snippets (gitignored)
├── layouts/
│   ├── _default/
│   │   ├── baseof.html          # Base template
│   │   ├── list.html            # Default list template
│   │   ├── single.html          # Default single page template
│   │   └── rss.xml              # Custom RSS template
│   ├── blog/
│   │   ├── list.html            # Blog listing with pagination
│   │   └── single.html          # Individual article template
│   ├── partials/
│   │   ├── head.html            # <head> contents (meta, CSS, favicons)
│   │   ├── header.html          # Site header & navigation
│   │   ├── footer.html          # Site footer
│   │   ├── css.html             # Tailwind CSS processing
│   │   ├── article-card.html    # Blog listing card component
│   │   ├── pagination.html      # Pagination navigation
│   │   ├── cloudinary-url.html  # Cloudinary URL builder
│   │   ├── contact-form.html    # Netlify Forms contact form
│   │   ├── mailchimp-form.html  # Newsletter signup form
│   │   ├── analytics.html       # Analytics script (swappable)
│   │   ├── seo.html             # OG tags, Twitter cards, etc.
│   │   └── glightbox.html       # GLightbox CSS/JS/init
│   ├── shortcodes/
│   │   ├── figure.html          # Image with caption + lightbox
│   │   ├── callout.html         # Highlighted box with optional CTA
│   │   ├── button.html          # Styled CTA link
│   │   └── svg.html             # Inline SVG from assets
│   ├── taxonomy/
│   │   ├── taxonomy.html        # All tags listing page (taxonomy kind)
│   │   └── term.html            # Single tag page (articles with that tag)
│   └── 404.html                 # Custom 404 page
├── static/
│   ├── favicon.ico
│   ├── apple-touch-icon.png
│   └── img/                     # Static images (logos, etc.)
├── hugo.toml                    # Site configuration
├── netlify.toml                 # Netlify deployment config
├── package.json                 # npm dependencies (Tailwind, Alpine)
├── .gitignore                   # Includes docs/tailwind_plus/
└── README.md                    # Project documentation
```

---

## Content File Format (Articles)

After migration, article frontmatter will look like:

```yaml
---
title: "Article Title"
date: 2024-06-13
author: "Joshua Steele"
description: >-
  A brief summary of the article used for listings and meta tags.
  Plain text, no markdown.
tags:
  - newsletter
  - ministry
cover: "https://res.cloudinary.com/dnkvsijzu/..."
caption: "Photo caption text"
pdf: "OFR-Jul-Aug-2025.pdf"
slug: "2024-06-13-original-slug"
---
Article content with Hugo shortcodes...
```

**Key changes from current format:**

- `preview` → `description` (renamed, markdown stripped)
- `slug` added explicitly to preserve existing URL structure
- `basename` and `iso8601Date` fields removed (not needed in Hugo)
- Vue component syntax converted to Hugo shortcodes

---

## URL Structure

Hugo's default permalink for a content section is `/{section}/{filename}/`,
which naturally produces `/blog/2024-06-13-my-article/` — matching the current
URL structure. An explicit permalink configuration makes this guaranteed:

```toml
[permalinks]
  blog = "/blog/:slug/"
```

This causes **no friction with Hugo's conventions** — the existing URL structure
aligns with how Hugo works by default.

**Preserved URLs (critical for SEO):**

| Pattern         | Example                        | Hugo Config                          |
| --------------- | ------------------------------ | ------------------------------------ |
| `/blog/{slug}/` | `/blog/2024-06-13-my-article/` | `[permalinks] blog = "/blog/:slug/"` |
| `/tags/{tag}/`  | `/tags/newsletter/`            | Hugo default taxonomy URL            |

**Static page URLs (preserved):**

`/family/`, `/ministry/`, `/podcast/`, `/archives/`, `/donate/`, `/contact/`,
`/subscribe/`

**Pagination URLs:**

- `/blog/` — page 1
- `/blog/page/2/`, `/blog/page/3/`, etc.
- `/tags/{tag}/` — page 1
- `/tags/{tag}/page/2/`, etc.

---

## Hugo Configuration (`hugo.toml`)

```toml
baseURL = "https://ofreport.com/"
locale = "en-US"
title = "OFReport.com"

# Pagination
[pagination]
  pagerSize = 8

# Permalinks — preserve existing URL structure
[permalinks]
  blog = "/blog/:slug/"

# Taxonomies
[taxonomies]
  tag = "tags"

# RSS output
[services.rss]
  limit = 10

[outputFormats.RSS]
  baseName = "feed"

# SEO
[params]
  description = "Joshua and Kelsie Steele — Missionaries serving Christ in Ukraine"
  titleSuffix = "Joshua and Kelsie Steele — Missionaries serving Christ in Ukraine"
  cloudinaryBase = "https://res.cloudinary.com/dnkvsijzu"
  pdfBase = "https://d21yo20tm8bmc2.cloudfront.net/ofr/"

# Build stats for Tailwind CSS
[build]
  [build.buildStats]
    enable = true
  [[build.cachebusters]]
    source = 'assets/notwatching/hugo_stats\.json'
    target = 'css'
  [[build.cachebusters]]
    source = '(postcss|tailwind)\.config\.js'
    target = 'css'

[module]
  [[module.mounts]]
    source = 'assets'
    target = 'assets'
  [[module.mounts]]
    disableWatch = true
    source = 'hugo_stats.json'
    target = 'assets/notwatching/hugo_stats.json'

# Markup configuration
[markup.goldmark.renderer]
  unsafe = true  # Allow raw HTML in markdown if needed
```

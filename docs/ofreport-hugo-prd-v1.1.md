# OFReport.com — Hugo Rebuild PRD

**Version:** 1.1
**Date:** February 8, 2026
**Author:** Joshua Steele (with Claude AI assistance)
**Source Reference:** [Hugo Migration Brief](./hugo-migration-brief.md)

---

## 1. Project Overview

### 1.1 Purpose

Rebuild [OFReport.com](https://ofreport.com), a missionary family blog
documenting 17 years of ministry work in Ukraine, from Nuxt.js 2 to Hugo. The
site has 219 blog articles, 5 static pages, and 26 tags spanning October 2008
to August 2025.

### 1.2 Goals

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
  in the finished site (see Section 2)

### 1.3 Non-Goals

- Line-by-line replication of the Nuxt site's code or architecture
- Adding a CMS or admin interface
- Multilingual support (may be added later; Hugo supports it natively)
- Complete visual redesign (refresh, not revolution)

---

## 2. Development Approach

### 2.1 Developer-Directed, AI-Assisted

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

### 2.2 Tailwind Plus Workflow

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

### 2.3 Suggested Build Phases

The following phases provide a logical order for building the site
incrementally. Each phase should include explanation, implementation, and
verification before proceeding.

| Phase | Focus                               | Key Learning                                                     |
| ----- | ----------------------------------- | ---------------------------------------------------------------- |
| 1     | Project scaffolding & configuration | Hugo project structure, `hugo.toml` config, content organization |
| 2     | Tailwind CSS v4 integration         | `css.TailwindCSS`, asset pipeline, `buildStats`                  |
| 3     | Base layout & navigation            | Go templates, partials, base template inheritance                |
| 4     | Blog listing with pagination        | Hugo's pagination system, list templates, range/where functions  |
| 5     | Single article template             | Single page templates, frontmatter access, date formatting       |
| 6     | Shortcodes                          | Custom shortcodes for images, callouts, buttons                  |
| 7     | Tag taxonomy                        | Hugo taxonomies, taxonomy list/term templates                    |
| 8     | Static pages                        | Content sections, page-specific templates                        |
| 9     | RSS feed                            | Custom RSS template, output formats                              |
| 10    | SEO & meta tags                     | Head partial, Open Graph, Twitter Cards, sitemap                 |
| 11    | Contact form (Netlify Forms)        | Static form handling, Netlify integration                        |
| 12    | Newsletter integration              | Mailchimp embedded forms                                         |
| 13    | Lightbox integration                | GLightbox setup, shortcode enhancement                           |
| 14    | Analytics                           | Privacy-friendly analytics partial                               |
| 15    | Content migration                   | Migration script, validation, testing                            |
| 16    | Deployment                          | Netlify configuration, redirects, final testing                  |

---

## 3. Architectural Decisions

### 3.1 Image Strategy: Cloudinary (Existing)

**Decision:** Continue using Cloudinary for all image hosting and
transformation.

**Rationale:**

- All existing images are already on Cloudinary (cloud name: `dnkvsijzu`)
- Free tier is sufficient for a personal blog's traffic
- No build-time image processing needed
- No images bloating the Git repository
- URL-based transformations work naturally with Hugo templates

**Implementation:**

- Create a Hugo partial (`partials/cloudinary-url.html`) that constructs
  optimized Cloudinary URLs with transformation parameters
- Transformation presets for different contexts:
  - **Article display:** `c_scale,f_auto,q_auto:best` with responsive widths
  - **OG/social images:** `c_fill,f_auto,h_630,q_auto,w_1200`
  - **RSS feed:** `c_scale,f_auto,q_auto,w_560`
  - **Preview cards:** `c_scale,f_auto,q_auto,w_740` (featured),
    `c_scale,f_auto,q_auto,w_610` (regular)
- The `cover` frontmatter field continues to hold the full Cloudinary URL

### 3.2 Inline Components: Hugo Shortcodes

**Decision:** Convert Vue components to Hugo shortcodes, using Hugo's built-in
`figure` shortcode where possible.

**Component Mapping:**

| Vue Component       | Hugo Approach                                       | Notes                                                                                                                                                                                                           |
| ------------------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `<article-image>`   | Custom `figure` shortcode or Hugo built-in `figure` | Wraps image in lightbox-compatible `<a>` tag; applies Cloudinary transformations. Evaluate whether Hugo's built-in figure shortcode is sufficient or if a custom one is needed for Cloudinary URL construction. |
| `<article-callout>` | Custom `callout` shortcode (paired)                 | `{{< callout [type] [pdf] >}}Content{{< /callout >}}`                                                                                                                                                           |
| `<article-button>`  | Custom `button` shortcode                           | `{{< button href="..." text="..." >}}`                                                                                                                                                                          |
| `<article-svg>`     | Custom `svg` shortcode                              | Loads SVG from `assets/` directory                                                                                                                                                                              |
| `<article-divider>` | Standard markdown `---` with CSS                    | No shortcode needed                                                                                                                                                                                             |
| `<article-spacer>`  | Eliminate                                           | Proper CSS spacing makes this unnecessary                                                                                                                                                                       |

**Shortcode design principles:**

- Keep shortcodes simple and focused on one task
- Use named parameters for clarity
- Document each shortcode with usage examples in the project README

### 3.3 CSS: Tailwind CSS v4

**Decision:** Use Tailwind CSS v4 via Hugo's built-in `css.TailwindCSS`
function.

**Setup (per Hugo official docs):**

1. Install dependencies: `npm install --save-dev tailwindcss @tailwindcss/cli`
2. Create `assets/css/main.css`:
   ```css
   @import "tailwindcss";
   @source "hugo_stats.json";
   ```
3. Add to `hugo.toml`:
   ```toml
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
   ```
4. Create `layouts/partials/css.html`:
   ```go-html-template
   {{ with resources.Get "css/main.css" }}
     {{ $opts := dict "minify" (not hugo.IsDevelopment) }}
     {{ with . | css.TailwindCSS $opts }}
       {{ if hugo.IsDevelopment }}
         <link rel="stylesheet" href="{{ .RelPermalink }}">
       {{ else }}
         {{ with . | fingerprint }}
           <link rel="stylesheet" href="{{ .RelPermalink }}"
                 integrity="{{ .Data.Integrity }}" crossorigin="anonymous">
         {{ end }}
       {{ end }}
     {{ end }}
   {{ end }}
   ```
5. Include in base template with deferred execution:
   ```go-html-template
   <head>
     {{ with (templates.Defer (dict "key" "global")) }}
       {{ partial "css.html" . }}
     {{ end }}
   </head>
   ```

### 3.4 JavaScript: Alpine.js (Minimal)

**Decision:** Use Alpine.js for small interactive behaviors. No heavy
JavaScript framework.

**Rationale:**

- Alpine.js (~17KB) is designed for adding interactivity to server-rendered
  HTML — exactly what a Hugo site needs
- Declarative syntax (attributes in HTML) keeps behavior readable and
  co-located with templates
- Familiar to Vue.js developers (Alpine was inspired by Vue)
- Popular pairing with Hugo + Tailwind in the static site ecosystem
- Avoids writing imperative vanilla JS for common UI patterns

**Use cases:**

- Mobile hamburger menu toggle
- Dropdown menus (if needed)
- Any future interactive elements (accordion, tabs, etc.)

**Implementation:**

- Install via npm: `npm install --save-dev alpinejs`
- Load via Hugo's `js.Build` pipe or from CDN
- Initialize in the base layout before `</body>`:
  ```html
  <script
    defer
    src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js"
  ></script>
  ```
- Use inline `x-data`, `@click`, `x-show` attributes in templates

**Example — hamburger menu:**

```html
<nav x-data="{ open: false }">
  <button @click="open = !open" aria-label="Toggle menu">
    <!-- hamburger icon -->
  </button>
  <div x-show="open" @click.away="open = false">
    <!-- mobile menu links -->
  </div>
</nav>
```

### 3.5 Contact Form: Netlify Forms

**Decision:** Replace AWS Lambda + reCAPTCHA with Netlify Forms.

**Implementation:**

- Standard HTML `<form>` with `data-netlify="true"` attribute
- Netlify honeypot field for spam prevention:
  `netlify-honeypot="bot-field"` on the form, hidden input for bots
- Custom success page at `/thank-you/` for post-submission redirect
- Fields: Name (required), Email (required), Message (required)
- Create as a Hugo partial (`partials/contact-form.html`) included on the
  `/contact/` page
- No JavaScript required

**Netlify free tier:** 100 submissions/month — more than sufficient.

### 3.6 Analytics: Free, Privacy-Friendly (Deferred)

**Decision:** Use a free, privacy-friendly analytics tool. The specific tool
will be chosen later in the project.

**Candidates:**

- **GoatCounter** — free for non-commercial use, open source, lightweight
- **Umami** — open source, self-hostable on free-tier platforms
- **Plausible Community Edition** — open source, self-hosted

**Implementation:**

- Create a swappable partial (`partials/analytics.html`) that contains the
  analytics script tag
- The partial is included in the base layout's `<head>` or before `</body>`
- Designed so switching tools means changing only this one file
- Conditional loading: only in production
  (`{{ if hugo.IsProduction }}...{{ end }}`)

### 3.7 Summary/Preview: Hugo `description` Field

**Decision:** Map the existing `preview` frontmatter field to Hugo's
`description` field during migration.

**How it works in Hugo:**

- `description` is a built-in Hugo frontmatter field accessed via
  `.Description`
- Used for `<meta name="description">` and Open Graph tags
- Used for article preview text on listing pages
- Plain text (strip any markdown from existing `preview` content during
  migration)

**In templates:**

```go-html-template
{{/* Listing page card */}}
<p>{{ .Description }}</p>

{{/* Meta description */}}
<meta name="description" content="{{ .Description }}">
```

### 3.8 RSS Feed

**Decision:** Use Hugo's built-in RSS with a customized template, served at
`/feed.xml` to maintain the existing URL for Mailchimp integration.

**Configuration in `hugo.toml`:**

```toml
[services.rss]
  limit = 10

[outputFormats.RSS]
  baseName = "feed"
```

**Custom RSS template** (`layouts/_default/rss.xml`):

- Include HTML-rendered description/content
- Include cover images with Cloudinary transformations
  (`c_scale,f_auto,q_auto,w_560`)
- Include publication date, author, and article link
- Set appropriate channel-level metadata for Mailchimp compatibility

### 3.9 Newsletter: Mailchimp (Inline Forms Only)

**Decision:** Keep Mailchimp for newsletter subscriptions. Use inline embedded
forms only — no popup.

**Placement:**

- Homepage (above footer)
- Article footer (after article content, before related articles)
- Dedicated `/subscribe/` page

**Implementation:**

- Mailchimp provides embed HTML — wrap in a Hugo partial
  (`partials/mailchimp-form.html`)
- Style with Tailwind to match site design
- No external Mailchimp JavaScript for popups

### 3.10 Lightbox: GLightbox

**Decision:** Use GLightbox for click-to-enlarge image viewing in articles.

**Why GLightbox:**

- Pure vanilla JavaScript — zero dependencies, no jQuery
- ~11KB gzipped — very lightweight
- Clean, modern aesthetic — not gimmicky
- Mobile-friendly with touch/swipe support
- Keyboard navigation (arrow keys, escape)
- MIT licensed

**Implementation:**

- Load CSS and JS from CDN (cdnjs.cloudflare.com) in the base layout, only
  on article pages:
  ```html
  <link
    rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/glightbox/3.3.1/css/glightbox.min.css"
  />
  <script src="https://cdnjs.cloudflare.com/ajax/libs/glightbox/3.3.1/js/glightbox.min.js"></script>
  ```
- Initialize in a small inline script:
  ```javascript
  const lightbox = GLightbox({ selector: ".glightbox" });
  ```
- The figure shortcode outputs lightbox-compatible HTML:
  ```html
  <figure>
    <a
      href="{full-size-cloudinary-url}"
      class="glightbox"
      data-gallery="article"
      data-description="{caption}"
    >
      <img src="{display-size-cloudinary-url}" alt="{alt}" loading="lazy" />
    </a>
    <figcaption>{caption}</figcaption>
  </figure>
  ```
- The `href` points to a larger Cloudinary transformation for the lightbox
  view, while `src` uses a smaller transformation for in-page display

### 3.11 Tag Consolidation

**Decision:** Consolidate `good and evil` and `good-and-evil` into a single
tag: `good-and-evil`.

**Action:** Handled by the migration script (Section 7).

---

## 4. Design & Visual Identity

### 4.1 Design Philosophy

The Hugo rebuild should **preserve the blog's general identity and structure**
while **refreshing the visual details**. This is not a redesign from scratch,
but an opportunity to improve polish, spacing, typography, and overall feel.

**What to preserve:**

- General page layout structure (header, content area, footer)
- Blog listing with featured article + grid layout
- Article page structure (cover image, title, meta, content)
- Navigation structure and menu items

**What is open for improvement:**

- Font choices and typographic scale — the existing fonts (Lato, Noto Serif,
  Mate SC) can be kept, changed, or refined
- Color palette — the existing blues and grays are a starting point, not a
  constraint. Better or more modern color choices are welcome
- Spacing and whitespace — improve breathing room and visual hierarchy
- Component styling — article cards, tag badges, buttons, callouts can all
  be refreshed
- Mobile experience — improve responsive behavior with modern CSS/Tailwind

### 4.2 Design Reference (Current Site)

These values are documented for reference. They are **not** requirements to
replicate exactly.

**Current color palette:**

| Token     | Hex        | Usage               |
| --------- | ---------- | ------------------- |
| Blue-500  | `#2bb0ed`  | Primary accent      |
| Blue-600  | `#1992d4`  | Links, hover states |
| Blue-900  | `#0f2847`  | Footer background   |
| Blue-dark | `#024775`  | Dark accents        |
| Gray-100  | light gray | Page background     |

**Current fonts (via Google Fonts):**

| Font       | Current Usage   | Weight(s) |
| ---------- | --------------- | --------- |
| Lato       | Headings        | 700       |
| Noto Serif | Body text       | 400, 700  |
| Mate SC    | Decorative text | —         |

**Current responsive breakpoints:**

| Name | Width  |
| ---- | ------ |
| xs   | 460px  |
| sm   | 640px  |
| md   | 768px  |
| lg   | 1024px |
| xl   | 1280px |

### 4.3 Tailwind Plus as Design Reference

The developer has a **Tailwind Plus** (UI Components) subscription. Licensed
component examples should be used as design references when building UI
elements (navigation bars, article cards, footers, forms, etc.).

See Section 2.2 for the workflow details on how to use Tailwind Plus snippets
with Claude Code.

---

## 5. Hugo Site Structure

### 5.1 Content Organization

```
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
│   ├── authors.json             # Author information
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
│   │   ├── tag.html             # Single tag page (articles with that tag)
│   │   └── tags.html            # All tags listing page
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

### 5.2 Content File Format (Articles)

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

### 5.3 URL Structure

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

### 5.4 Hugo Configuration (`hugo.toml`)

```toml
baseURL = "https://ofreport.com/"
languageCode = "en-us"
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

---

## 6. Template & Component Specifications

### 6.1 Base Layout (`baseof.html`)

```
<!DOCTYPE html>
<html lang="en">
<head>
  {{ partial "head.html" . }}
  {{ with (templates.Defer (dict "key" "global")) }}
    {{ partial "css.html" . }}
  {{ end }}
</head>
<body>
  {{ partial "header.html" . }}
  <main>
    {{ block "main" . }}{{ end }}
  </main>
  {{ partial "footer.html" . }}
  {{ partial "glightbox.html" . }}
  {{ partial "analytics.html" . }}
  <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js"></script>
</body>
</html>
```

### 6.2 Blog Listing Page

**Page 1 behavior:**

- First (most recent) article displayed as a featured card at full width
- Remaining articles (up to 8) in a 2-column responsive grid
- Pagination controls at bottom

**Page 2+ behavior:**

- All articles in 2-column grid (no featured card)
- Pagination controls at bottom

**Article card displays:**

- Cover image (if present, with Cloudinary optimization)
- Title (linked)
- Author name and formatted date
- Description text
- Tag badges
- PDF download icon (if `pdf` field is present)

### 6.3 Single Article Page

**Layout (top to bottom):**

1. Cover image (full-width, responsive sizing, with lightbox)
2. Caption (if present, styled as small text below image)
3. Article title (`<h1>`)
4. Meta line: Author name, date, reading time (Hugo built-in)
5. Tag badges
6. Article content (rendered markdown with shortcodes)
7. PDF download callout (if `pdf` field is present)
8. Mailchimp newsletter signup form
9. Previous/next article navigation

### 6.4 Navigation

**Header:**

- Site logo/name (links to homepage)
- Hamburger menu on mobile (Alpine.js toggle), inline links on desktop
- Menu items: Family, Ministry, Blog, Podcast, Archives, Contact, Donate

**Footer:**

- 3-column link layout
- Bible verse quote
- Social media icons (Facebook, Twitter, GitHub)
- External links: ETO, Bible First, CMO, kelsie.me
- Copyright with dynamic year: `© {{ now.Year }} Joshua and Kelsie Steele`

### 6.5 SEO Partial (`seo.html`)

**Title format:** `{{ .Title }} | {{ .Site.Params.titleSuffix }}`

**Meta tags to include:**

- `<meta name="description" content="{{ .Description }}">`
- `<link rel="canonical" href="{{ .Permalink }}">`
- Open Graph: `og:title`, `og:description`, `og:image`, `og:url`, `og:type`
- Twitter Card meta tags
- Robots: `index,follow` in production, `noindex,nofollow` otherwise

**OG image logic:**

- If article has `cover` field: use Cloudinary URL with
  `c_fill,f_auto,h_630,q_auto,w_1200` transformation
- Otherwise: use a default site OG image

### 6.6 Custom 404 Page

- SVG "404" graphic (port from existing site)
- Friendly message
- Link back to homepage and blog

---

## 7. Shortcode Specifications

### 7.1 Figure/Image Shortcode

**Purpose:** Display a Cloudinary-hosted image with optional caption, wrapped
in a lightbox-compatible link.

**Usage:**

```
{{< figure src="cloudinary-public-id-or-full-url" caption="Optional caption"
    alt="Alt text" >}}
```

**Output HTML:**

```html
<figure>
  <a
    href="{large-cloudinary-url}"
    class="glightbox"
    data-gallery="article"
    data-description="{caption}"
  >
    <img src="{display-cloudinary-url}" alt="{alt}" loading="lazy" />
  </a>
  <figcaption>{caption}</figcaption>
</figure>
```

**Notes:**

- Evaluate whether Hugo's built-in `figure` shortcode can handle Cloudinary
  URLs and lightbox attributes, or if a custom shortcode is needed
- The shortcode should accept both full Cloudinary URLs and public IDs
- Apply appropriate Cloudinary transformations for display size vs. lightbox
  size

### 7.2 Callout Shortcode

**Purpose:** Highlighted box for important information, CTAs, or PDF download
links.

**Usage:**

```
{{< callout >}}
Important information goes here.
{{< /callout >}}

{{< callout pdf="OFR-Jul-Aug-2025.pdf" >}}
Get the full newsletter PDF.
{{< /callout >}}
```

**Output HTML:**

```html
<div class="callout">
  <p>Important information goes here.</p>
  <!-- If pdf param provided: -->
  <a
    href="https://d21yo20tm8bmc2.cloudfront.net/ofr/OFR-Jul-Aug-2025.pdf"
    class="callout-download"
    >Download PDF</a
  >
</div>
```

### 7.3 Button Shortcode

**Purpose:** Styled CTA link.

**Usage:**

```
{{< button href="/donate/" text="Support Our Ministry" >}}
{{< button href="https://example.com" text="Visit Site" external=true >}}
```

### 7.4 SVG Shortcode

**Purpose:** Embed an SVG file from the assets directory.

**Usage:**

```
{{< svg name="bible-first-logo" >}}
```

**Implementation:** Reads SVG from `assets/img/{name}.svg` and outputs inline.

---

## 8. Content Migration

### 8.1 Migration Script

**Language:** Ruby

**Rationale:** The developer is highly proficient in Ruby and will be better
able to understand, debug, and modify the script. The transformation tasks
(file I/O, YAML parsing, regex text replacement) are well-suited to Ruby.

**Script responsibilities:**

1. **Read** each markdown file from the source Nuxt project's
   `content/articles/` directory

2. **Transform frontmatter:**
   - Rename `preview` → `description` (strip any markdown formatting)
   - Remove `basename` and `iso8601Date` fields (build-generated, not needed)
   - Add explicit `slug` field derived from the filename (to preserve existing
     URLs)
   - Preserve all other fields: `title`, `date`, `author`, `tags`, `cover`,
     `caption`, `pdf`

3. **Transform content body:**
   - Convert `<article-image>` → Hugo figure shortcode
   - Convert `<article-callout>` → `{{< callout >}}` shortcode
   - Convert `<article-button>` → `{{< button >}}` shortcode
   - Convert `<article-svg>` → `{{< svg >}}` shortcode
   - Convert `<article-divider>` → markdown `---`
   - Remove `<article-spacer>` instances

4. **Fix tags:**
   - Replace `good and evil` with `good-and-evil` in all tag arrays

5. **Write** transformed files to the Hugo project's `content/blog/` directory

6. **Validate:**
   - Compare article count: input vs. output
   - Verify all frontmatter fields are present
   - Check for any remaining Vue component syntax (`<article-` patterns)
   - Flag articles that may need manual review (see Section 8.2)
   - Generate a diff report for manual review

### 8.2 Legacy WordPress Article Styling

A number of older articles on the existing site were originally published on
a WordPress blog and were migrated to the Nuxt site without fully updating
their formatting. There is an existing unmerged pull request (PR #93 on the
current GitHub repo) that attempted to address some of these styling
inconsistencies.

**Approach for the Hugo migration:**

- The migration script should process all 219 articles consistently
- After migration, a manual review pass should identify articles with
  formatting issues (inconsistent headings, raw HTML, missing images, broken
  layout patterns)
- The migration script's validation step should flag articles that contain
  raw HTML or unusual patterns that may indicate legacy formatting issues
- Fixing these articles is part of the migration scope — the goal is that
  all articles render cleanly and consistently in the new Hugo site
- PR #93 from the existing repo should be consulted as a reference for known
  problem articles

### 8.3 Migration Checklist

- [ ] All 219 articles converted
- [ ] All 5 static pages created in Hugo
- [ ] Frontmatter schema matches Hugo expectations
- [ ] All Vue component syntax converted to shortcodes
- [ ] Duplicate tag consolidated
- [ ] No content lost (diff validation)
- [ ] Legacy WordPress articles reviewed and styled consistently
- [ ] URLs match existing structure (`/blog/{slug}/`)
- [ ] Cover images display correctly (Cloudinary URLs intact)
- [ ] PDF links work (CloudFront URLs intact)
- [ ] RSS feed generates correctly at `/feed.xml`
- [ ] All tags render with correct article counts
- [ ] Pagination works on blog and tag pages
- [ ] Contact form submits successfully via Netlify
- [ ] 404 page displays correctly
- [ ] Site passes Lighthouse audit (performance, SEO, accessibility)

---

## 9. Source Control & Repository Strategy

### 9.1 Development Repository

**Decision:** Develop the Hugo site in a **new, separate repository** during
the build process.

**Rationale:**

- Keeps the existing Nuxt site intact and deployable throughout development
- Provides a clean Git history for the Hugo project
- Avoids branch confusion and merge complexity
- The existing repo remains available as a reference for content and behavior

**Recommended approach:**

1. **During development:** Create a new repo (e.g., `ofreport.com-hugo` or
   similar) for all Hugo development work
2. **At launch:** When the Hugo site is ready to go live:
   - Archive or rename the old Nuxt repo (e.g., `ofreport.com-legacy`)
   - Rename the Hugo repo to `ofreport.com` (or push to a fresh repo with
     that name)
   - Update Netlify to build from the new repo
3. **Post-launch:** The old repo remains archived as a historical reference

**Alternative:** If you prefer to keep everything in one repo, you could use
a long-lived `hugo-rebuild` branch, but this tends to create more complexity
than the separate-repo approach.

### 9.2 `.gitignore`

Key entries for the Hugo project:

```
# Hugo build output
public/
resources/_gen/

# Node modules
node_modules/

# Hugo stats (regenerated on build)
hugo_stats.json

# Tailwind Plus licensed snippets (must not be committed)
docs/tailwind_plus/

# OS files
.DS_Store
Thumbs.db

# Environment files
.env
```

---

## 10. Deployment

### 10.1 Netlify Configuration (`netlify.toml`)

```toml
[build]
  publish = "public"
  command = "npm install && hugo --gc --minify"

[build.environment]
  HUGO_VERSION = "0.147.0"
  HUGO_ENV = "production"
  NODE_VERSION = "20"

[context.deploy-preview]
  command = "npm install && hugo --gc --minify --buildFuture -b $DEPLOY_PRIME_URL"

[context.deploy-preview.environment]
  HUGO_VERSION = "0.147.0"

[context.branch-deploy]
  command = "npm install && hugo --gc --minify -b $DEPLOY_PRIME_URL"

[context.branch-deploy.environment]
  HUGO_VERSION = "0.147.0"

# Redirects for SEO continuity
[[redirects]]
  from = "/blog/page/1"
  to = "/blog/"
  status = 301

# Security headers
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
```

### 10.2 Build Performance

Hugo builds are near-instant for 219 articles. Expected build time: under 1
second for Hugo itself, plus a few seconds for Tailwind CSS processing.

### 10.3 Domain & DNS

No changes needed — the site remains on the same domain (`ofreport.com`) and
Netlify hosting. Only the build command, publish directory, and source repo
change.

---

## 11. New Features

These features are not present on the current site but are low-cost additions
in Hugo.

### 11.1 Reading Time

Hugo calculates reading time automatically via `.ReadingTime` (returns minutes).
Display on article pages alongside the date and author.

### 11.2 Related Articles

Hugo can suggest related content based on tags, date, and other parameters.
Display 2–3 related articles at the bottom of each article page.

**Configuration in `hugo.toml`:**

```toml
[related]
  includeNewer = true
  threshold = 80
  [[related.indices]]
    name = "tags"
    weight = 100
  [[related.indices]]
    name = "date"
    weight = 10
```

### 11.3 Image Lightbox (Click-to-Enlarge)

Not present on the current site. All article images will be viewable in a
clean, full-screen lightbox overlay via GLightbox (see Section 3.10).

### 11.4 Search (Optional, Deferred)

Client-side search via Pagefind is a strong candidate if search is desired
later. Pagefind indexes the built site at deploy time and provides a
lightweight search UI with no server-side component. Can be added post-launch
without architectural changes.

---

## 12. Risks & Mitigations

| Risk                                        | Likelihood | Impact | Mitigation                                                                       |
| ------------------------------------------- | ---------- | ------ | -------------------------------------------------------------------------------- |
| Vue syntax not fully converted in migration | Medium     | High   | Validation step in migration script checks for remaining `<article-` patterns    |
| Broken URLs hurt SEO                        | Low        | High   | URL structure aligns with Hugo defaults; explicit permalink config guarantees it |
| Cloudinary free tier exceeded               | Low        | Medium | Monitor usage; 25 credits/month is generous for blog traffic                     |
| RSS feed breaks Mailchimp campaigns         | Medium     | High   | Test feed URL (`/feed.xml`) and content format before cutover                    |
| Legacy WordPress articles render poorly     | Medium     | Medium | Migration script flags unusual patterns; manual review pass for older articles   |
| Lightbox conflicts with Cloudinary URLs     | Low        | Low    | Test with actual Cloudinary images early in development                          |
| Tailwind v4 + Hugo integration issues       | Low        | Medium | Follow official Hugo docs exactly; use `css.TailwindCSS` function                |

---

## 13. Out of Scope (Future Considerations)

- **Comments system** (Disqus, giscus, etc.) — can be added later
- **Dark mode** — can be added with Tailwind's dark mode support
- **Multilingual content** — Hugo supports i18n natively; architecture doesn't
  prevent future addition
- **CMS integration** — Decap CMS or similar could be added for non-technical
  editors
- **Image migration to local** — if Cloudinary becomes impractical, images
  could be moved to Hugo page bundles in the future
- **Client-side search** — Pagefind can be added post-launch

---

## Appendix A: Reference Links

- [Hugo Documentation](https://gohugo.io/documentation/)
- [Hugo `css.TailwindCSS` function](https://gohugo.io/functions/css/tailwindcss/)
- [Hugo Content Summaries](https://gohugo.io/content-management/summaries/)
- [Hugo Shortcodes](https://gohugo.io/content-management/shortcodes/)
- [Hugo Taxonomies](https://gohugo.io/content-management/taxonomies/)
- [Hugo RSS Templates](https://gohugo.io/templates/rss/)
- [Alpine.js Documentation](https://alpinejs.dev/)
- [GLightbox GitHub](https://github.com/biati-digital/glightbox)
- [Netlify Forms Documentation](https://docs.netlify.com/forms/setup/)
- [Netlify Hugo Deployment](https://docs.netlify.com/frameworks/hugo/)
- [Cloudinary Transformation Reference](https://cloudinary.com/documentation/transformation_reference)
- [Tailwind CSS v4 Documentation](https://tailwindcss.com/docs)
- [OFReport.com Source Code (Nuxt)](https://github.com/joshukraine/ofreport.com)

## Appendix B: Existing Data Files

These files from the current site should be migrated to the Hugo `data/`
directory:

| File            | Purpose                        | Hugo Usage                                 |
| --------------- | ------------------------------ | ------------------------------------------ |
| `authors.json`  | Author name, bio, avatar       | Data file accessed via `site.Data.authors` |
| `archives.json` | PDF newsletter archive by year | Data file for `/archives/` page template   |

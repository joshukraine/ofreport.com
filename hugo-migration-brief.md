# OFReport.com — Codebase Audit & Hugo Migration Brief

This report documents the full scope and technical architecture of
[OFReport.com](https://ofreport.com), a missionary family blog built with
Nuxt.js 2. Its purpose is to inform a PRD for rebuilding the site in Hugo.

### Important: Rebuild, Not Migration

This is **not** a line-by-line port. The new Hugo site should be built in
whatever way makes the most sense for the Hugo framework and modern web
practices. The existing Nuxt implementation is documented here as **reference
for understanding the content, features, and user experience** — not as a
blueprint to replicate exactly. Where Hugo offers a better, simpler, or more
idiomatic way to solve a problem, that approach should be preferred. The goals
are:

- **Preserve all existing content** (219 articles, static pages, PDFs, images)
- **Preserve the general feature set** (blog, tags, pagination, RSS, SEO, etc.)
- **Preserve key URL structures** where possible for SEO continuity
- **Embrace Hugo idioms** rather than recreating Nuxt/Vue patterns
- **Use modern technologies** (current Tailwind, current analytics, etc.)
- **Simplify where possible** — reduce complexity and JavaScript dependency

---

## 1. Site Overview

- **Purpose**: Family blog documenting missionary work in Ukraine
- **Authors**: Joshua Steele (primary), Kelsie Steele, one guest author (Raphaël Villeneuve)
- **Content span**: October 2008 — August 2025 (17 years)
- **Current stack**: Nuxt.js 2.18.1, Tailwind CSS v1, Cloudinary, Netlify
- **Deployment**: Static site generation (`nuxt generate`) deployed to Netlify CDN
- **Source code**: [github.com/joshukraine/ofreport.com](https://github.com/joshukraine/ofreport.com)

---

## 2. Content Inventory

| Content Type | Count | Location |
|---|---|---|
| Blog articles (Markdown) | 219 | `content/articles/*.md` |
| Static pages (Markdown) | 5 | `content/pages/*.md` |
| Unique tags | 26 | Defined in article frontmatter |
| Authors | 3 | `data/authors.json` |
| Newsletter PDF archives | 61 articles link PDFs | Hosted on AWS CloudFront CDN |

### Static Pages

| Page | Route | Description |
|---|---|---|
| Family | `/family/` | Family background and introduction |
| Ministry | `/ministry/` | Ministry overview (ETO, Bible First, CMO, UGO) with SVG logos |
| Podcast | `/podcast/` | Podcast subscription page with Buzzsprout embed |
| Archives | `/archives/` | Newsletter PDF archive organized by year |
| Donate | `/donate/` | Donation instructions |
| Contact | `/contact/` | Contact form with reCAPTCHA v2 |
| Subscribe | `/subscribe/` | Mailchimp newsletter signup |

### Tags (26 total)

`abs`, `announcements`, `audio`, `bible first`, `bible study`, `bryan shufelt`,
`cmo`, `economics`, `english club`, `family`, `frederic bastiat`, `fun`,
`good and evil`, `good-and-evil`, `love story`, `ministry`, `newsletter`,
`photos`, `podcast`, `seven pillars`, `testimony`, `theology`, `ugo`,
`ukraine`, `video`, `voices-from-ukraine`

Note: `good and evil` and `good-and-evil` appear to be duplicates that should
be consolidated during migration.

---

## 3. Article Frontmatter Schema

```yaml
---
title: "Article Title"                    # Required — string
date: "2024-06-13"                        # Required — YYYY-MM-DD
author: "Joshua Steele"                   # Required — must match authors.json
tags:                                     # Required — array of strings
  - newsletter
  - ministry
preview: >                                # Required — excerpt for listings (supports markdown)
  A brief summary of the article...
cover: "https://res.cloudinary.com/..."   # Optional — full Cloudinary URL (55% of articles)
caption: "Photo caption with *markdown*"  # Optional — displayed under cover image (50% of articles)
pdf: "OFR-Jul-Aug-2025.pdf"              # Optional — newsletter PDF filename (28% of articles)
---
```

### Build-Generated Fields (added by `md2json` script)

- `basename` — article slug derived from filename (e.g., `2024-06-13-my-article`)
- `iso8601Date` — ISO 8601 formatted date with timezone

### Filename Convention

Articles follow the pattern: `YYYY-MM-DD-slug-title.md`

---

## 4. Feature Set

### 4.1 Blog Listing & Pagination

- **Default**: 8 articles per page (configured via `PER_PAGE` env var)
- **Featured article**: Page 1 displays one featured article at full width, followed by 8 regular articles in a 2-column grid
- **Subsequent pages**: 8 articles in 2-column grid, no featured article
- **Article preview cards** show: cover image (optional), title, author, date, preview text, tag badges, PDF download icon (if applicable)
- **Route structure**:
  - `/blog/` — page 1 (redirects from `/blog/page/1`)
  - `/blog/page/2`, `/blog/page/3`, etc.

### 4.2 Tag System

- Articles can have multiple tags
- Tags are parameterized for URLs (lowercased, spaces to hyphens, special chars removed)
- Tag pages have their own pagination
- **Route structure**:
  - `/tags/` — index page listing all tags with article counts
  - `/tags/{tag}/` — articles filtered by tag (redirects from `/tags/{tag}/page/1`)
  - `/tags/{tag}/page/2`, etc.

### 4.3 RSS Feed

- Format: RSS 2.0 at `/feed.xml`
- Contains latest 10 articles
- Includes title, link, HTML-rendered preview, publication date, cover image
- Cover images optimized via Cloudinary transformations (`c_scale,f_auto,q_auto,w_560`)
- Cache time: 15 minutes

### 4.4 SEO & Meta Tags

- **Title template**: `{Page Title} | Joshua and Kelsie Steele — Missionaries serving Christ in Ukraine`
- **Open Graph**: `og:title`, `og:description`, `og:image` (cover image at 1200x630), `og:type` ("article" for posts)
- **Twitter Cards**: Supported via OG tags
- **Robots**: `index,follow` in production, `noindex,nofollow` otherwise
- **Sitemap**: Auto-generated at `/sitemap.xml` (gzip compressed)
- **Canonical URLs**: Auto-generated per page
- **Favicons**: Apple touch icon, Android Chrome icons, Safari pinned tab SVG, MS tile

### 4.5 Image Handling (Cloudinary)

- **Cloud name**: `dnkvsijzu`
- All article images hosted on Cloudinary
- Images referenced by full URL in frontmatter (`cover` field) or by public ID in markdown components
- **Optimization transformations applied contextually**:
  - Article display: `crop="scale"`, `quality="auto:best"`, lazy loading
  - OG/social: `c_fill,f_auto,h_630,q_auto,w_1200`
  - RSS feed: `c_scale,f_auto,q_auto,w_560`
  - Preview cards: fixed widths (740px featured, 610px regular)
- Helper function `cldOptimize(url, opts)` injects transformation params into Cloudinary URLs

### 4.6 Custom Markdown Components

Articles use Vue components embedded in markdown via `frontmatter-markdown-loader`.
These solve specific content needs but **do not need to be recreated as-is**.
The PRD should evaluate each use case and determine the best Hugo-native
approach (which may be shortcodes, standard markdown, render hooks, or
something else entirely).

| Current Component | What Problem It Solves | Usage Notes |
|---|---|---|
| `<article-image>` | Display Cloudinary images with optional captions | Most common component. Hugo has built-in figure support and image render hooks that may handle this natively. |
| `<article-callout>` | Highlighted box with optional PDF download link or CTA | Could potentially be a shortcode, or a styled blockquote convention. |
| `<article-button>` | Styled CTA link (internal or external) | Simple enough that styled markdown links or a lightweight shortcode could suffice. |
| `<article-svg>` | Inline SVG graphic from assets | Used on a few pages. Could be a shortcode or partial. |
| `<article-divider>` | Horizontal rule with custom spacing | Standard markdown `---` with CSS may be sufficient. |
| `<article-spacer>` | Vertical whitespace | May be unnecessary with proper CSS typography/spacing. |

**Content conversion note**: All 219 articles contain Vue component syntax
(`<article-image ... />`). A migration script will be needed to convert these
to whatever approach the Hugo site uses. The script's specifics depend on the
PRD's decisions about how to handle each use case.

### 4.7 Contact Form

- Fields: Name (required, max 100), Email (required, validated, max 100), Message (required, max 3000)
- Client-side validation via Vuelidate
- reCAPTCHA v2 for spam prevention
- Submits via POST to AWS Lambda endpoint (`/email/send/json`)
- Toast notifications for success/error feedback
- This is the only dynamic/server-dependent feature on the site

### 4.8 Newsletter Subscription (Mailchimp)

- Mailchimp embedded form in multiple locations: homepage, article footer, dedicated `/subscribe/` page
- Mailchimp popup script loaded in the default layout
- Simple email input + subscribe button

### 4.9 Newsletter PDF Archives

- `/archives/` page lists downloadable PDF newsletters organized by year
- Data stored in `data/archives.json`
- PDFs hosted on AWS CloudFront: `https://d21yo20tm8bmc2.cloudfront.net/ofr/`
- 61 articles also link to PDFs directly via the `pdf` frontmatter field

### 4.10 Podcast

- `/podcast/` page with Buzzsprout embed
- Podcast episodes referenced in articles with tag `podcast`
- Audio embeds appear inline in article markdown

### 4.11 Analytics

- Google Analytics property: `UA-22952661-1`
- Note: This is a Universal Analytics ID (deprecated by Google). Migration should use GA4 or an alternative.

### 4.12 Navigation

- **Header**: Fixed navbar with site logo, hamburger menu (mobile), inline links (desktop)
- **Menu items**: Family, Ministry, Blog, Podcast, Archives, Contact, Donate
- **Footer**: 3-column link layout, Bible verse quote, social media icons (Facebook, Twitter, GitHub), copyright with dynamic year
- **Footer external links**: ETO, Bible First, CMO, kelsie.me

### 4.13 Error Handling

- Custom 404 page with SVG "404" graphic and link back to homepage

---

## 5. Design & Typography

### Fonts (loaded via Google Fonts)

| Font | Usage | Weight(s) |
|---|---|---|
| Lato | Headings (`font-header`) | 700 |
| Noto Serif | Body text (`font-serif`) | 400, 700 |
| Mate SC | Decorative text (`font-fancy`) | — |
| Material Icons | UI icons | — |

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| Blue-500 | `#2bb0ed` | Primary accent, loading bar |
| Blue-600 | `#1992d4` | Links, hover states |
| Blue-900 | `#0f2847` | Footer background |
| Blue-dark | `#024775` | Dark accents |
| Nav gradient | `#127fbf` → `#035388` | Mobile nav background |
| Gray-100 | — | Page background |

### Responsive Breakpoints

| Name | Width |
|---|---|
| xs | 460px |
| sm | 640px |
| md | 768px |
| lg | 1024px |
| xl | 1280px |

### Layout Patterns

- Mobile-first responsive design
- Article cover images scale: 250px (xs) → 350px (sm) → 450px (md) → 600px (lg) → 75vh (xl)
- Blog listing: full-width featured card + 2-column grid
- Page transitions: fade effect with out-in mode

---

## 6. Build & Deployment

### Build Pipeline

1. `yarn md2json` — converts `content/articles/*.md` frontmatter to `data/articles.json`
2. `yarn generate` — runs md2json, then Nuxt static generation to `dist/`
3. Netlify deploys contents of `dist/`

### Netlify Configuration

```toml
base = "."
publish = "dist/"
command = "yarn generate"
PER_PAGE = "8"
```

### Environment Variables

| Variable | Purpose | Required |
|---|---|---|
| `PER_PAGE` | Articles per pagination page | Yes (default: 8) |
| `OFR_RECAPTCHA_SITE_KEY` | reCAPTCHA v2 site key | For contact form |
| `NODE_ENV` | Controls robots.txt behavior | Set by Netlify |

### Current Dependencies (for reference only — none carry over to Hugo)

| Package | Version | Purpose |
|---|---|---|
| nuxt | 2.18.1 | Framework (replaced by Hugo) |
| tailwindcss | ^1.9.6 | CSS framework (outdated, needs modern replacement) |
| markdown-it | 13.0.2 | Markdown processing (Hugo uses Goldmark) |
| markdown-to-json | ^0.5.1 | Frontmatter extraction (not needed in Hugo) |
| frontmatter-markdown-loader | ^3.6.0 | Webpack markdown loader (not needed in Hugo) |
| cloudinary-vue | ^1.2.2 | Image components (needs Hugo-native approach) |
| vuejs-paginate | ^2.1.0 | Pagination UI (Hugo has built-in pagination) |
| vuelidate | ^0.7.4 | Form validation (depends on form solution chosen) |
| dayjs | 1.11.13 | Date formatting (Go templates handle dates) |

---

## 7. Architectural Decisions for the PRD

The following areas need decisions. For each, the current Nuxt approach is noted
for context, but the Hugo site should adopt whatever approach is best — not
necessarily what was done before.

### 7.1 Features That Hugo Handles Natively

These features don't need special planning — Hugo provides them out of the box:

- Markdown content with YAML frontmatter
- Tag taxonomy (with pagination, listing pages, and article counts)
- Blog pagination
- RSS/Atom feeds
- XML sitemap
- Robots.txt
- Custom 404 page
- Date formatting

### 7.2 Image Strategy

**Current approach**: All images on Cloudinary CDN, referenced by URL or public
ID, with transformation parameters injected at the template level.

**Decision needed**: Continue with Cloudinary, switch to Hugo's built-in image
processing (page bundles with local images), or use another approach entirely.
Considerations:

- Cloudinary requires no build-time processing and has a generous free tier
- Hugo's image processing gives full control but requires self-hosting images
- A hybrid approach is possible (Cloudinary for existing content, local for new)

### 7.3 Inline Content Components

**Current approach**: 6 Vue components used inside article markdown (see
Section 4.6). The most important are `article-image` (image + caption) and
`article-callout` (highlighted box with optional link/download).

**Decision needed**: How to handle these in Hugo. Options include:

- Hugo shortcodes (most direct equivalent)
- Markdown render hooks (e.g., image render hook for figures with captions)
- Standard markdown conventions with CSS (e.g., `---` for dividers, blockquotes
  for callouts)
- Some combination of the above

Whatever is chosen, a **content migration script** will be needed to convert
the Vue component syntax in all 219 articles to the new format.

### 7.4 Contact Form

**Current approach**: Vuelidate + reCAPTCHA v2 + POST to AWS Lambda.

**Decision needed**: Hugo is static-only, so forms need an external service.
Options include Netlify Forms (simplest since the site is already on Netlify),
Formspree, Basin, or keeping the existing AWS Lambda endpoint with a plain HTML
form.

### 7.5 Newsletter / Email Subscription

**Current approach**: Mailchimp embedded forms and popup script.

**Decision needed**: Continue with Mailchimp, switch to another provider, or
simplify. The popup approach may be worth reconsidering from a UX perspective.

### 7.6 Analytics

**Current approach**: Google Analytics Universal (UA-22952661-1) — now
deprecated by Google.

**Decision needed**: Migrate to GA4, or consider a privacy-friendly alternative
(Plausible, Fathom, Umami, Goatcounter, etc.).

### 7.7 CSS / Design System

**Current approach**: Tailwind CSS v1 with custom theme (colors, fonts,
breakpoints).

**Decision needed**: The design can be refreshed or preserved, but the CSS
approach should use modern tooling. Options:

- Current Tailwind (v4) via Hugo's built-in PostCSS/Tailwind support
- A simpler CSS approach (custom CSS without a framework — the site is not complex)
- Another utility framework

The existing color palette, fonts, and general visual identity are documented in
Section 5 for reference regardless of approach.

### 7.8 URL Structure

**Preserve for SEO**:

- `/blog/{slug}/` — individual articles
- `/tags/{tag}/` — tag pages

**Can change** (with Netlify redirects from old paths):

- `/blog/page/{n}/` — pagination URLs
- `/tags/{tag}/page/{n}/` — tag pagination URLs
- Static page URLs (`/family/`, `/ministry/`, etc.)

### 7.9 Content Migration Script

Regardless of architectural decisions, a migration script will need to:

- Convert Vue component syntax to the chosen Hugo format across all 219 articles
- Preserve all frontmatter fields (Hugo supports YAML frontmatter natively)
- Handle the `cover` field based on the chosen image strategy
- Map the `preview` field to Hugo's summary mechanism (`.Summary`, `description` param, or manual `<!--more-->` markers)
- Consolidate the duplicate tag (`good and evil` / `good-and-evil`)
- Validate no content is lost

### 7.10 Data Files

| Current File | Hugo Equivalent |
|---|---|
| `data/site.json` (site metadata) | Hugo `config.toml` / `hugo.toml` site params |
| `data/authors.json` (author info) | Hugo data file, or author taxonomy, or simple config params |
| `data/archives.json` (PDF archive listing) | Hugo data file (works identically) |
| `data/articles.json` (generated index) | Not needed — Hugo reads content directly |

---

## 8. Additional PRD Topics

Beyond the core feature set, the PRD should also consider:

1. **Content organization**: Hugo's content directory structure (sections,
   page bundles). Should articles use leaf bundles to co-locate images with
   their content?

2. **Theme approach**: Custom theme from scratch vs. adapting an existing Hugo
   theme. Given the site's specific design, a custom theme is likely best but
   worth discussing.

3. **New features to consider** (not in the current site):
   - **Search**: Client-side search via Pagefind, Fuse.js, or Lunr.js
   - **Comments**: Disqus, utterances, giscus, or none
   - **Dark mode**: Low-cost addition with modern CSS / Tailwind
   - **Related articles**: Hugo can auto-generate related content suggestions
   - **Reading time**: Hugo calculates this automatically

4. **Multilingual support**: The site is English-only but is about Ukraine. Hugo
   has excellent i18n support — worth considering in the architecture even if
   not implemented immediately.

5. **Build & deployment**: Hugo builds will be near-instant for 219 articles.
   Netlify supports Hugo natively with no special configuration needed beyond
   changing the build command.

---

## 9. Key Risks & Considerations

| Area | Risk | Notes |
|---|---|---|
| Content conversion | Vue syntax in 219 articles must be transformed | Automated script needed; specifics depend on PRD decisions |
| SEO continuity | Changing `/blog/{slug}/` URLs would break existing links/rankings | Preserve these URLs or configure Netlify `_redirects` |
| Contact form | Only dynamic feature; needs a static-compatible solution | Netlify Forms is the simplest option |
| Image references | Cloudinary URLs are embedded throughout content and templates | Whatever image approach is chosen, migration script must handle these |
| Analytics | GA Universal Analytics is deprecated | Must choose a replacement |
| Content fidelity | Ensure no articles lose content, formatting, or links during conversion | Migration script should include validation/diff checking |

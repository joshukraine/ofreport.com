# Architectural Decisions

This document records the key technology and architecture decisions for the
Hugo rebuild. Each section follows a Decision → Rationale → Implementation
pattern.

---

## Image Strategy: Cloudinary (Existing)

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

---

## Inline Components: Hugo Shortcodes

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

See [`05-shortcodes.md`](./05-shortcodes.md) for detailed shortcode
specifications.

---

## CSS: Tailwind CSS v4

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

---

## JavaScript: Alpine.js (Minimal)

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

---

## Contact Form: Netlify Forms

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

---

## Analytics: Umami

**Decision:** Use [Umami](https://umami.is) for privacy-friendly, cookie-free
analytics.

**Rationale:**

- Umami is now the standard analytics tool across all of the developer's
  projects (personal and Euro Team Outreach), so OFReport.com follows suit for
  a single operational surface and dashboard
- Privacy-friendly and cookie-free — no consent banner required
- Open source and self-hostable; lightweight tracking script
- Reference deployment to mirror for the snippet and instance pattern:
  [`euroteamoutreach/lens.euroteamoutreach.org`](https://github.com/euroteamoutreach/lens.euroteamoutreach.org)

GoatCounter and Plausible Community Edition were the other candidates
considered; Umami won on cross-project standardization.

**Implementation (Phase 14 — done):**

- `partials/analytics.html` emits the Umami tracking `<script>` (deferred, with
  `data-website-id` and the script `src`), double-gated so it stays inert until
  go-live: `hugo.IsProduction` **and** a non-empty `scriptUrl` + `websiteId`.
- The partial is included before `</body>` in `baseof.html`; switching or
  removing analytics means changing only this one file.
- The website ID and script `src` are configured via `hugo.toml`
  `[params.umami]` rather than hard-coded — **left empty in Phase 14**, so no
  script is emitted on any build.
- `data-domains="ofreport.com"` scopes tracking to the canonical host, so a
  stray `*.netlify.app` load during pre-cutover testing cannot pollute the
  production record.

**Deferred to Phase 16 (Deployment):**

- Populate `[params.umami]` with the live `scriptUrl`
  (`https://lens.euroteamoutreach.org/script.js`) and `websiteId`
  (`34d2cfa4-e623-418a-936d-670c9d163ead`) — the actual go-live flip.
- **Reuse the existing OFReport.com Umami website ID** (the same one the Nuxt
  site uses) so pageviews keep appending to the existing dashboard record — do
  not create a new Umami website.
- Verify pageviews land on the existing record once the Hugo site serves the
  live domain.

---

## Summary/Preview: Hugo `description` Field

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

---

## RSS Feed

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

---

## Newsletter: Mailchimp (Inline Forms Only)

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

---

## Lightbox: GLightbox

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

---

## Tag Consolidation

**Decision:** Consolidate `good and evil` and `good-and-evil` into a single
tag: `good-and-evil`.

**Action:** Handled by the migration script
(see [`06-content-migration.md`](./06-content-migration.md)).

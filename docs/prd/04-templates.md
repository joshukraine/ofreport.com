# Templates & Layouts

---

## Base Layout (`baseof.html`)

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

---

## Blog Listing Page

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

---

## Single Article Page

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

---

## Navigation

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

---

## SEO Partial (`seo.html`)

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

---

## Custom 404 Page

- SVG "404" graphic (port from existing site)
- Friendly message
- Link back to homepage and blog

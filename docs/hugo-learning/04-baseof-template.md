---
file_explained: layouts/_default/baseof.html
date: 2026-02-12
commit: ddd16278
---

# Base Template — `layouts/_default/baseof.html`

A line-by-line walkthrough of Hugo's base template, the outer HTML shell that
wraps every page on the site.

## The Big Picture

`baseof.html` is Hugo's **base template** — it defines the full HTML document
structure (`<!DOCTYPE>`, `<html>`, `<head>`, `<body>`) and designates a slot
where page-specific content gets injected. Every other template (`list.html`,
`single.html`, etc.) plugs into this shell via `define "main"`.

Think of it as the frame of a house — the walls, roof, and plumbing are always
the same. Each room (page type) fills in its own interior.

## Line-by-Line

### Lines 1–2 — Document boilerplate

```html
<!DOCTYPE html>
<html lang="en">
```

Standard HTML5 document declaration. `lang="en"` tells browsers and screen
readers the page content is in English. Nothing Hugo-specific here.

### Lines 3–8 — The `<head>` block

```text
<head>
  {{ partial "head.html" . }}
  {{ with (templates.Defer (dict "key" "global")) }}
    {{ partial "css.html" . }}
  {{ end }}
</head>
```

Two things happening here:

**`{{ partial "head.html" . }}`** (line 4) — Includes the `head.html` partial,
which contains meta tags, the page title, SEO tags, favicons, etc. The `.`
passes the full page context so the partial can access `.Title`,
`.Description`, and other page-level data.

**`{{ with (templates.Defer ...) }}`** (lines 5–7) — This is the most
interesting construct in the file. **`templates.Defer`** tells Hugo: "don't
execute this block now — wait until the *very end* of page rendering, then come
back and run it."

Why defer the CSS? Because of how Tailwind CSS v4 works with Hugo:

1. Hugo renders all templates, collecting every CSS class it encounters into
   `hugo_stats.json`
2. Only after *all* templates have rendered is `hugo_stats.json` complete
3. The `css.html` partial reads `hugo_stats.json` to purge unused CSS

If the CSS partial ran immediately (without `Defer`), it would process an
incomplete class list and the final CSS would be missing styles. Deferring
guarantees the CSS is built with the full picture.

- **`dict "key" "global"`** — The `"key"` parameter is a cache key. Using
  `"global"` means this deferred block is executed once for the entire site,
  not once per page. Since the CSS is the same on every page, this avoids
  redundant work.
- **`with`** here is used for its return value — `templates.Defer` returns a
  special placeholder that Hugo swaps out later. The `with` block ensures the
  placeholder is actually output into the HTML.

### Line 9 — Body opening

```html
<body class="min-h-screen bg-gray-100 font-serif text-gray-900">
```

Tailwind utility classes setting site-wide defaults: minimum full viewport
height, light gray background, serif font, and dark text. Every page inherits
these.

### Line 10 — Header

```text
{{ partial "header.html" . }}
```

The site header (logo, navigation, mobile menu). Appears on every page since
it's in `baseof.html`.

### Lines 11–13 — The main content slot

```text
<main class="pt-16">
  {{ block "main" . }}{{ end }}
</main>
```

This is the **key line of the entire file**. **`block "main" .`** defines a
named placeholder with two behaviors:

1. **If a child template defines `{{ define "main" }}`** — the child's content
   replaces this block entirely. This is what `blog/list.html`,
   `blog/single.html`, and every other template does.
2. **If no child template defines it** — whatever is between
   `{{ block "main" . }}` and `{{ end }}` renders as a fallback. Here the
   fallback is empty, so an undefined page would just show a blank `<main>`.

The `.` after `"main"` passes the current page context into the block, which is
why child templates can access `.Title`, `.Content`, etc. at their top level.

`pt-16` adds top padding to account for the fixed header.

### Lines 14–17 — Footer and scripts

```text
{{ partial "footer.html" . }}
{{ partial "glightbox.html" . }}
{{ partial "analytics.html" . }}
<script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3/dist/cdn.min.js"></script>
```

- **`footer.html`** — Site footer, same on every page.
- **`glightbox.html`** — The image lightbox library. Included globally so it's
  available on article pages that use the `figure` shortcode.
- **`analytics.html`** — Tracking snippet (likely Plausible or similar).
- **Alpine.js** — Loaded from CDN with `defer` so it doesn't block page
  rendering. Alpine powers lightweight interactivity like the mobile menu
  toggle. This is the one script tag written directly in `baseof.html` rather
  than in a partial.

## Key Concepts in This Template

| Concept | What it does |
|---|---|
| `baseof.html` | Hugo's base template — the outer HTML shell for every page |
| `{{ block "main" . }}` | Named placeholder that child templates fill via `{{ define "main" }}` |
| `templates.Defer` | Delays execution until all templates have rendered — critical for Tailwind CSS purging |
| `dict "key" "global"` | Cache key ensuring deferred CSS runs once for the whole site, not per page |
| Partials in baseof | Anything here appears on every page (header, footer, scripts) |
| `defer` (HTML attribute) | Standard HTML — tells the browser to load the script without blocking rendering |

---
file_explained: layouts/partials/article-card.html
date: 2026-02-12
commit: ddd16278
---

# Article Card Partial — `layouts/partials/article-card.html`

A line-by-line walkthrough of the article card partial, which renders each blog
post preview on the listing page. This partial is called from `layouts/blog/list.html`.

## How This Partial Fits In

From `list.html`, this partial is called like:

```text
{{ partial "article-card.html" (dict "page" (index $paginator.Pages 0) "featured" true) }}
```

A `dict` (dictionary) is passed in as the context. That means inside this
partial, `.` is **not** a page — it's the dictionary
`{ "page": <article>, "featured": true/false }`. The first two lines unpack it.

## Line-by-Line

### Lines 1–3 — Unpacking the context

```text
{{- $page := .page -}}
{{- $featured := default false .featured -}}
{{- $preset := cond $featured "featured" "regular" -}}
```

- **`$page := .page`** — Pulls the article page object out of the dict and
  stores it in `$page`. From here on, `$page` is used instead of `.` to access
  page properties.
- **`default false .featured`** — **`default`** is a safety net: if `.featured`
  wasn't passed (or is nil), use `false`. This makes the partial safe to call
  without the `featured` key.
- **`cond $featured "featured" "regular"`** — **`cond`** is Hugo's ternary
  function. It reads: "if `$featured` is true, return `"featured"`, otherwise
  return `"regular"`." The result is stored in `$preset`, which is used for
  Cloudinary image sizing.

### Line 5 — Conditional CSS classes

```text
<article class="{{ if $featured }}...classes...{{ else }}...classes...{{ end }}">
```

An `if`/`else` *inside an HTML attribute*. This is a common Hugo pattern — you
can embed template logic anywhere in the markup. Featured articles get a
horizontal layout (`lg:flex-row`), regular ones stay vertical.

### Lines 6–17 — Cover image block

```text
{{- with $page.Params.cover }}
  {{- $imgURL := partial "cloudinary-url.html" (dict "src" . "preset" $preset) }}
```

- **`$page.Params.cover`** — `.Params` accesses the frontmatter of an article.
  So this reads the `cover:` field from the article's YAML.
- **`with`** again serves double duty: it checks that `cover` exists *and*
  rebinds `.` to the cover URL string inside the block.
- **`partial "cloudinary-url.html"`** — Calls *another* partial to build the
  optimized Cloudinary image URL. Partials can call other partials — they
  compose like functions.
- **`(dict "src" . "preset" $preset)`** — Passes the cover URL (`.`, which is
  the cover string thanks to `with`) and the preset name to the Cloudinary
  partial.

The rest of this block is standard HTML — an `<img>` tag and an overlay `<div>`
for a subtle ring effect. Note `loading="lazy"` for browser-native lazy loading.

### Lines 21–23 — Date formatting

```text
<time datetime="{{ $page.Date.Format "2006-01-02" }}" class="text-gray-500">
  {{- $page.Date.Format "January 2, 2006" -}}
</time>
```

Hugo uses Go's date formatting, which is based on a **reference date**:
`Mon Jan 2 15:04:05 MST 2006`. Instead of `YYYY-MM-DD`, you write `2006-01-02`.
Instead of `%B %d, %Y`, you write `January 2, 2006`. The reference date is
always the same — you just rearrange its components to define your format.

Two formats are used here:

- `"2006-01-02"` — machine-readable ISO format for the `datetime` attribute
- `"January 2, 2006"` — human-readable for display

### Lines 24–28 — Tag loop

```text
{{- range $page.Params.tags }}
  <span class="...">{{- . -}}</span>
{{- end }}
```

**`range`** loops over the article's tags array. Inside the loop, `.` becomes
the current tag string. Each tag renders as a styled badge.

### Lines 33–36 — The clickable title with overlay trick

```text
<h3 class="... group-hover:text-gray-600">
  <a href="{{ $page.Permalink }}">
    <span class="absolute inset-0"></span>
    {{ $page.Title }}
  </a>
</h3>
```

- **`$page.Permalink`** — The full URL to the article (e.g.,
  `/blog/2024-06-13-my-post/`).
- **`<span class="absolute inset-0">`** — This is a Tailwind UI pattern: an
  invisible span that stretches over the entire card, making the whole card area
  clickable, not just the text. The `group` class on the parent `<div>` and
  `group-hover:` on the `<h3>` make the title change color when hovering
  anywhere on the card.

### Lines 38–40 — Description

```text
{{- with $page.Description }}
  <p class="...">{{ . }}</p>
{{- end }}
```

**`$page.Description`** pulls from the `description:` field in frontmatter.
`with` ensures nothing renders if there's no description.

### Lines 45–47 — Author

```text
{{- with $page.Params.author }}
  <p class="font-semibold text-gray-900">{{ . }}</p>
{{- end }}
```

Same pattern — `with` checks and rebinds, `.` becomes the author string.

### Lines 49–62 — PDF download link

```text
{{- with $page.Params.pdf }}
  <a href="{{ site.Params.pdfBase }}{{ . }}" ...>
```

- **`site.Params.pdfBase`** — **`site`** is a global object that accesses values
  from `hugo.toml`. This pulls the `pdfBase` parameter (the CloudFront URL
  prefix).
- The PDF filename (`.`) is appended to the base URL to form the full download
  link.
- **`relative z-10`** on the link — The `z-10` ensures this link sits *above*
  that invisible `<span class="absolute inset-0">` from the title, so clicking
  "PDF" opens the PDF rather than navigating to the article. Without it, the
  card overlay would intercept the click.

## Key Patterns to Remember

| Pattern | What it does |
|---|---|
| `dict` + unpacking | Pass named arguments to partials (like function parameters) |
| `with` | Check-and-rebind in one step — avoids nested `if` + variable access |
| `default` | Provide fallback values for optional parameters |
| `cond` | Ternary/inline conditional — pick one of two values |
| `$page.Params.x` | Access any frontmatter field from an article |
| `site.Params.x` | Access global config values from `hugo.toml` |
| Partials calling partials | Composable, like functions calling functions |

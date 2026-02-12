---
file_explained: layouts/blog/list.html
date: 2026-02-12
commit: ddd16278
---

# Blog List Template — `layouts/blog/list.html`

A line-by-line walkthrough of the blog listing template, explaining Hugo's
template syntax and concepts as they appear.

## The Big Picture

This template defines the **main content block** for the blog listing page
(e.g., `/blog/`). It connects to `baseof.html` via the `define`/`block`
mechanism — `baseof.html` has a `{{ block "main" . }}` placeholder, and this
template fills it in.

## Template Tags Explained

### `{{ define "main" }}` ... `{{ end }}` (lines 1, 43)

This wraps the entire file. It says "this is the content that should be injected
into the `"main"` block of `baseof.html`." Every template that extends `baseof`
needs one of these.

### `{{ .Title }}` (line 6)

The double curly braces `{{ }}` output a value. The dot (`.`) represents the
**current context** — on this page, it's the blog section's page object. So
`.Title` renders the title from `content/blog/_index.md`.

### `{{- with .Content }}` ... `{{- end }}` (lines 8–10)

- **`with`** is like an `if` + context shift. It checks if `.Content` exists; if
  it does, the block executes and the dot (`.`) *inside* the block becomes
  `.Content` itself. That's why line 9 uses `{{ . }}` — it means "the content we
  just checked for."
- **The dash `-`** in `{{-` trims whitespace before the tag. `{{- ... -}}`
  trims both sides. This keeps the rendered HTML clean — without it you'd get
  extra blank lines.

### `{{- $paginator := .Paginate .Pages -}}` (line 12)

- **`$paginator`** is a **variable** (Hugo variables start with `$`).
- **`:=`** is the assignment operator (declare and assign).
- **`.Paginate .Pages`** calls Hugo's built-in pagination, splitting `.Pages`
  (all blog posts) into chunks (default 10 per page). The returned paginator
  object has properties like `.HasPrev`, `.HasNext`, and `.Pages` (the posts
  for the *current* chunk).

### `{{- $isFirstPage := not $paginator.HasPrev -}}` (line 13)

A boolean variable. If there's no previous page, we're on page 1. This drives
the featured-article layout.

### `{{- if and $isFirstPage $paginator.Pages }}` (line 16)

**`if`** is a conditional. **`and`** is a function (not an operator) — it takes
two arguments. This reads: "if we're on the first page AND there are pages to
show."

### `{{/* ... */}}` (lines 17, 20, 30)

These are **comments**. They don't appear in the rendered HTML. Useful for
documenting intent.

### `{{ partial "article-card.html" (dict "page" ... "featured" true) }}` (line 18)

- **`partial`** includes another template from `layouts/partials/`.
- **`dict`** creates a dictionary (key-value map) to pass as the context. Here,
  the partial receives `.page` (the article) and `.featured` (a boolean) so it
  can render differently for featured vs. regular cards.

### `{{- $rest := after 1 $paginator.Pages -}}` (line 21)

**`after 1`** skips the first item, returning everything from index 1 onward.
Since the first article was already rendered as featured, this gives us the
remaining articles.

### `{{ index $paginator.Pages 0 }}` (line 18)

**`index`** accesses an element by position — here, the first article (index 0).

### `{{- range $rest }}` ... `{{- end }}` (lines 24–26)

**`range`** is Hugo's loop. It iterates over the collection, and inside the loop
the dot (`.`) becomes the current item (each blog post). Similar to a `for...of`
loop in JavaScript.

### `{{ partial "pagination.html" . }}` (line 39)

Includes the pagination partial, passing `.` (the full page context) so it can
access the paginator and render page links.

## The Dot (`.`) — The Key Concept

The single most important thing in Hugo templates is understanding what `.`
means at any given point:

- **Top level** of this template: `.` is the blog section page
- **Inside `with .Content`**: `.` becomes the content string
- **Inside `range`**: `.` becomes the current loop item
- **Inside a partial**: `.` is whatever you passed as the second argument

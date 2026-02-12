---
file_explained: layouts/partials/pagination.html
date: 2026-02-12
commit: ddd16278
---

# Pagination Partial — `layouts/partials/pagination.html`

A line-by-line walkthrough of the pagination partial, which renders a
"Previous / 1 ... 3 **4** 5 ... 10 / Next" navigation bar below the blog
listing. Called from `layouts/blog/list.html`.

## The Big Picture

This partial is called from `list.html` as:

```text
{{ partial "pagination.html" . }}
```

The `.` passed in is the full page context (the blog section page), which is
why line 1 can access `.Paginator`.

## Line-by-Line

### Line 1 — Getting the paginator

```text
{{- $paginator := .Paginator -}}
```

`.Paginator` is a built-in Hugo property on any list page. It returns the same
paginator object that was created by `.Paginate` in `list.html`. Hugo caches
it — once `.Paginate` is called on a page, `.Paginator` returns that same
instance. The partial stores it in `$paginator` for convenience.

### Line 3 — Guard clause

```text
{{- if gt $paginator.TotalPages 1 -}}
```

**`gt`** is Hugo's "greater than" function — comparison operators are functions,
not symbols. This reads: "if total pages > 1." If there's only one page of
results, the entire `<nav>` is skipped. You've seen `and` and `not` already;
Hugo also has `lt`, `ge`, `le`, `eq`, and `ne`.

### Lines 4–5 — Convenience variables

```text
{{- $current := $paginator.PageNumber -}}
{{- $total := $paginator.TotalPages -}}
```

Storing frequently used values in variables. This is just for readability —
avoids repeating `$paginator.PageNumber` throughout the template.

### Lines 8–9 — The sliding window

```text
{{- $windowStart := math.Max 1 (sub $current 2) -}}
{{- $windowEnd := math.Min $total (add $current 2) -}}
```

This is the core logic. Instead of showing all page numbers (which could be
dozens), it shows a **window of 5 pages** centered on the current page.

- **`sub $current 2`** — Subtraction function. If you're on page 6, this
  gives 4.
- **`math.Max 1 ...`** — Clamps the start so it never goes below 1.
- **`add $current 2`** — Addition function. Page 6 gives 8.
- **`math.Min $total ...`** — Clamps the end so it never exceeds the last page.

So on page 6 of 10, the window would be pages 4–8. Hugo doesn't have `+` or
`-` operators in templates — you use `add`, `sub`, `mul`, `div` functions
instead.

### Lines 14–21 — Previous link

```text
{{- if $paginator.HasPrev }}
  <a href="{{ $paginator.Prev.URL }}">...Previous...</a>
{{- end }}
```

- **`$paginator.HasPrev`** — Boolean, true if there's a previous page.
- **`$paginator.Prev.URL`** — The URL of the previous page. `.Prev` is a pager
  object with its own `.URL` property.

Only renders when there's somewhere to go back to. The SVG inside is a
left-arrow icon.

### Lines 26–27 — Looping over all pagers

```text
{{- range $paginator.Pagers -}}
  {{- $pageNum := .PageNumber -}}
```

**`$paginator.Pagers`** is a slice of all pager objects (one per page of
results). The `range` loop iterates through every one of them, and
`.PageNumber` captures which page number each pager represents.

This is the key insight: the loop visits *every* page, but the `if` conditions
inside decide which ones actually render. It's a "loop and filter" pattern
rather than "loop over only what you need."

### Lines 29–35 — First page + leading ellipsis

```text
{{- if and (eq $pageNum 1) (gt $windowStart 1) }}
  <a href="{{ .URL }}" ...>1</a>
  {{- if gt $windowStart 2 }}
    <span ...>&hellip;</span>
  {{- end }}
{{- end }}
```

This block only fires when `$pageNum` is 1 *and* the window doesn't start at 1
(meaning page 1 would otherwise be hidden). It ensures page 1 is always visible.

- **`&hellip;`** is the HTML entity for "..." (ellipsis).
- The ellipsis only shows if there's a gap — `gt $windowStart 2` means "the
  window starts at 3 or later," so there are hidden pages between 1 and the
  window.

### Lines 38–44 — Pages within the window

```text
{{- if and (ge $pageNum (int $windowStart)) (le $pageNum (int $windowEnd)) }}
  {{- if eq $pageNum $current }}
    <a ... aria-current="page" class="...border-blue-500...text-blue-600">{{ $pageNum }}</a>
  {{- else }}
    <a ... class="...text-gray-500...">{{ $pageNum }}</a>
  {{- end }}
{{- end }}
```

- **`ge`** (greater-or-equal), **`le`** (less-or-equal) — Only render page
  numbers that fall within the window.
- **`int`** — Type cast. `math.Max`/`math.Min` return floats, but `$pageNum`
  is an int. `int` converts so the comparison works.
- **`eq $pageNum $current`** — The current page gets highlighted styling (blue
  border and text), while other pages get neutral gray. The
  `aria-current="page"` attribute is an accessibility best practice.

### Lines 47–53 — Last page + trailing ellipsis

```text
{{- if and (eq $pageNum $total) (lt $windowEnd $total) }}
  {{- if lt $windowEnd (sub $total 1) }}
    <span ...>&hellip;</span>
  {{- end }}
  <a href="{{ .URL }}" ...>{{ $total }}</a>
{{- end }}
```

Mirror image of the first-page logic. If the window ends before the last page,
this ensures the last page number is always visible, with an ellipsis if there's
a gap.

### Lines 59–66 — Next link

```text
{{- if $paginator.HasNext }}
  <a href="{{ $paginator.Next.URL }}">Next...</a>
{{- end }}
```

Same pattern as Previous but with `.HasNext` and `.Next.URL`.

## New Concepts in This Template

| Concept | What it does |
|---|---|
| `.Paginator` | Built-in accessor for the cached paginator on list pages |
| `gt`, `lt`, `ge`, `le`, `eq`, `ne` | Comparison functions (not operators) |
| `add`, `sub` | Arithmetic functions (Hugo has no `+`/`-` operators in templates) |
| `math.Max`, `math.Min` | Clamp values to a range |
| `int` | Type casting — needed when mixing float results with int comparisons |
| `$paginator.Pagers` | Slice of all pager objects — loop + filter pattern |
| `$paginator.HasPrev`/`.HasNext` | Booleans for navigation availability |
| `$paginator.Prev.URL`/`.Next.URL` | URLs for adjacent pages |
| `aria-current="page"` | Accessibility attribute marking the active page |

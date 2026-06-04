# Shortcode Specifications

---

## Figure/Image Shortcode

**Purpose:** Display a Cloudinary-hosted image with optional caption, wrapped
in a lightbox-compatible link.

**Usage:**

```text
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

- Implemented as a custom shortcode (`layouts/shortcodes/figure.html`); Hugo's
  built-in `figure` doesn't build Cloudinary URLs or emit lightbox attributes.
- `src` accepts both a full Cloudinary URL and a bare public ID. The
  `cloudinary-url.html` partial expands a bare public ID to
  `{cloudinaryBase}/image/upload/{id}` before applying transforms, so every
  caller of that partial gets this for free.
- **Sizing:** the inline display `<img>` uses the `figure` preset
  (`c_scale,f_auto,q_auto,w_768`) — the article body width — to keep pages
  light, while the lightbox `<a href>` uses the `lightbox` preset
  (`c_scale,f_auto,q_auto,w_1600`) for a larger zoom view. Display is
  intentionally *not* the uncapped `article` preset, which is reserved for the
  full-width cover image in `blog/single.html`.
- Rendered with `not-prose` so it matches the cover-image figure styling
  (`rounded-xl`, `loading="lazy"`); the caption is centered. `figcaption` and
  `data-description` are emitted only when `caption` is provided, and `alt`
  falls back to `caption`.
- GLightbox CSS/JS activation is **Phase 13** — this shortcode emits
  lightbox-compatible markup now and is forward-compatible.

---

## Callout Shortcode

**Purpose:** Highlighted box for important information, CTAs, or PDF download
links.

**Usage:**

```text
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

---

## Button Shortcode

**Purpose:** Styled CTA link.

**Usage:**

```text
{{< button href="/donate/" text="Support Our Ministry" >}}
{{< button href="https://example.com" text="Visit Site" external=true >}}
```

---

## SVG Shortcode

**Purpose:** Embed an SVG file from the assets directory.

**Usage:**

```text
{{< svg name="bible-first-logo" >}}
```

**Implementation:** Reads SVG from `assets/img/{name}.svg` and outputs inline.

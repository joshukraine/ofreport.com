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

- Evaluate whether Hugo's built-in `figure` shortcode can handle Cloudinary
  URLs and lightbox attributes, or if a custom shortcode is needed
- The shortcode should accept both full Cloudinary URLs and public IDs
- Apply appropriate Cloudinary transformations for display size vs. lightbox
  size

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

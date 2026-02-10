# New Features, Risks & Future Considerations

---

## New Features

These features are not present on the current site but are low-cost additions
in Hugo.

### Reading Time

Hugo calculates reading time automatically via `.ReadingTime` (returns minutes).
Display on article pages alongside the date and author.

### Related Articles

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

### Image Lightbox (Click-to-Enlarge)

Not present on the current site. All article images will be viewable in a
clean, full-screen lightbox overlay via GLightbox
(see [`01-architecture.md`](./01-architecture.md)).

### Search (Optional, Deferred)

Client-side search via Pagefind is a strong candidate if search is desired
later. Pagefind indexes the built site at deploy time and provides a
lightweight search UI with no server-side component. Can be added post-launch
without architectural changes.

---

## Risks & Mitigations

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

## Out of Scope (Future Considerations)

- **Comments system** (Disqus, giscus, etc.) — can be added later
- **Dark mode** — can be added with Tailwind's dark mode support
- **Multilingual content** — Hugo supports i18n natively; architecture doesn't
  prevent future addition
- **CMS integration** — Decap CMS or similar could be added for non-technical
  editors
- **Image migration to local** — if Cloudinary becomes impractical, images
  could be moved to Hugo page bundles in the future
- **Client-side search** — Pagefind can be added post-launch

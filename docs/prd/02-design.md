# Design & Visual Identity

---

## Design Philosophy

The Hugo rebuild should **preserve the blog's general identity and structure**
while **refreshing the visual details**. This is not a redesign from scratch,
but an opportunity to improve polish, spacing, typography, and overall feel.

**What to preserve:**

- General page layout structure (header, content area, footer)
- Blog listing with featured article + grid layout
- Article page structure (cover image, title, meta, content)
- Navigation structure and menu items

**What is open for improvement:**

- Font choices and typographic scale — the existing fonts (Lato, Noto Serif,
  Mate SC) can be kept, changed, or refined
- Color palette — the existing blues and grays are a starting point, not a
  constraint. Better or more modern color choices are welcome
- Spacing and whitespace — improve breathing room and visual hierarchy
- Component styling — article cards, tag badges, buttons, callouts can all
  be refreshed
- Mobile experience — improve responsive behavior with modern CSS/Tailwind

---

## Design Reference (Current Site)

These values are documented for reference. They are **not** requirements to
replicate exactly.

**Current color palette:**

| Token     | Hex        | Usage               |
| --------- | ---------- | ------------------- |
| Blue-500  | `#2bb0ed`  | Primary accent      |
| Blue-600  | `#1992d4`  | Links, hover states |
| Blue-900  | `#0f2847`  | Footer background   |
| Blue-dark | `#024775`  | Dark accents        |
| Gray-100  | light gray | Page background     |

**Current fonts (via Google Fonts):**

| Font       | Current Usage   | Weight(s) |
| ---------- | --------------- | --------- |
| Lato       | Headings        | 700       |
| Noto Serif | Body text       | 400, 700  |
| Mate SC    | Decorative text | —         |

**Current responsive breakpoints:**

| Name | Width  |
| ---- | ------ |
| xs   | 460px  |
| sm   | 640px  |
| md   | 768px  |
| lg   | 1024px |
| xl   | 1280px |

---

## Tailwind Plus as Design Reference

The developer has a **Tailwind Plus** (UI Components) subscription. Licensed
component examples should be used as design references when building UI
elements (navigation bars, article cards, footers, forms, etc.).

See the Tailwind Plus Workflow section in
[`00-overview.md`](./00-overview.md) for details on how to use Tailwind Plus
snippets with Claude Code.

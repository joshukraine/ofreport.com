# Content Migration

---

## Migration Script

**Language:** Ruby

**Rationale:** The developer is highly proficient in Ruby and will be better
able to understand, debug, and modify the script. The transformation tasks
(file I/O, YAML parsing, regex text replacement) are well-suited to Ruby.

**Script responsibilities:**

1. **Read** each markdown file from the source Nuxt project's
   `content/articles/` directory

2. **Transform frontmatter:**
   - Rename `preview` → `description` (strip any markdown formatting)
   - Remove `basename` and `iso8601Date` fields (build-generated, not needed)
   - Add explicit `slug` field derived from the filename (to preserve existing
     URLs)
   - Preserve all other fields: `title`, `date`, `author`, `tags`, `cover`,
     `caption`, `pdf`

3. **Transform content body:**
   - Convert `<article-image>` → Hugo figure shortcode
   - Convert `<article-callout>` → `{{< callout >}}` shortcode
   - Convert `<article-button>` → `{{< button >}}` shortcode
   - Convert `<article-svg>` → `{{< svg >}}` shortcode
   - Convert `<article-divider>` → markdown `---`
   - Remove `<article-spacer>` instances

4. **Fix tags:**
   - Replace `good and evil` with `good-and-evil` in all tag arrays

5. **Write** transformed files to the Hugo project's `content/blog/` directory

6. **Validate:**
   - Compare article count: input vs. output
   - Verify all frontmatter fields are present
   - Check for any remaining Vue component syntax (`<article-` patterns)
   - Flag articles that may need manual review (see Legacy WordPress Articles
     below)
   - Generate a diff report for manual review

---

## Legacy WordPress Article Styling

A number of older articles on the existing site were originally published on
a WordPress blog and were migrated to the Nuxt site without fully updating
their formatting. There is an existing unmerged pull request (PR #93 on the
current GitHub repo) that attempted to address some of these styling
inconsistencies.

**Approach for the Hugo migration:**

- The migration script should process all 223 articles consistently
- After migration, a manual review pass should identify articles with
  formatting issues (inconsistent headings, raw HTML, missing images, broken
  layout patterns)
- The migration script's validation step should flag articles that contain
  raw HTML or unusual patterns that may indicate legacy formatting issues
- Fixing these articles is part of the migration scope — the goal is that
  all articles render cleanly and consistently in the new Hugo site
- PR #93 from the existing repo should be consulted as a reference for known
  problem articles

---

## Migration Checklist

- [ ] All 223 articles converted
- [ ] All 5 static pages created in Hugo
- [ ] Frontmatter schema matches Hugo expectations
- [ ] All Vue component syntax converted to shortcodes
- [ ] Duplicate tag consolidated
- [ ] No content lost (diff validation)
- [ ] Legacy WordPress articles reviewed and styled consistently
- [ ] URLs match existing structure (`/blog/{slug}/`)
- [ ] Cover images display correctly (Cloudinary URLs intact)
- [ ] PDF links work (CloudFront URLs intact)
- [ ] RSS feed generates correctly at `/feed.xml`
- [ ] All tags render with correct article counts
- [ ] Pagination works on blog and tag pages
- [ ] Contact form submits successfully via Netlify
- [ ] 404 page displays correctly
- [ ] Site passes Lighthouse audit (performance, SEO, accessibility)

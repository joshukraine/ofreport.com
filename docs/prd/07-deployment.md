# Deployment & Source Control

---

## Development Repository

**Decision:** Develop the Hugo site in a **new, separate repository** during
the build process.

**Rationale:**

- Keeps the existing Nuxt site intact and deployable throughout development
- Provides a clean Git history for the Hugo project
- Avoids branch confusion and merge complexity
- The existing repo remains available as a reference for content and behavior

**Recommended approach:**

1. **During development:** Create a new repo (e.g., `ofreport.com-hugo` or
   similar) for all Hugo development work
2. **At launch:** When the Hugo site is ready to go live:
   - Archive or rename the old Nuxt repo to `ofreport.com-nuxt`
   - Rename the Hugo repo to `ofreport.com` (or push to a fresh repo with
     that name)
   - Update Netlify to build from the new repo
3. **Post-launch:** The old repo remains archived as a historical reference

**Alternative:** If you prefer to keep everything in one repo, you could use
a long-lived `hugo-rebuild` branch, but this tends to create more complexity
than the separate-repo approach.

---

## `.gitignore`

Key entries for the Hugo project:

```text
# Hugo build output
public/
resources/_gen/

# Node modules
node_modules/

# Hugo stats (regenerated on build)
hugo_stats.json

# Tailwind Plus licensed snippets (must not be committed)
docs/tailwind_plus/

# OS files
.DS_Store
Thumbs.db

# Environment files
.env
```

---

## Netlify Configuration (`netlify.toml`)

```toml
[build]
  publish = "public"
  command = "npm install && hugo --gc --minify"

[build.environment]
  HUGO_VERSION = "0.155.2"
  HUGO_ENV = "production"
  NODE_VERSION = "22"

[context.deploy-preview]
  command = "npm install && hugo --gc --minify --buildFuture -b $DEPLOY_PRIME_URL"

[context.deploy-preview.environment]
  HUGO_VERSION = "0.155.2"

[context.branch-deploy]
  command = "npm install && hugo --gc --minify -b $DEPLOY_PRIME_URL"

[context.branch-deploy.environment]
  HUGO_VERSION = "0.155.2"

# Redirects for SEO continuity
[[redirects]]
  from = "/blog/page/1"
  to = "/blog/"
  status = 301

# Security headers
[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
```

---

## Build Performance

Hugo builds are near-instant for 223 articles. Expected build time: under 1
second for Hugo itself, plus a few seconds for Tailwind CSS processing.

---

## Domain & DNS

No changes needed — the site remains on the same domain (`ofreport.com`) and
Netlify hosting. Only the build command, publish directory, and source repo
change.

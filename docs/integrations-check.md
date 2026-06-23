# Integrations Verification

**Issue:** #179 (launch-readiness epic #150 §4)
**Last run:** 2026-06-23 — RSS feed ✅ validated; Mailchimp / Netlify Forms / Umami pending (see status).

A pre-cutover gate for the site's four external integrations. Like the URL-parity (`docs/url-parity/`) and link-check (`docs/link-check.md`) gates, it proves each integration rather than assuming it. **Only two integrations can be fully verified before cutover** — the other two are production-only by design and are confirmed on cutover day (#150 §7 steps 6–7). This doc records the evidence and keeps that boundary explicit.

## Status at a glance

| Integration | When verifiable | Status |
| --- | --- | --- |
| **RSS feed** (Phase 9) | Now (preview) | ✅ **PASS** — well-formed, 10 items, all cover enclosures resolve |
| **Mailchimp signup forms** (Phase 12) | Now (preview) | ⬜ Pending account-side submit |
| **Netlify Forms** detection + honeypot (Phase 11) | Now (preview, partial) | ⬜ Pending dashboard check |
| **Umami analytics** (Phase 14) | Cutover only | ⬜ Deferred — production-gated by design (#150 §7) |

Preview base for all "now" checks: `https://ofreport-dev.netlify.app`

---

## 1. RSS feed → Mailchimp ✅ PASS (2026-06-23)

The feed is the input to Mailchimp's RSS-to-email campaigns, so the URL must be stable and the markup must render. URL parity (#173) already proved `/feed.xml` returns `200` and is a valid feed; this is the structural + content validation.

### How to re-run

```bash
curl -s https://ofreport-dev.netlify.app/feed.xml -o /tmp/feed.xml
xmllint --noout /tmp/feed.xml && echo "well-formed"
# probe every cover enclosure resolves:
grep -oE 'enclosure url="[^"]+"' /tmp/feed.xml | sed -E 's/enclosure url="([^"]+)"/\1/' \
  | while read u; do echo "$(curl -s -o /dev/null -w '%{http_code}' -I "$u")  $u"; done
```

### Findings

- **Well-formed** (`xmllint --noout` clean). RSS 2.0 with `atom:` and `dc:` namespaces declared.
- **Channel** carries `title`, `link`, `description`, `generator`, `language` (`en-US`), `copyright`, `lastBuildDate`, and an `atom:link` self-reference.
- **Self-reference is launch-ready:** even on the preview build, `<atom:link href="https://ofreport.com/feed.xml" …>` and channel `<link>` point at the **production** domain — so Mailchimp continuity is preserved (the feed URL Mailchimp polls never changes across cutover). This is the single most important RSS fact for the migration.
- **10 items** (explicit `[services.rss] limit = 10` in `hugo.toml`), newest → oldest:
  - `Wed, 27 May 2026` → `Mon, 24 Feb 2025`
- **Each item** has `title`, `link` (absolute, production permalink), `pubDate` (RFC-822), `dc:creator`, `guid` (= permalink), a **curated excerpt** `description` (the excerpt model from CHANGELOG 2026-06-06, not full HTML), and a cover `<enclosure>`.
- **All 10 cover enclosures resolve `200`** (the `rss` Cloudinary preset, `w_560` — a different transform than the cover probe's `hero`; both resolve, consistent with Cloudinary's all-or-nothing derivative behavior).

### Minor / cosmetic (not blockers)

- `enclosure` emits `length="0"` (`layouts/_default/rss.xml:53`) — Hugo can't know the remote Cloudinary byte size. Universally tolerated by readers and Mailchimp; the RSS spec wants real bytes but this is the standard Hugo-remote-image compromise.
- `enclosure` emits `type="image/jpeg"` for every item, but several covers are `.png` (and `f_auto` actually delivers webp/avif). The `type` is an advisory hint, so this is harmless — but it's inaccurate. **Possible tiny future fix:** derive the type from the source extension, or drop the attribute. Low priority; out of scope for this gate.

### Account-side confirm (Joshua) — optional but recommended

- [ ] Open `https://ofreport-dev.netlify.app/feed.xml` in a feed reader (or the [W3C Feed Validator](https://validator.w3.org/feed/)) and confirm titles, excerpts, dates, and a cover image render as expected.

---

## 2. Mailchimp signup forms ⬜ Pending

The embedded forms POST directly to `OFReport.us6.list-manage.com` (`layouts/partials/mailchimp-form.html`) — **independent of the Hugo/Netlify environment**, so a preview submit exercises the real production path. Three placements to verify:

| Placement | Where |
| --- | --- |
| Homepage | `https://ofreport-dev.netlify.app/` |
| Article footer | any article, e.g. `https://ofreport-dev.netlify.app/blog/2026-05-27-teaching-serving-standing/` |
| Subscribe page | `https://ofreport-dev.netlify.app/subscribe/` |

### Account-side confirm (Joshua)

- [ ] Submit a real test address from **each** of the three placements.
- [ ] Confirm each submission lands in the Mailchimp audience (and the double-opt-in email arrives, if enabled).
- [ ] Note any styling/UX issues with the inline success/error states.

> _Evidence (fill in after testing): which placements tested, test address used, audience confirmation._

---

## 3. Netlify Forms (contact) ⬜ Pending — partial pre-cutover

The contact form (`layouts/partials/contact-form.html`) is auto-detected by Netlify on build. **Detection + honeypot are testable on the preview; notification routing is production-only** — the live Nuxt site uses an AWS Lambda (not Netlify Forms), so routing must be set up fresh on the production site at cutover (#150 §7 step 6). The Lambda retires with the Nuxt site; nothing to migrate.

Form: `https://ofreport-dev.netlify.app/contact/`

### Account-side confirm (Joshua) — on the `ofreport-dev` site

- [ ] Confirm the form appears under the site's **Forms** tab (auto-detected on the latest build).
- [ ] Submit the contact form; confirm the submission is captured.
- [ ] Confirm the honeypot field rejects an obvious bot submission (does not appear as a real submission).

> _Evidence (fill in after testing): form name detected, submission captured Y/N, honeypot behavior._

### Deferred to cutover (#150 §7 step 6–7)

- [ ] Set up notification routing on the **production** Netlify site (new — this site has no Forms config today).
- [ ] After cutover, submit the contact form on `ofreport.com` and confirm routing + spam handling.

---

## 4. Umami analytics ⬜ Deferred — production only

The `analytics.html` partial is **double-gated on `hugo.IsProduction` + a configured `scriptUrl`/`websiteId`**, and `data-domains="ofreport.com"` scopes tracking to the canonical host. It emits **nothing** on previews by design, so it cannot be verified before cutover — and that's the correct, safe behavior (a stray `*.netlify.app` load can never pollute the dashboard).

`[params.umami]` in `hugo.toml` is intentionally blank today.

### Deferred to cutover (#150 §7 step 6–7)

- [ ] Populate live `scriptUrl` + `websiteId` (reuses the existing OFReport.com website ID `34d2cfa4-e623-418a-936d-670c9d163ead`, so the dashboard record continues unbroken).
- [ ] Confirm events fire on `ofreport.com` in production **only**, and never on the preview.

> **Optional pre-stage:** the config can be filled in ahead of cutover since the partial stays inert until production — this just needs the Umami instance `scriptUrl`. Leaving blank per the documented plan is also fine.

---

## Cross-check: nothing dropped

The two cutover-only integrations (Umami firing, Netlify Forms notification routing) and the live Mailchimp RSS campaign send (#150 §8 post-launch) remain tracked in epic #150. This doc closes the **preview-verifiable** bucket of §4; it does not close §4 outright.

# Integrations Verification

**Issue:** #179 (launch-readiness epic #150 §4)
**Last run:** 2026-06-23 — RSS ✅ PASS (incl. Mailchimp render, #180/#181); Netlify Forms detection ✅ (HTML evidence); Mailchimp signup submit + Netlify dashboard round-trip pending Joshua; Umami deferred to cutover.

A pre-cutover gate for the site's four external integrations. Like the URL-parity (`docs/url-parity/`) and link-check (`docs/link-check.md`) gates, it proves each integration rather than assuming it. **Only two integrations can be fully verified before cutover** — the other two are production-only by design and are confirmed on cutover day (#150 §7 steps 6–7). This doc records the evidence and keeps that boundary explicit.

## Status at a glance

| Integration | When verifiable | Status |
| --- | --- | --- |
| **RSS feed** (Phase 9) | Now (preview) | ✅ **PASS** — well-formed, 10 items + `content:encoded`, all 20 image URLs resolve; Mailchimp render confirmed (#180/#181) |
| **Mailchimp signup forms** (Phase 12) | Now (preview) | ⬜ Pending account-side submit |
| **Netlify Forms** detection + honeypot (Phase 11) | Now (preview, partial) | 🟡 **Detection confirmed** (HTML evidence); submission + honeypot pending dashboard |
| **Umami analytics** (Phase 14) | Cutover only | ⬜ Deferred — production-gated by design (#150 §7) |

Preview base for all "now" checks: `https://ofreport-dev.netlify.app`

---

## 1. RSS feed → Mailchimp ✅ PASS (2026-06-23)

The feed is the input to Mailchimp's RSS-to-email campaigns, so the URL must be stable and the markup must render undistorted in email. URL parity (#173) already proved `/feed.xml` returns `200` and is a valid feed; this is the structural + content validation, including the Mailchimp-hardening fixes shipped in #181 (evidence in #180).

### How to re-run

```bash
cd "$(mktemp -d)" && curl -s https://ofreport-dev.netlify.app/feed.xml -o feed.xml
xmllint --noout feed.xml && echo "well-formed"

# noon-UTC dates (the #181 off-by-one fix — every pubDate must end "12:00:00 +0000"):
grep -oE '<pubDate>[^<]+</pubDate>' feed.xml | head -3

# enclosure types track the real extension (not all jpeg — the #181 fix):
grep -oE '<enclosure[^>]+>' feed.xml | sed -E 's/.*type="([^"]+)".*/\1/' | sort | uniq -c

# every image URL (enclosures + content:encoded <img>) resolves 200:
python3 - <<'PY'
import re, subprocess
xml = open('feed.xml').read()
urls = list(dict.fromkeys(re.findall(r'<enclosure[^>]*url="([^"]+)"', xml)
                          + re.findall(r'<img[^>]*src="([^"]+)"', xml)))
bad = [u for u in urls if subprocess.run(["curl","-s","-o","/dev/null","-w","%{http_code}","-I",u],
        capture_output=True, text=True).stdout.strip() != "200"]
print(f"{len(urls)} image URLs — " + ("ALL 200" if not bad else f"{len(bad)} FAILED: {bad}"))
PY
```

### Findings

- **Well-formed** (`xmllint --noout` clean). RSS 2.0 with `atom:`, `dc:`, **and `content:`** namespaces declared — the `content` namespace was added in #181 for the `<content:encoded>` blocks.
- **Channel** carries `title`, `link`, `description`, `generator`, `language` (`en-US`), `copyright`, `lastBuildDate`, and an `atom:link` self-reference.
- **Self-reference is launch-ready:** even on the preview build, `<atom:link href="https://ofreport.com/feed.xml" …>` and channel `<link>` point at the **production** domain — so Mailchimp continuity is preserved (the feed URL Mailchimp polls never changes across cutover). This is the single most important RSS fact for the migration.
- **10 items** (explicit `[services.rss] limit = 10` in `hugo.toml`), newest → oldest: `Wed, 27 May 2026` → `Mon, 24 Feb 2025`.
- **Dates emit at noon UTC** (`… 12:00:00 +0000`) on both `pubDate` and `lastBuildDate` — the #181 fix for the publish-date-off-by-one wart, so the displayed date never crosses a day boundary when rendered anywhere in the Americas.
- **Each item** has `title`, `link` (absolute, production permalink), `pubDate` (RFC-822), `dc:creator`, `guid` (= permalink), a plain-text **curated excerpt** `description` (the excerpt model from CHANGELOG 2026-06-06, kept clean for RSS readers), a `<content:encoded>` CDATA block, and a cover `<enclosure>`.
- **`<content:encoded>` carries an email-safe cover `<img>`** sized by width only (`width="600"` + inline `style="…width:100%;max-width:600px;height:auto;border:0"`) at the 1200×630 (1.91:1) `c_fill` social preset — the width-with-auto-height pattern that can't distort in email clients — followed by the excerpt. This is the block the Mailchimp campaign points at for the email body (`*|RSSITEM:CONTENT_FULL|*`).
- **Enclosure `type` tracks the real extension** — 8 `image/jpeg`, 2 `image/png` (no longer hardcoded to jpeg; the #181 fix). Enclosure retained for podcast-style readers.
- **All 20 image URLs resolve `200`** — 10 enclosure covers (`rss` preset, `w_560`) + 10 `content:encoded` covers (1200×630 `c_fill`).

### Mailchimp render — confirmed (Joshua, #180)

A real Mailchimp RSS-to-email **test campaign** was sent account-side: the **cover image rendered undistorted** and the **displayed publish date matched the actual post date**. This closes the two legacy warts (stretched cover, off-by-one date) at the source. Full evidence in #180; the live, fixed feed is `https://ofreport-dev.netlify.app/feed.xml`.

> **Cutover note:** the production Mailchimp RSS campaign must repoint at `https://ofreport.com/feed.xml` and use `*|RSSITEM:CONTENT_FULL|*` (not `*|RSSITEM:CONTENT|*`, which drops the cover) in the RSS Items block. Tracked in #150 §8 (post-launch).

### Minor / cosmetic (not a blocker)

- `enclosure` emits `length="0"` (`layouts/_default/rss.xml`) — Hugo can't know the remote Cloudinary byte size. Universally tolerated by readers and Mailchimp; the RSS spec wants real bytes, but this is the standard Hugo-remote-image compromise.

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

## 3. Netlify Forms (contact) 🟡 Detection confirmed — submission/honeypot pending

The contact form (`layouts/partials/contact-form.html`) is auto-detected by Netlify on build. **Detection + honeypot are testable on the preview; notification routing is production-only** — the live Nuxt site uses an AWS Lambda (not Netlify Forms), so routing must be set up fresh on the production site at cutover (#150 §7 step 6). The Lambda retires with the Nuxt site; nothing to migrate.

Form: `https://ofreport-dev.netlify.app/contact/`

### Detection confirmed at the HTML level (Claude, 2026-06-23)

Netlify's form-detection post-processor leaves a **distinctive fingerprint** in the served HTML, so detection is verifiable without the dashboard. When Netlify finds `data-netlify="true"` at deploy time, it registers the form and **consumes** the build-directive attributes (`data-netlify`, `netlify-honeypot`), re-serializing only that form (single-quoted, alphabetized attributes) while keeping the runtime fields it needs at POST time.

Three serializers make this unambiguous:

| Form | Served `<form>` tag style | Meaning |
| --- | --- | --- |
| Hugo's minifier (local `hugo --minify`) | `<form name=contact … data-netlify=true netlify-honeypot=bot-field …>` | source HTML before Netlify sees it |
| Deployed **Mailchimp** form (no `data-netlify`) | `<form id=mc-embedded-subscribe-form … >` — unquoted, Hugo style, untouched | Netlify ignored it (correct) |
| Deployed **contact** form | `<form action='/thank-you/' class='…' method='POST' name='contact'>` — single-quoted, alphabetized, **`data-netlify` gone** | Netlify detected + processed it ✅ |

The runtime fields survive the rewrite, confirming the form is wired to capture: `<input type=hidden name=form-name value=contact>` (associates the POST with the "contact" form) and `<input name=bot-field …>` (the honeypot trap). The `netlify-honeypot="bot-field"` directive is consumed — Netlify now knows which field is the honeypot.

#### How to re-run

```bash
curl -s https://ofreport-dev.netlify.app/contact/ -o /tmp/contact.html
# data-netlify is CONSUMED on a successful detect — its absence is the pass signal:
grep -q 'data-netlify' /tmp/contact.html \
  && echo "still present → NOT detected ❌" \
  || echo "consumed by Netlify → detected ✅"
# the runtime fields Netlify needs must remain:
grep -oE "name=['\"]?(form-name|bot-field)" /tmp/contact.html | sort -u
```

### Account-side confirm (Joshua) — on the `ofreport-dev` site

Detection is already evidenced above; these confirm the round-trip in the dashboard.

- [ ] Confirm a form named **`contact`** appears under the site's **Forms** tab (Netlify dashboard → `ofreport-dev` → Forms).
- [ ] Submit the contact form at `/contact/`; confirm the submission appears under that form.
- [ ] Submit again with the hidden **`bot-field`** populated (e.g. via devtools) and confirm Netlify drops it as spam (does not appear as a real submission).

> _Evidence (fill in after testing): form appears in Forms tab Y/N, submission captured Y/N, honeypot-filled submit rejected Y/N._

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

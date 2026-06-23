# Debrief — Launch-Readiness Verification Gates

- **Project:** OFReport.com Hugo Rebuild
- **Date:** 2026-06-23
- **Scope:** Phase 16 (Deployment) foundation — URL parity, redirects, and re-runnable pre-cutover gates
- **PRs:** #174, #175, #176, #177, #178 (all merged)
- **Issues:** #171 (URL audit), #172 (redirect map), #173 (live verify), #168 (link check), #166 (cover probe) — all under launch epic #150
- **PRD refs:** `07-deployment.md §"Netlify Configuration"`, `ROADMAP.md` Phase 16

## Summary

This chunk built the verification scaffolding for the Nuxt → Hugo cutover: a three-stage URL-parity pipeline (audit → redirects → verify), a site-wide link-check gate, and a cover-image resolution probe. The headline result is **proven URL parity** — all 373 live URLs resolve on the new Hugo build (347 one-to-one, 26 via a single clean 301, 0 that would 404). Phase 15 (Content Migration) was also formally closed during this window. No template or content behavior changed beyond a `/thank-you` noindex and the corrected `page/1` redirects; the work is overwhelmingly tooling and evidence, built to be re-run on cutover day.

## Key architecture decisions

- **Two-script URL-parity split (`audit.py` + `verify.py`).** `audit.py` is an offline structural diff (committed live sitemap vs. local `./public`) that proves pages *exist*; `verify.py` fires real HTTP at the deployed preview to prove pages *resolve*. Separate failure modes, separate scripts — a page can exist yet still fail to resolve if a Netlify rule misfires.
- **"Cosmetic slash hop" excluded from the redirect budget.** `verify.py`'s classifier compares `cur.rstrip("/") != loc.rstrip("/")`, so Netlify's automatic `/contact` → `/contact/` normalization doesn't count as a content redirect. This is what makes the live 347/26/0 buckets line up exactly with the static audit — and prevents `page/1` (slash-normalized *and* redirected in one response) from looking like a failing 2-hop chain.
- **Forced, trailing-slash redirects for `page/1`.** The original PRD rule was proven to be a dead no-op (Netlify normalized the slash, then served Hugo's existing `page/1/index.html` alias, shadowing the non-forced rule). Fixed with `force = true` + trailing-slash `from` + a single `:tag` placeholder collapsing all 25 tag rules into one. The live verify confirms the placeholder works (26/26 single-301s).
- **Defense-in-depth `noindex` for `/thank-you`.** `noindex: true` drives the robots meta via `seo.html` (`and hugo.IsProduction (not .Params.noindex)`); `sitemap.disable: true` keeps it out of `sitemap.xml`. Both, because each addresses a different crawler path.
- **Gates own disjoint slices via documented excludes.** lychee excludes `ofreport.com` (owned by `verify.py`) and `res.cloudinary.com` (covers owned by `probe-covers.rb`), avoiding non-deterministic double-coverage (bulk Cloudinary HEADs throttle). Each exclude-list entry carries a reason — triage, not suppression.
- **`probe-covers.rb` mirrors the render partial and reads config.** It rebuilds the served hero-preset URL exactly as `cloudinary-url.html` does (3 source shapes) and reads `cloudinaryBase` from `hugo.toml` so it can't drift. Cloudinary derivatives are all-or-nothing, so one transform per cover conclusively answers "does it resolve."

## Test / gate status (all re-run 2026-06-23, all green)

- **Production build** (`hugo --gc --minify`): clean — 290 pages, 26 aliases, ~0.6s.
- **Cover probe** (`scripts/probe-covers.rb`): 125 covers, **0 broken** (98 articles intentionally cover-less).
- **URL audit** (`docs/url-parity/audit.py`): 373 live URLs, **0 would 404**, 1 expected new page (`/thank-you`).
- **Live resolution** (`docs/url-parity/verify.py` → deploy preview): **347 / 26 / 0**, blog 223/223, tags 25/25, feed + sitemap PASS.
- **Link check** (`lychee`, documented run 2026-06-23): **0 broken internal links**; 3830 unique links, outbound failures triaged.

## Flagged for follow-up

- **`nogreaterjoy.org` donate link 404s** on `2025-04-23-before-the-curtain-closes` — a live, user-facing giving CTA, currently parked in the lychee exclude list. Needs the current NoGreaterJoy giving URL to repoint. (Highest-value follow-up: real broken button, not a crawler nit.)
- **Gates are manual/local, not wired into CI.** Fine for a one-time cutover; a regression risk post-launch. Decision: wire into the Netlify build or keep as a documented pre-deploy checklist.
- **`HERO_TRANSFORMS` in `probe-covers.rb` duplicates the partial's hero preset** — comment-enforced sync, not code-enforced. Low risk (preset rarely changes).
- **Hugo version drift:** `netlify.toml` pins `0.163.0`; local builds `0.163.3+extended`. Align before cutover to remove ambiguity.
- **`live-urls.txt` is a committed snapshot.** If the live Nuxt site changes before cutover, re-run `audit.py` to refresh the inventory. Low risk (site is effectively frozen).
- **Open a11y issues (#164 contrast, #165 heading order)** will affect the Phase 16 Lighthouse gate — worth clearing before that audit.

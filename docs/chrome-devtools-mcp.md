# Chrome DevTools MCP — Front-End QA Tooling

This document records why and how the `chrome-devtools-mcp` server was wired into this project, what it adds on top of the browser tooling we already had, and the implications going forward. It was added on 2026-06-13 to support front-end QA during the Nuxt → Hugo rebuild.

## TL;DR

We added a **project-scoped** `.mcp.json` at the repo root that runs the Chrome DevTools MCP server (built and maintained by the Google Chrome team). It gives the AI agent access to DevTools' *analytical* panels — Lighthouse audits, performance traces, and device/network/CPU emulation — which our existing browser tooling could not do. The server is scoped to this repository only and launches a throwaway, isolated Chrome profile, so there is no exposure of the developer's real browser session.

## Background: why this was worth adding

The pain point in past front-end work was that the AI agent could not see *into* Chrome DevTools — it could not measure performance, run accessibility/SEO audits, or properly emulate devices. Chrome shipped `chrome-devtools-mcp` to close that gap, and it reached **v1 stability in Chrome 149** (we pinned v1.2.0).

The important nuance is that we already run **Claude in Chrome** (Anthropic's browser-extension MCP), which drives the real browser session and already handles clicking, navigating, screenshots, reading the console, reading network requests, and running JavaScript. So this is not "the agent can finally see the browser" — it is specifically the *measurement and audit* layer that the interactive extension never had.

### What each tool is for

| Capability | Claude in Chrome (already had) | chrome-devtools-mcp (new) |
| --- | --- | --- |
| Click / type / navigate / screenshot | Yes | Yes |
| Read console + network | Yes | Yes |
| **Lighthouse audits** (a11y, SEO, performance, best practices) | No | Yes |
| **Performance traces** with Core Web Vitals / LCP / CLS / long-task insights | No | Yes |
| **Heap snapshots / memory-leak analysis** | No | Yes (off by default — see config) |
| **Device + network throttling + CPU emulation** | Partial (resize only) | Yes (proper emulation) |
| Drives the real, logged-in browser session | Yes (native) | Only via opt-in remote-debug attach |

For this migration specifically, the high-value tools are **Lighthouse** (verify the rebuilt site scores well on accessibility/SEO), **performance traces** (catch layout shift and slow loads while matching the old design), and **emulation** (confirm responsive behavior without manual resizing). Memory tooling is low-value here because the site is near-static (Hugo + Tailwind v4 + a little Alpine.js), so it is left disabled.

## The configuration

The server is configured in `.mcp.json` at the repository root (Claude Code's convention for project-scoped, checked-in MCP servers):

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "-y",
        "chrome-devtools-mcp@1.2.0",
        "--isolated",
        "--no-usage-statistics",
        "--no-performance-crux"
      ]
    }
  }
}
```

### Why each choice

| Setting | Rationale |
| --- | --- |
| `chrome-devtools-mcp@1.2.0` (pinned) | Deterministic, reproducible behavior, consistent with our "pin versions" practice. The tool is evolving quickly; bump deliberately rather than tracking `@latest`. |
| `--isolated` | Launches a throwaway Chrome profile that is auto-cleaned on exit. Correct for a no-auth static site — no session or PII exposure, and it never touches the real browser or the Claude-in-Chrome profile. |
| `--no-usage-statistics` | Opts out of Google's tool-usage telemetry. |
| `--no-performance-crux` | Stops the performance tools from sending trace URLs to Google's CrUX field-data API. Pointless against `localhost` anyway, and privacy-respecting by default. |
| Memory debugging: omitted | The `--memoryDebugging` flag is off by default; heap-leak analysis adds little on a near-static site. |
| Headless: omitted | Default is headed (visible UI), which is preferable for visual QA. |

The server exposes roughly 40 tools by default; the fuller catalog is around 47 if the memory, extensions, and third-party categories are enabled. Our config keeps those extra categories off to limit the tool surface.

## How to use it

1. Start the dev server: `npm run dev` (Hugo serves at `http://localhost:1313/`).
2. On the next Claude Code session **in this project**, approve the trust prompt for the new `chrome-devtools` MCP server (a one-time Claude Code safeguard for project-scoped servers). The tools then load only in this repo.
3. Ask the agent to use the tools, for example:
   - "Run a Lighthouse audit on the home page and summarize the accessibility issues."
   - "Trace the article page load and find the largest layout shifts."
   - "Emulate an iPhone and a slow 4G connection, then screenshot the blog list."

### When to flip a flag back

- **Production performance audits**: remove `--no-performance-crux` if you run Lighthouse/perf against the live `https://ofreport.com` URL — CrUX real-world Core Web Vitals are genuinely useful there (they are not available for `localhost`).
- **Connecting to your real, logged-in browser**: replace `--isolated` with `--browserUrl http://127.0.0.1:9222` (manual remote-debug port) or `--autoConnect` (Chrome 144+). Only do this deliberately: the agent then inherits your live session — logged-in accounts, cookies, and PII. Not needed for this static site.

## Security and privacy

The Chrome team's own disclaimer: the server "exposes the content of the browser instance to MCP clients allowing them to inspect, debug, and modify any data in the browser." With our isolated configuration the only thing exposed is the throwaway profile pointed at our own dev site, so the risk is minimal. The risk only becomes material if you switch to `--autoConnect` / `--browserUrl` against your real Chrome, which we are not doing.

## Implications going forward

- **Two browser-driving MCP servers now coexist in this project.** Claude in Chrome (interactive/visual) and chrome-devtools (audit/perf) overlap on navigate/screenshot/console/network. The working division: use chrome-devtools for Lighthouse, performance traces, and emulation; use the extension for live visual checks. Expect slightly more tool-selection noise as a tradeoff.
- **Context/token cost is scoped, not global.** The ~40 tool definitions load only in this repository because the config is project-scoped. This was a deliberate choice over a global install to keep everyday sessions lean.
- **Version maintenance is manual.** Because the version is pinned, it will not auto-update. Bump it intentionally when you want newer features or fixes; re-check the flag list (`npx -y chrome-devtools-mcp@latest --help`) after a major bump, as categories and defaults change between releases.
- **Reproducibility.** The `.mcp.json` is committed, so the tooling travels with the repo. If this proves its worth across a few projects, the next step is to capture the pattern as a reusable snippet so wiring it into future front-end projects is a one-liner (rule of three — not before).

## Reference URLs

- DevTools 149 release notes (agents section): <https://developer.chrome.com/blog/new-in-devtools-149/#devtools-for-agents>
- DevTools for agents v1 announcement: <https://developer.chrome.com/blog/devtools-for-agents-v1>
- DevTools for agents docs (overview): <https://developer.chrome.com/docs/devtools/agents>
- Getting started guide: <https://developer.chrome.com/docs/devtools/agents/get-started>
- GitHub repository (full tool list, flags, disclaimer): <https://github.com/ChromeDevTools/chrome-devtools-mcp>

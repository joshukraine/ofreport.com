#!/usr/bin/env ruby
# frozen_string_literal: true

# migrate.rb — convert the Nuxt 2 articles to Hugo content.
#
# Scope (issue #126, Phase 15 core — the "happy path"):
#   * Frontmatter transforms (preview -> description, add slug, image -> cover,
#     tag fix, drop build-only fields).
#   * The six <article-*> component conversions to Hugo shortcodes.
#
# Scope (issue #127, legacy raw-HTML normalization — the PR #93 class of work,
# scaled across the whole archive). Applied AFTER the <article-*> pass, so only
# true legacy raw HTML remains to handle. Per-type handling:
#   * WordPress <a href="full"><img src="thumb"></a> (+ caption line) -> {{< figure >}}.
#     The full-size <a href> is the image source; it is delivered through
#     Cloudinary fetch (see partials/cloudinary-url.html) for f_auto/q_auto +
#     GLightbox zoom. A caption on the immediately-following line is absorbed;
#     otherwise the img `alt` becomes the caption.
#   * <nuxt-link to="/path/">text</nuxt-link> -> markdown [text](/path/).
#     (Safe: none of the source nuxt-links sit inside a raw HTML block, where
#     emitted markdown would not be parsed.)
#   * YouTube / Vimeo <iframe> -> {{< youtube ID >}} / {{< vimeo ID >}} (responsive).
#     The Nuxt <div class="videoWrapper"> wrapper around such iframes is unwrapped.
#   * KEPT RAW (render fine under goldmark unsafe=true; no clean shortcode win):
#     Buzzsprout <div id><script> podcast players, the Instagram <blockquote>
#     embed, and self-hosted <video>/<audio>/<source> players. <strong> is also
#     left raw — it already renders bold, and several instances sit inside <p>
#     blocks where a "**" would render as literal asterisks.
#   * Everything else (underline <span>, stray <div>/<br>/<sup>/<figcaption>, the
#     one in-page skip-link, genuine <a> links) is left as-is and surfaced in the
#     RESIDUAL RAW HTML report for the manual fix pass.
#
# Scope (issue #128, validation + content-audit report). On top of the #126/#127
# transforms, the script now:
#   * Hardens validation into explicit PASS/FAIL assertions that FAIL THE RUN
#     (exit 1): input==output count, all required frontmatter present, zero
#     leftover <article-*>, zero CONVERSION GAPS, and "good and evil" fully
#     consolidated to "good-and-evil".
#   * Writes a machine-readable content-audit CSV (default tmp/migration-audit.csv)
#     — the triage hand-off for the manual fix pass (#129) and graceful display
#     (#135). One row per article: cover status/width, missing description /
#     caption / figure alt, residual raw HTML by type, conversion gaps, legacy
#     HTML entities, bare-angle-bracket URLs, and per-file notes.
#   * Optionally probes each cover's pixel width via Cloudinary's fl_getinfo flag
#     (--probe-covers) to flag legacy thumbnails below SMALL_COVER_WIDTH. Off by
#     default so the normal run stays fast, offline, and deterministic.
#
# Re-runnability (per Joshua's 2026-06-21 decision): the default guard is
# SKIP-IF-EXISTS. A normal re-run writes only NEW files (late-arriving posts) and
# never clobbers a target that already exists — so hand-edits made after a prior
# migration are safe. Use --force to re-migrate everything from scratch (this
# DOES overwrite, including hand-edits); use it when an upstream correction to an
# already-migrated post needs to be re-pulled.
#
# Dependencies: Ruby stdlib only (yaml, fileutils, optparse, date, csv, json,
# net/http, uri). No gems.
#
# Usage:
#   ruby scripts/migrate.rb              # migrate new files into content/blog/
#   ruby scripts/migrate.rb --dry-run    # transform + validate + report, write nothing
#   ruby scripts/migrate.rb --force      # re-migrate ALL files (overwrites)
#   ruby scripts/migrate.rb --probe-covers   # also probe cover widths (network)
#   ruby scripts/migrate.rb --audit PATH     # audit CSV path (default tmp/migration-audit.csv)
#   ruby scripts/migrate.rb --source PATH --dest PATH

require "yaml"
require "fileutils"
require "optparse"
require "date"
require "csv"
require "json"
require "net/http"
require "uri"

module Migrate
  # Frontmatter field order in the output, matching archetypes/blog.md. Optional
  # fields (cover/caption/pdf) are omitted entirely when absent in the source,
  # which matches the existing hand-authored articles in content/blog/.
  FIELD_ORDER = %w[title date author description tags cover caption pdf slug].freeze
  REQUIRED_FIELDS = %w[title date author description slug].freeze

  # Tags the normalization pass is expected to ELIMINATE. If any survive into the
  # output it means a conversion missed a shape — a real bug, reported loudly.
  GAP_PATTERNS = {
    "<img>"       => /<img\b/i,
    "<nuxt-link>" => /<nuxt-link\b/i,
    "<iframe>"    => /<iframe\b/i
  }.freeze

  # Tags intentionally left as raw HTML (embeds that work under unsafe=true) or
  # genuinely one-off markup for the manual fix pass. Reported for visibility,
  # not as errors.
  RESIDUAL_PATTERNS = {
    "<script> (podcast/embed)" => /<script\b/i,
    "<video>/<audio> (self-hosted)" => /<(video|audio)\b/i,
    "<blockquote> (instagram)" => /<blockquote\b/i,
    "stray <div>"              => /<div\b/i,
    "<strong> (renders bold as-is)" => /<strong\b/i,
    "underline/styling <span>" => /<span\b/i,
    "genuine <a> link"         => /<a\s/i,
    "<sup>/<figcaption>/<br>"  => /<(sup|figcaption|br)\b/i
  }.freeze

  # --- content-audit constants (issue #128) --------------------------------

  # Our Cloudinary delivery base, used to build a fetch fl_getinfo URL for any
  # remote (non-Cloudinary) cover. Mirrors hugo.toml [params] cloudinaryBase.
  CLOUDINARY_BASE = "https://res.cloudinary.com/dnkvsijzu"

  # Covers narrower than this (px) are flagged "small" — a legacy thumbnail that
  # can't fill the modern hero/OG display crisply. Tunable; 1200 = the OG width.
  SMALL_COVER_WIDTH = 1200

  # The cover-status vocabulary, in summary display order. Single source of truth
  # for both cover_status (which returns one of these) and the report roll-up.
  COVER_STATUSES = %w[ok small unprobed broken missing].freeze

  # Legacy HTML entities left over from the WordPress lineage (e.g. "&nbsp;",
  # "Q&amp;A", "&#39;"). They render, but should be real characters — surfaced
  # for the manual fix pass. The catch-all "&word;" alternative is last so the
  # named/numeric forms are reported by their exact spelling.
  LEGACY_TOKEN_RE = /&nbsp;|&amp;|&#\d+;|&[a-z]+;/i

  # Bare-angle-bracket autolinks like <https://…>. They render under goldmark,
  # but are often a youtu.be link that should be an embed — surfaced for review.
  BARE_ANGLE_URL_RE = %r{<https?://[^>\s]+>}i

  # A migrated {{< figure >}}; group 1 is its parameter string. Used to count
  # figures carrying neither alt= nor caption= (a real a11y gap — no fallback
  # text), distinct from the common alt-falls-back-to-caption case.
  FIGURE_RE = /\{\{<\s*figure\s+(.*?)\s*>}}/m

  # Precompiled once (rather than per file): each regex matches a single
  # <name …> tag, tolerating ">" inside quoted attribute values (some captions
  # contain ">"). The attribute string is captured in group 1.
  COMPONENT_TAGS = %w[
    article-image article-callout article-button article-svg article-divider article-spacer
  ].freeze
  TAG_REGEX = COMPONENT_TAGS.to_h { |name|
    [name, /<#{name}\b((?:[^>"']|"[^"]*"|'[^']*')*)\/?>/m]
  }.freeze

  # --- legacy raw-HTML patterns (issue #127) -------------------------------

  # The Nuxt "videoWrapper" div wraps a single (usually YouTube) iframe for
  # responsive sizing. Hugo's youtube/vimeo shortcodes are responsive on their
  # own, so the wrapper is stripped and its inner iframe handled below.
  VIDEOWRAPPER_RE = %r{<div\s+class="videoWrapper">\s*(<iframe\b.*?</iframe>)\s*</div>}im

  # WordPress gallery image: an <a href="full"> wrapping an <img src="thumb">,
  # optionally trailed by a single caption line (no blank line between).
  #   g1/g2 = href (double/single quoted)  g3 = <img> attrs  g4 = caption line
  ANCHOR_IMG_RE =
    %r{<a\b[^>]*?\bhref\s*=\s*(?:"([^"]*)"|'([^']*)')[^>]*>\s*<img\b([^>]*?)/?>\s*</a>(?:[ \t]*\n[ \t]*([^\n<][^\n]*))?}im

  # A bare <img> (not anchor-wrapped); same optional trailing caption line.
  #   g1 = <img> attrs  g2 = caption line
  BARE_IMG_RE = %r{<img\b([^>]*?)/?>(?:[ \t]*\n[ \t]*([^\n<][^\n]*))?}im

  # <nuxt-link to="/path/">text</nuxt-link>.  g1/g2 = to=  g3 = inner text
  NUXT_LINK_RE =
    %r{<nuxt-link\b[^>]*?\bto\s*=\s*(?:"([^"]*)"|'([^']*)')[^>]*>(.*?)</nuxt-link>}im

  # <iframe ... src="..."></iframe>.  g1/g2 = src
  IFRAME_RE = %r{<iframe\b[^>]*?\bsrc\s*=\s*(?:"([^"]*)"|'([^']*)')[^>]*>\s*</iframe>}im

  # A bare <img>/<a href> is only treated as an image source when it points at
  # an actual image file.
  IMAGE_EXT_RE = /\.(?:jpe?g|png|gif|webp|avif)\b/i

  module_function

  # --- attribute parsing ---------------------------------------------------

  # Parse an attribute string into a hash. Handles double- and single-quoted
  # values and Vue's bound-prop ":" prefix (`:outline="true"`). The colon is
  # stripped so `outline` and `:outline` collapse to one key.
  def parse_attrs(str)
    attrs = {}
    str.to_s.scan(/(:?[\w-]+)\s*=\s*(?:"([^"]*)"|'([^']*)')/) do |key, dq, sq|
      attrs[key.sub(/\A:/, "")] = dq.nil? ? sq : dq
    end
    attrs
  end

  def truthy?(value)
    value == true || value.to_s.strip == "true"
  end

  # Quote a value as a Hugo shortcode named parameter. Hugo parses these as Go
  # interpreted-string literals, so backslashes and double quotes must be escaped
  # (confirmed against the Hugo shortcode docs). Block form avoids Ruby's special
  # treatment of "\" in gsub replacement strings.
  def quote(value)
    escaped = value.to_s.gsub("\\") { "\\\\" }.gsub('"') { '\\"' }
    %("#{escaped}")
  end

  # Pull name + url out of a Vue object literal like
  # `{ name: 'X', href: 'https://…' }` or `{ name: 'X', to: '/blog/…/' }`.
  def parse_link(obj)
    name = obj[/name:\s*'([^']*)'/, 1]
    url  = obj[/href:\s*'([^']*)'/, 1] || obj[/to:\s*'([^']*)'/, 1]
    { name: name, url: url }
  end

  # --- component conversions ----------------------------------------------

  # <article-image> -> {{< figure >}}. width/height/border are intentionally
  # dropped: the figure shortcode is responsive-by-preset and only accepts
  # src/caption/alt (alt falls back to caption inside the shortcode). Emission is
  # delegated to figure_shortcode, shared with the WordPress-image conversion.
  def convert_image(attrs)
    figure_shortcode(attrs["publicId"], attrs["caption"], nil)
  end

  # <article-callout> -> {{< callout >}}. Three shapes:
  #   * :download="true"  -> content is the PDF filename; map to pdf="…".
  #   * :link="{…}"       -> append a markdown link line inside the inner body.
  #   * plain             -> content becomes the inner body.
  def convert_callout(attrs)
    content = attrs["content"].to_s

    if truthy?(attrs["download"])
      return "{{< callout pdf=#{quote(content)} >}}\n{{< /callout >}}"
    end

    inner = content
    if attrs["link"]
      link = parse_link(attrs["link"])
      inner = "#{content}\n\n[#{link[:name]}](#{link[:url]})" if link[:name] && link[:url]
    end

    "{{< callout >}}\n#{inner}\n{{< /callout >}}"
  end

  # <article-button> -> {{< button >}}. path -> href; outline/external become
  # bare Hugo bools; center=true is the shortcode default (omit); margin dropped.
  def convert_button(attrs)
    parts = ["href=#{quote(attrs['path'])}", "text=#{quote(attrs['text'])}"]
    parts << "outline=true"  if truthy?(attrs["outline"])
    parts << "external=true" if truthy?(attrs["external"])
    parts << 'align="left"'  if attrs.key?("center") && !truthy?(attrs["center"])
    "{{< button #{parts.join(' ')} >}}"
  end

  # <article-svg> -> {{< svg >}}. width -> a Tailwind class; alt/margin dropped
  # (the inlined SVG carries its own a11y markup). A `link` wrapper is not
  # expressible via the shortcode, so the caller is warned to review it.
  def convert_svg(attrs, warn)
    classes = ["block"]
    width = attrs["width"]
    classes << "w-[#{width}px]" if present?(width)
    classes.push("max-w-full", "h-auto")

    warn.call("<article-svg> link=#{attrs['link'].inspect} not supported by svg shortcode") \
      if present?(attrs["link"])

    "{{< svg name=#{quote(attrs['name'])} class=#{quote(classes.join(' '))} >}}"
  end

  # --- legacy raw-HTML conversions (issue #127) ---------------------------

  # Protocol-relative ("//host/…") legacy URLs become https; everything else is
  # passed through untouched so already-absolute URLs survive.
  def normalize_url(url)
    url.to_s.strip.sub(%r{\A//}, "https://")
  end

  # Emit a {{< figure >}} from a resolved image source + optional caption/alt.
  # Shared by both convert_image (<article-image>) and convert_wp_image. caption
  # may be nil (the article-image path passes it straight through), so it is
  # coerced before comparison. alt is only emitted when it differs from the
  # caption (the shortcode already falls back to caption when alt is absent).
  def figure_shortcode(src, caption, alt)
    parts = ["src=#{quote(src)}"]
    parts << "caption=#{quote(caption)}" if present?(caption)
    parts << "alt=#{quote(alt)}" if present?(alt) && alt.strip != caption.to_s.strip
    "{{< figure #{parts.join(' ')} >}}"
  end

  # Convert one WordPress image to a figure. `href` is the wrapping <a> target
  # (nil for a bare <img>); the full-size href wins as the source when it is an
  # image URL, otherwise the <img src> is used. A trailing caption line, when
  # present, takes precedence over the img alt for the visible caption.
  def convert_wp_image(href, img_attrs, caption_line)
    attrs   = parse_attrs(img_attrs)
    img_src = normalize_url(attrs["src"])
    full    = normalize_url(href)
    source  = present?(href) && full.match?(IMAGE_EXT_RE) ? full : img_src
    alt     = attrs["alt"].to_s.strip
    caption = caption_line.to_s.rstrip
    caption = alt if caption.empty?
    figure_shortcode(source, caption, alt)
  end

  # YouTube/Vimeo <iframe> -> shortcode. Returns nil for anything else so the
  # caller can leave the original markup untouched.
  def convert_iframe(src, warn)
    url = src.to_s
    if (id = url[%r{youtube\.com/embed/([\w-]+)}, 1] || url[%r{youtu\.be/([\w-]+)}, 1])
      "{{< youtube #{id} >}}"
    elsif (id = url[%r{(?:player\.)?vimeo\.com/(?:video/)?(\d+)}, 1])
      "{{< vimeo #{id} >}}"
    else
      warn.call("<iframe src=#{url.inspect}> not youtube/vimeo — kept raw, review")
      nil
    end
  end

  # Apply every component conversion to the body. `warn` collects per-file notes.
  def transform_body(body, warn)
    out = body.dup
    out = out.gsub(TAG_REGEX["article-image"])    { convert_image(parse_attrs($1)) }
    out = out.gsub(TAG_REGEX["article-callout"])  { convert_callout(parse_attrs($1)) }
    out = out.gsub(TAG_REGEX["article-button"])   { convert_button(parse_attrs($1)) }
    out = out.gsub(TAG_REGEX["article-svg"])      { convert_svg(parse_attrs($1), warn) }
    out = out.gsub(TAG_REGEX["article-divider"])  { "\n\n---\n\n" }
    out = out.gsub(TAG_REGEX["article-spacer"])   { "" }

    # Legacy raw-HTML normalization (issue #127). Order matters: unwrap the
    # videoWrapper div before the iframe pass; handle anchor-wrapped <img> before
    # bare <img> so the wrapping <a> is consumed rather than left dangling.
    out = out.gsub(VIDEOWRAPPER_RE) { $1 }
    out = out.gsub(ANCHOR_IMG_RE)   { convert_wp_image($1 || $2, $3, $4) }
    out = out.gsub(BARE_IMG_RE)     { convert_wp_image(nil, $1, $2) }
    out = out.gsub(NUXT_LINK_RE)    { "[#{$3.strip}](#{$1 || $2})" }
    out = out.gsub(IFRAME_RE)       { |m| convert_iframe($1 || $2, warn) || m }

    # Collapse the blank-line runs left behind by removed spacers/dividers.
    out.gsub(/\n{3,}/, "\n\n").strip + "\n"
  end

  # --- frontmatter transforms ---------------------------------------------

  # Strip markdown/HTML formatting from preview text so `description` is plain.
  def strip_markdown(text)
    text.to_s
        .gsub(/<br\s*\/?>/i, " ")             # explicit line breaks
        .gsub(/<[^>]+>/, "")                   # any other inline HTML
        .gsub(/!\[[^\]]*\]\([^)]*\)/, "")      # images
        .gsub(/\[([^\]]*)\]\([^)]*\)/, '\1')   # links -> text
        .gsub(/(\*\*|__)(.*?)\1/, '\2')        # bold
        .gsub(/(\*|_)(.*?)\1/, '\2')           # italic
        .gsub(/`([^`]*)`/, '\1')               # inline code
        .gsub(/\s+/, " ")
        .strip
  end

  # Fallback description for the single article with no `preview`: first body
  # paragraph, markdown-stripped and truncated on a word boundary.
  def snippet(body, limit = 160)
    para = body.to_s.strip.split(/\n\s*\n/).find { |p| !p.strip.empty? }.to_s
    text = strip_markdown(para)
    return text if text.length <= limit

    "#{text[0, limit].sub(/\s+\S*\z/, '')}…"
  end

  # Normalize any date form (incl. legacy "2012-11-04 20:43:37") to YYYY-MM-DD.
  def normalize_date(value)
    value.to_s.strip[/\d{4}-\d{2}-\d{2}/] || value.to_s.strip
  end

  # Build the ordered output frontmatter hash and a list of per-file flags.
  def transform_frontmatter(fm, slug, body)
    flags = []
    out = {}

    out["title"]  = fm["title"].to_s.strip
    out["date"]   = normalize_date(fm["date"])
    out["author"] = fm["author"].to_s.strip

    if fm["preview"]
      out["description"] = strip_markdown(fm["preview"])
    else
      out["description"] = snippet(body)
      flags << "no `preview` — description generated from first paragraph"
    end

    tags = Array(fm["tags"]).map { |t| t == "good and evil" ? "good-and-evil" : t }
    out["tags"] = tags unless tags.empty?

    cover = (fm["cover"] || fm["image"]).to_s.strip
    unless cover.empty?
      out["cover"] = cover
      flags << "`image:` renamed to `cover:` (legacy value — verify URL)" if fm["image"] && !fm["cover"]
    end

    # Folded YAML scalars carry a trailing newline; strip so caption stays a
    # clean single-line value rather than a multi-line block in the output.
    out["caption"] = fm["caption"].to_s.strip if present?(fm["caption"])
    out["pdf"]     = fm["pdf"].to_s.strip     if present?(fm["pdf"])
    out["slug"]    = slug

    # Order canonically and drop nils.
    ordered = {}
    FIELD_ORDER.each { |k| ordered[k] = out[k] unless out[k].nil? }
    [ordered, flags]
  end

  # --- per-file pipeline ---------------------------------------------------

  FRONTMATTER_RE = /\A---\s*\n(.*?\n)---\s*\n?(.*)\z/m

  def process_file(path)
    raw = File.read(path)
    slug = File.basename(path, ".md")

    match = raw.match(FRONTMATTER_RE)
    raise "no YAML frontmatter found" unless match

    fm = YAML.safe_load(match[1], permitted_classes: [Date, Time]) || {}
    body = match[2]

    warnings = []
    new_body = transform_body(body, ->(msg) { warnings << msg })
    new_fm, fm_flags = transform_frontmatter(fm, slug, body)

    # Build the output file. YAML.dump gives safe quoting; line_width: -1 keeps
    # long descriptions on one line (no hard wraps). Strip its leading "---".
    yaml = YAML.dump(new_fm, line_width: -1).sub(/\A---\s*\n/, "")
    content = "---\n#{yaml}---\n\n#{new_body}"

    cover = new_fm["cover"]
    # Figures with neither alt nor caption — no fallback text at all. parse_attrs
    # keys on real attribute names, so a value that merely contains "alt="
    # (e.g. a URL query param) can't be mistaken for an alt parameter.
    figs_no_alt = new_body.scan(FIGURE_RE).count do |params,|
      attrs = parse_attrs(params)
      !attrs.key?("alt") && !attrs.key?("caption")
    end

    {
      slug: slug,
      content: content,
      date: new_fm["date"].to_s,
      cover: cover,
      cover_width: nil, # filled by the optional --probe-covers pass
      missing_required: REQUIRED_FIELDS.reject { |f| present?(new_fm[f]) },
      leftover_components: new_body.scan(/<article-[\w-]+/).uniq,
      gaps: GAP_PATTERNS.select { |_, re| new_body.match?(re) }.keys,
      residual: RESIDUAL_PATTERNS.select { |_, re| new_body.match?(re) }.keys,
      description_empty: !present?(new_fm["description"]),
      missing_caption: present?(cover) && !present?(new_fm["caption"]),
      figures_missing_alt: figs_no_alt,
      legacy_tokens: new_body.scan(LEGACY_TOKEN_RE).map(&:downcase).uniq.sort,
      bare_angle_urls: new_body.scan(BARE_ANGLE_URL_RE).size,
      bad_tags: Array(new_fm["tags"]).select { |t| t == "good and evil" },
      flags: fm_flags + warnings
    }
  end

  def present?(value)
    !value.nil? && !value.to_s.strip.empty? && value != []
  end

  # --- cover-width probe (issue #128, opt-in via --probe-covers) -----------

  # Fill each result's :cover_width by probing Cloudinary. Sequential and
  # network-bound (~one request per cover), which is why it is opt-in; progress
  # goes to stderr so the report on stdout stays clean.
  def probe_covers(results)
    coverable = results.select { |r| present?(r[:cover]) }
    warn "Probing #{coverable.size} cover widths via Cloudinary fl_getinfo…"
    coverable.each_with_index do |r, i|
      r[:cover_width] = probe_cover_width(r[:cover])
      warn "  …#{i + 1}/#{coverable.size}" if ((i + 1) % 25).zero?
    end
  end

  # Probe one cover's pixel width via Cloudinary's fl_getinfo delivery flag,
  # which returns image metadata as JSON without auth (verified against this
  # account). Returns the integer width, or nil on any failure (non-Cloudinary
  # path, network error, unexpected payload) — width is a best-effort triage
  # signal, never fatal.
  def probe_cover_width(url)
    info = getinfo_url(url)
    return nil unless info

    uri = URI(info)
    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                          open_timeout: 8, read_timeout: 8) do |http|
      http.get(uri.request_uri)
    end
    return nil unless res.is_a?(Net::HTTPSuccess)

    data  = JSON.parse(res.body)
    width = data.dig("input", "width") || data.dig("output", "width")
    width&.to_i
  rescue StandardError
    nil
  end

  # Insert the fl_getinfo flag for a cover URL. Handles the two Cloudinary
  # delivery shapes (upload + fetch) and wraps any other remote http URL in a
  # fetch call; returns nil for relative legacy paths (nothing probeable).
  def getinfo_url(url)
    u = url.to_s
    return nil unless u.start_with?("http")

    if u.include?("/image/upload/")
      u.sub("/image/upload/", "/image/upload/fl_getinfo/")
    elsif u.include?("/image/fetch/")
      u.sub("/image/fetch/", "/image/fetch/fl_getinfo/")
    else
      "#{CLOUDINARY_BASE}/image/fetch/fl_getinfo/#{u}"
    end
  end

  # --- content-audit report (issue #128) -----------------------------------

  # Triage status for a cover given its (optionally probed) width. Returns one of
  # COVER_STATUSES:
  #   missing  — no cover at all              broken — relative legacy path
  #   unprobed — has a cover, width unknown   small  — width < SMALL_COVER_WIDTH
  #   ok       — width >= SMALL_COVER_WIDTH
  def cover_status(result)
    cover = result[:cover]
    return "missing" unless present?(cover)
    return "broken"  if cover.start_with?("/") && !cover.start_with?("//")

    width = result[:cover_width]
    return "unprobed" if width.nil?

    width < SMALL_COVER_WIDTH ? "small" : "ok"
  end

  AUDIT_HEADERS = %w[
    slug date cover_status cover_width cover_url description_empty
    missing_caption figures_missing_alt residual_html conversion_gaps
    legacy_tokens bare_angle_urls notes
  ].freeze

  # Write the per-article content-audit CSV — the triage hand-off for the manual
  # fix pass (#129) and graceful display (#135). One row per article (full
  # inventory; consumers filter/sort), sorted by slug, multi-value cells
  # semicolon-joined. Written regardless of --dry-run: it is a tmp/ artifact, not
  # site content.
  def write_audit(path, results)
    FileUtils.mkdir_p(File.dirname(path))
    CSV.open(path, "w") do |csv|
      csv << AUDIT_HEADERS
      results.sort_by { |r| r[:slug] }.each do |r|
        csv << [
          r[:slug],
          r[:date],
          cover_status(r),
          r[:cover_width],
          r[:cover],
          r[:description_empty] ? "yes" : "",
          r[:missing_caption] ? "yes" : "",
          r[:figures_missing_alt].positive? ? r[:figures_missing_alt] : "",
          r[:residual].join("; "),
          r[:gaps].join("; "),
          r[:legacy_tokens].join("; "),
          r[:bare_angle_urls].positive? ? r[:bare_angle_urls] : "",
          r[:flags].join("; ")
        ]
      end
    end
  end

  # --- runner --------------------------------------------------------------

  def run(source:, dest:, dry_run:, force:, probe:, audit:)
    files = Dir.glob(File.join(source, "*.md")).sort
    abort "No source articles found in #{source}" if files.empty?

    FileUtils.mkdir_p(dest) unless dry_run

    results = []
    written = []
    skipped = []
    errors = []

    files.each do |path|
      result = process_file(path)
      results << result

      target = File.join(dest, "#{result[:slug]}.md")
      if File.exist?(target) && !force
        skipped << result[:slug]
        next
      end

      File.write(target, result[:content]) unless dry_run
      written << result[:slug]
    rescue => e
      errors << { slug: File.basename(path, ".md"), message: e.message }
    end

    probe_covers(results) if probe
    write_audit(audit, results)

    report(source: source, dest: dest, dry_run: dry_run, force: force,
           total: files.size, results: results, written: written,
           skipped: skipped, errors: errors, probe: probe, audit: audit)
  end

  def report(source:, dest:, dry_run:, force:, total:, results:, written:, skipped:, errors:, probe:, audit:)
    bar = "=" * 70
    puts bar
    puts "Migration #{dry_run ? '(dry run — no content written; audit CSV still written)' : 'complete'}"
    puts bar
    puts "Source : #{source}"
    puts "Dest   : #{dest}"
    puts "Guard  : #{force ? 'force (overwrite all)' : 'skip-if-exists'}"
    puts
    puts "Articles found  : #{total}"
    puts "Written/created : #{written.size}"
    puts "Skipped (exists): #{skipped.size}"
    puts "Errors          : #{errors.size}"
    puts

    # Hard assertions (issue #128): any FAIL exits the run non-zero. These are the
    # invariants the migration must never violate; the detail sections below name
    # the offending files. Soft signals (residual raw HTML, missing covers, etc.)
    # are triage items, reported but non-fatal.
    accounted = written.size + skipped.size + errors.size
    assertions = [
      ["Article count: input #{total} == accounted #{accounted}", errors.empty? && accounted == total],
      ["All required frontmatter present", results.all? { |r| r[:missing_required].empty? }],
      ["Zero unconverted <article-*> components", results.all? { |r| r[:leftover_components].empty? }],
      ["Zero conversion gaps (<img>/<nuxt-link>/<iframe>)", results.all? { |r| r[:gaps].empty? }],
      ["Tag 'good and evil' fully consolidated", results.all? { |r| r[:bad_tags].empty? }]
    ]
    all_passed = assertions.all? { |_, pass| pass }

    puts "VALIDATION (hard assertions — run fails on any FAIL):"
    assertions.each { |name, pass| puts "  [#{pass ? 'PASS' : 'FAIL'}] #{name}" }
    puts

    unless errors.empty?
      puts "ERRORS (file could not be migrated):"
      errors.each { |e| puts "  - #{e[:slug]}: #{e[:message]}" }
      puts
    end

    missing = results.reject { |r| r[:missing_required].empty? }
    unless missing.empty?
      puts "MISSING REQUIRED FRONTMATTER:"
      missing.each { |r| puts "  - #{r[:slug]}: #{r[:missing_required].join(', ')}" }
      puts
    end

    leftover = results.reject { |r| r[:leftover_components].empty? }
    unless leftover.empty?
      puts "UNCONVERTED <article-*> COMPONENTS (should be none):"
      leftover.each { |r| puts "  - #{r[:slug]}: #{r[:leftover_components].join(', ')}" }
      puts
    end

    notes = results.reject { |r| r[:flags].empty? }
    unless notes.empty?
      puts "NOTES (per-file decisions / manual-review items):"
      notes.each { |r| r[:flags].each { |f| puts "  - #{r[:slug]}: #{f}" } }
      puts
    end

    gaps = results.reject { |r| r[:gaps].empty? }
    unless gaps.empty?
      puts "CONVERSION GAPS — normalization missed these (should be none):"
      gaps.each { |r| puts "  - #{r[:slug]}: #{r[:gaps].join(', ')}" }
      puts
    end

    residual = results.reject { |r| r[:residual].empty? }
    unless residual.empty?
      puts "RESIDUAL RAW HTML — kept raw / manual fix pass (#{residual.size} files):"
      residual.first(40).each { |r| puts "  - #{r[:slug]}: #{r[:residual].join(', ')}" }
      puts "  …and #{residual.size - 40} more" if residual.size > 40
      puts
    end

    # Roll-up: per-category counts for triage at a glance. The per-article detail
    # lives in the audit CSV; these are the headline numbers the issue/PRD track.
    cover_counts = results.group_by { |r| cover_status(r) }.transform_values(&:size)
    cover_line = COVER_STATUSES
                 .filter_map { |k| "#{k} #{cover_counts[k]}" if cover_counts[k] }
                 .join(" | ")
    figs_total = results.sum { |r| r[:figures_missing_alt] }
    figs_files = results.count { |r| r[:figures_missing_alt].positive? }

    puts "CONTENT-AUDIT SUMMARY (n=#{results.size}):"
    puts "  covers (#{probe ? 'probed' : 'widths not probed — use --probe-covers'}): #{cover_line}"
    puts "  empty description       : #{results.count { |r| r[:description_empty] }}"
    puts "  cover without caption   : #{results.count { |r| r[:missing_caption] }}"
    puts "  figures missing alt     : #{figs_total} across #{figs_files} articles"
    puts "  legacy HTML entities    : #{results.count { |r| !r[:legacy_tokens].empty? }} articles"
    puts "  bare-angle-bracket URLs : #{results.count { |r| r[:bare_angle_urls].positive? }} articles"
    puts "  residual raw HTML       : #{residual.size} articles"
    puts "  conversion gaps         : #{gaps.size} articles (must be 0)"
    puts "  → audit CSV written     : #{audit}"
    puts

    puts bar
    all_passed
  end
end

# --- CLI ------------------------------------------------------------------

if __FILE__ == $PROGRAM_NAME
  repo_root = File.expand_path("..", __dir__)
  options = {
    source: File.expand_path("../ofreport.com-nuxt2/content/articles", repo_root),
    dest: File.join(repo_root, "content", "blog"),
    dry_run: false,
    force: false,
    probe: false,
    audit: File.join(repo_root, "tmp", "migration-audit.csv")
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: ruby scripts/migrate.rb [options]"
    opts.on("--source PATH", "Source articles dir (Nuxt)") { |v| options[:source] = File.expand_path(v) }
    opts.on("--dest PATH", "Destination dir (Hugo content/blog)") { |v| options[:dest] = File.expand_path(v) }
    opts.on("--dry-run", "Transform + validate + report; write nothing") { options[:dry_run] = true }
    opts.on("--force", "Overwrite existing files (re-migrate all)") { options[:force] = true }
    opts.on("--probe-covers", "Probe cover widths via Cloudinary (network)") { options[:probe] = true }
    opts.on("--audit PATH", "Audit CSV path (default tmp/migration-audit.csv)") { |v| options[:audit] = File.expand_path(v) }
    opts.on("-h", "--help", "Show this help") { puts opts; exit }
  end.parse!

  ok = Migrate.run(**options)
  exit(ok ? 0 : 1)
end

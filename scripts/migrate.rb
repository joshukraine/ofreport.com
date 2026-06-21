#!/usr/bin/env ruby
# frozen_string_literal: true

# migrate.rb — convert the Nuxt 2 articles to Hugo content.
#
# Scope (issue #126, Phase 15 core — the "happy path"):
#   * Frontmatter transforms (preview -> description, add slug, image -> cover,
#     tag fix, drop build-only fields).
#   * The six <article-*> component conversions to Hugo shortcodes.
#   * Baseline validation + a flag list of legacy raw HTML for the follow-up issue.
#
# Explicitly NOT in scope (separate follow-up issues):
#   * Converting raw <img>/<nuxt-link>/<iframe>/embeds (flagged here, fixed there).
#   * The rich content-audit report.
#
# Re-runnability (per Joshua's 2026-06-21 decision): the default guard is
# SKIP-IF-EXISTS. A normal re-run writes only NEW files (late-arriving posts) and
# never clobbers a target that already exists — so hand-edits made after a prior
# migration are safe. Use --force to re-migrate everything from scratch (this
# DOES overwrite, including hand-edits); use it when an upstream correction to an
# already-migrated post needs to be re-pulled.
#
# Dependencies: Ruby stdlib only (yaml, fileutils, optparse, date). No gems.
#
# Usage:
#   ruby scripts/migrate.rb              # migrate new files into content/blog/
#   ruby scripts/migrate.rb --dry-run    # transform + validate + report, write nothing
#   ruby scripts/migrate.rb --force      # re-migrate ALL files (overwrites)
#   ruby scripts/migrate.rb --source PATH --dest PATH

require "yaml"
require "fileutils"
require "optparse"
require "date"

module Migrate
  # Frontmatter field order in the output, matching archetypes/blog.md. Optional
  # fields (cover/caption/pdf) are omitted entirely when absent in the source,
  # which matches the existing hand-authored articles in content/blog/.
  FIELD_ORDER = %w[title date author description tags cover caption pdf slug].freeze
  REQUIRED_FIELDS = %w[title date author description slug].freeze

  # Patterns that indicate legacy raw markup left for the follow-up issue. The
  # migration does not touch these; it only reports which files still contain them.
  LEGACY_PATTERNS = {
    "raw <img>"     => /<img\b/i,
    "<nuxt-link>"   => /<nuxt-link\b/i,
    "<iframe>"      => /<iframe\b/i,
    "raw <div>"     => /<div\b/i,
    "raw <span>"    => /<span\b/i,
    "raw <a>"       => /<a\s/i
  }.freeze

  module_function

  # --- attribute parsing ---------------------------------------------------

  # Build a regex that matches a single <name ...> tag, tolerating ">" inside
  # quoted attribute values (some captions contain ">"). The attribute string is
  # captured in group 1.
  def tag_regex(name)
    /<#{name}\b((?:[^>"']|"[^"]*"|'[^']*')*)\/?>/m
  end

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
  # src/caption/alt (alt falls back to caption inside the shortcode).
  def convert_image(attrs)
    parts = ["src=#{quote(attrs['publicId'])}"]
    caption = attrs["caption"]
    parts << "caption=#{quote(caption)}" if caption && !caption.empty?
    "{{< figure #{parts.join(' ')} >}}"
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
    classes << "w-[#{width}px]" if width && !width.empty?
    classes.push("max-w-full", "h-auto")

    warn.call("<article-svg> link=#{attrs['link'].inspect} not supported by svg shortcode") \
      if attrs["link"] && !attrs["link"].empty?

    "{{< svg name=#{quote(attrs['name'])} class=#{quote(classes.join(' '))} >}}"
  end

  # Apply every component conversion to the body. `warn` collects per-file notes.
  def transform_body(body, warn)
    out = body.dup
    out = out.gsub(tag_regex("article-image"))   { convert_image(parse_attrs($1)) }
    out = out.gsub(tag_regex("article-callout"))  { convert_callout(parse_attrs($1)) }
    out = out.gsub(tag_regex("article-button"))   { convert_button(parse_attrs($1)) }
    out = out.gsub(tag_regex("article-svg"))      { convert_svg(parse_attrs($1), warn) }
    out = out.gsub(tag_regex("article-divider"))  { "\n\n---\n\n" }
    out = out.gsub(tag_regex("article-spacer"))   { "" }
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
    out["caption"] = fm["caption"].to_s.strip unless fm["caption"].to_s.strip.empty?
    out["pdf"]     = fm["pdf"].to_s.strip     unless fm["pdf"].to_s.strip.empty?
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

    {
      slug: slug,
      content: content,
      missing_required: REQUIRED_FIELDS.reject { |f| present?(new_fm[f]) },
      leftover_components: new_body.scan(/<article-[\w-]+/).uniq,
      legacy: LEGACY_PATTERNS.select { |_, re| new_body.match?(re) }.keys,
      flags: fm_flags + warnings
    }
  end

  def present?(value)
    !value.nil? && !value.to_s.strip.empty? && value != []
  end

  # --- runner --------------------------------------------------------------

  def run(source:, dest:, dry_run:, force:)
    files = Dir.glob(File.join(source, "*.md")).sort
    abort "No source articles found in #{source}" if files.empty?

    FileUtils.mkdir_p(dest) unless dry_run

    written = []
    skipped = []
    errors = []
    flagged = []
    legacy = []

    files.each do |path|
      result = process_file(path)

      flagged << result if result[:flags].any? ||
                           result[:missing_required].any? ||
                           result[:leftover_components].any?
      legacy << result if result[:legacy].any?

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

    report(source: source, dest: dest, dry_run: dry_run, force: force,
           total: files.size, written: written, skipped: skipped,
           errors: errors, flagged: flagged, legacy: legacy)

    errors.empty?
  end

  def report(source:, dest:, dry_run:, force:, total:, written:, skipped:, errors:, flagged:, legacy:)
    bar = "=" * 70
    puts bar
    puts "Migration #{dry_run ? '(dry run — nothing written)' : 'complete'}"
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

    # Baseline validation: every input must produce one output (written or skipped).
    accounted = written.size + skipped.size + errors.size
    ok = errors.empty? && accounted == total
    puts "Validation: input #{total} == accounted #{accounted}  ->  #{ok ? 'OK' : 'MISMATCH'}"
    puts

    unless errors.empty?
      puts "ERRORS (file could not be migrated):"
      errors.each { |e| puts "  - #{e[:slug]}: #{e[:message]}" }
      puts
    end

    missing = flagged.reject { |r| r[:missing_required].empty? }
    unless missing.empty?
      puts "MISSING REQUIRED FRONTMATTER:"
      missing.each { |r| puts "  - #{r[:slug]}: #{r[:missing_required].join(', ')}" }
      puts
    end

    leftover = flagged.reject { |r| r[:leftover_components].empty? }
    unless leftover.empty?
      puts "UNCONVERTED <article-*> COMPONENTS (should be none):"
      leftover.each { |r| puts "  - #{r[:slug]}: #{r[:leftover_components].join(', ')}" }
      puts
    end

    notes = flagged.reject { |r| r[:flags].empty? }
    unless notes.empty?
      puts "NOTES (per-file decisions / manual-review items):"
      notes.each { |r| r[:flags].each { |f| puts "  - #{r[:slug]}: #{f}" } }
      puts
    end

    unless legacy.empty?
      puts "LEGACY RAW HTML — for the follow-up issue (#{legacy.size} files):"
      legacy.first(40).each { |r| puts "  - #{r[:slug]}: #{r[:legacy].join(', ')}" }
      puts "  …and #{legacy.size - 40} more" if legacy.size > 40
      puts
    end

    puts bar
  end
end

# --- CLI ------------------------------------------------------------------

if __FILE__ == $PROGRAM_NAME
  repo_root = File.expand_path("..", __dir__)
  options = {
    source: File.expand_path("../ofreport.com-nuxt2/content/articles", repo_root),
    dest: File.join(repo_root, "content", "blog"),
    dry_run: false,
    force: false
  }

  OptionParser.new do |opts|
    opts.banner = "Usage: ruby scripts/migrate.rb [options]"
    opts.on("--source PATH", "Source articles dir (Nuxt)") { |v| options[:source] = File.expand_path(v) }
    opts.on("--dest PATH", "Destination dir (Hugo content/blog)") { |v| options[:dest] = File.expand_path(v) }
    opts.on("--dry-run", "Transform + validate + report; write nothing") { options[:dry_run] = true }
    opts.on("--force", "Overwrite existing files (re-migrate all)") { options[:force] = true }
    opts.on("-h", "--help", "Show this help") { puts opts; exit }
  end.parse!

  ok = Migrate.run(**options)
  exit(ok ? 0 : 1)
end

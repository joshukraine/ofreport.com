# frozen_string_literal: true

# convert_anchors_to_markdown.rb — issue #129 manual-review pass.
#
# Converts the residual raw <a> anchors carried through the WordPress →
# Middleman → Nuxt → Hugo migration into native markdown links, so they pass
# through Hugo's link render hook (external new-tab + rel="noopener" + the
# screen-reader "opens in a new tab" announcement; same-domain relative
# handling) instead of rendering inert under `unsafe = true`.
#
# Transform per anchor `<a ...href="URL"...>TEXT</a>` → `[TEXT](URL)`:
#   * href is the only attribute kept; decorative `title=` and `target=` are
#     dropped (the render hook decides new-tab behaviour by host).
#   * `&amp;` in the href is decoded to a literal `&` (markdown URLs are not
#     HTML-attribute contexts, so the entity would otherwise survive verbatim).
#   * one legacy WordPress relative link (`../../03/krakow/`) is repointed to its
#     Hugo permalink; it is the only non-resolving relative target in the set.
#
# Anchors inside a raw block-level HTML wrapper (a line beginning with <p>, <hN>,
# <blockquote>, <div>, …) are LEFT RAW: CommonMark treats such a line as an HTML
# block and does not parse markdown inside it, so a converted link would render
# as literal `[text](url)`. These wrappers are the irreducible centered/embedded
# blocks (Instagram embed, centered link headings) we keep raw anyway, and their
# anchors never reached the render hook to begin with — so converting them gains
# nothing and breaks rendering.
#
# Idempotent: re-running converts nothing new (only raw `<a>` inside block
# wrappers remain). Safe to run after the migration's skip-if-exists guard.
#
# Usage:
#   ruby scripts/convert_anchors_to_markdown.rb            # apply
#   ruby scripts/convert_anchors_to_markdown.rb --dry-run  # preview only

require "optparse"

dry_run = false
OptionParser.new do |o|
  o.on("--dry-run", "Print conversions without writing") { dry_run = true }
end.parse!(ARGV)

CONTENT_GLOB = File.expand_path("../content/blog/*.md", __dir__)
ANCHOR = %r{<a\b([^>]*)>(.*?)</a>}i

# A line starting with one of these block-level tags is a CommonMark HTML block;
# markdown inside it is not parsed, so anchors on such lines stay raw.
HTML_BLOCK_START = /\A\s*<(p|h[1-6]|div|blockquote|figcaption|table|ul|ol|li)[\s>]/i

# Legacy relative links that do not resolve under Hugo's /blog/:slug/ permalinks.
RELATIVE_REPOINTS = {
  "../../03/krakow/" => "/blog/2012-03-07-krakow/",
}.freeze

def href_of(attrs)
  if attrs =~ /\bhref\s*=\s*"([^"]*)"/i then Regexp.last_match(1)
  elsif attrs =~ /\bhref\s*=\s*'([^']*)'/i then Regexp.last_match(1)
  end
end

converted = 0
files_touched = 0

Dir.glob(CONTENT_GLOB).sort.each do |path|
  count = 0

  lines = File.readlines(path).map do |line|
    next line if line.match?(HTML_BLOCK_START) # raw HTML block — leave anchors raw

    line.gsub(ANCHOR) do
      attrs = Regexp.last_match(1)
      text = Regexp.last_match(2)
      href = href_of(attrs)

      raise "#{File.basename(path)}: anchor without href: <a#{attrs}>" if href.nil?
      raise "#{File.basename(path)}: link text contains brackets, would break markdown: #{text.inspect}" if text.match?(/[\[\]]/)
      raise "#{File.basename(path)}: link text contains nested HTML: #{text.inspect}" if text.match?(/<[a-z]/i)

      href = href.gsub("&amp;", "&")
      href = RELATIVE_REPOINTS.fetch(href, href)
      raise "#{File.basename(path)}: href contains paren, would break markdown: #{href}" if href.match?(/[()]/)

      count += 1
      "[#{text}](#{href})"
    end
  end

  next if count.zero?

  updated = lines.join

  converted += count
  files_touched += 1
  puts "#{File.basename(path)}: #{count} anchor#{'s' if count > 1}"

  File.write(path, updated) unless dry_run
end

puts
puts "#{dry_run ? '[dry-run] ' : ''}Converted #{converted} anchors across #{files_touched} files."

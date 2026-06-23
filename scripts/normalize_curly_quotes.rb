#!/usr/bin/env ruby
# frozen_string_literal: true

# One-off content sweep for issue #156: normalize the straight ASCII apostrophes
# (' U+0027) and double quotes (" U+0022) the WordPress -> Middleman -> Nuxt ->
# Hugo lineage left scattered through the Markdown SOURCE into their typographic
# curly forms (’ U+2019, “ U+201C, ” U+201D).
#
# Companion to scripts/decode_legacy_entities.rb (#155) and
# scripts/normalize_lviv_spelling.rb (#157). Sweeps every Markdown file under
# content/. Idempotent: once a file is clean no straight prose quote remains, so
# re-running is a no-op, and the migration's skip-if-exists guard preserves the
# edits.
#
# This is a SOURCE-consistency pass, not a rendered-bug fix. goldmark's
# typographer (Hugo default) already renders straight body quotes as curly, so
# the published HTML is unchanged by this sweep EXCEPT where a straight quote was
# never reaching goldmark in the first place (none here — see verification). The
# directional logic below mirrors smartypants/goldmark so the rendered output
# stays byte-identical; the rendered-HTML diff is the regression oracle.
#
# ── Apostrophes ──────────────────────────────────────────────────────────────
# Non-directional: every unprotected straight ' becomes ’ (U+2019), matching the
# curly apostrophe the content already uses for "God's", "who's", and the one the
# entity sweep decoded &#39;/&apos; into. Opening single quotes ('tis) are absent
# from the scope (the issue lists only contractions/possessives + double quotes),
# and ’tis is the conventional rendering anyway.
#
# ── Double quotes ────────────────────────────────────────────────────────────
# Directional: a " opens (“) at the start of a region or after whitespace, an
# opening bracket, an em/en dash, or an emphasis marker; otherwise it closes (”).
#
# ── What is PROTECTED (left straight) ────────────────────────────────────────
# In the body, a single left-to-right pass matches these regions first and
# returns them verbatim, so a straight quote inside them never converts:
#   - Hugo shortcode tags  {{< … >}} / {{% … %}}  — src=, caption=, alt=, href=
#     params (a curly char would break a URL; AC#2 leaves shortcode params alone).
#     Only the TAG is protected, so prose between a paired shortcode's open/close
#     (e.g. {{< callout >}}…{{< /callout >}}) is still curled.
#   - HTML tags and autolinks  <a href="…">, </a>, <br>, <https://…>.
#   - Markdown link/image destinations + titles  ](url "title").
#   - Markdown link-reference definitions  [id]: url "title"  (the title quotes
#     are CommonMark delimiters — curling them silently breaks the reference).
#   - Bare/auto URLs  https://…
#
# In the frontmatter, only prose-bearing keys are touched, and the YAML scalar
# delimiters are preserved so the document keeps parsing:
#   - plain   (title: Foo's day)      → value curled in place.
#   - single  (caption: 'Foo''s day') → delimiters kept; the doubled '' YAML
#     escape collapses to a single curly ’ (which needs no escaping); inner " is
#     curled.
#   - double  (title: "Foo \"bar\"")  → delimiters kept; the \" escape collapses
#     to a curly ” (needs no escaping); apostrophes curled.
#   - block   (description: >- / |)   → continuation lines curled as plain prose.
# Non-prose keys (date, slug, cover, pdf, tags, bgImage, author, layout, …) are
# skipped entirely — they hold URLs, ids, dates, filenames, lists, or booleans.

require "yaml"

ROOT = File.expand_path("..", __dir__)

# Frontmatter keys whose values are prose worth curling. Everything else in the
# frontmatter (URLs, ids, dates, lists, booleans, the author name) is skipped.
PROSE_KEYS = %w[
  title description caption heading subheading conclusion DISCLAIMER _UPDATE
].freeze

# ── Directional double-quote helper ──────────────────────────────────────────

# A " opens when it begins a region or follows whitespace, an opening bracket, an
# em/en dash, or a markdown emphasis marker; otherwise it closes.
OPENING_BEFORE = /[\s(\[{<“‘—–*_]/

def opening_quote?(prev_char)
  prev_char.nil? || OPENING_BEFORE.match?(prev_char)
end

# Curl the straight double quotes in +str+ directionally. +seed_prev+ is the
# character considered to precede the first char (defaults to a space, so a
# leading quote opens).
def curl_double_quotes(str, seed_prev = " ")
  prev = seed_prev
  str.each_char.map do |ch|
    out =
      if ch == '"'
        opening_quote?(prev) ? "“" : "”"
      else
        ch
      end
    prev = ch
    out
  end.join
end

# ── Body pass ────────────────────────────────────────────────────────────────

SHORTCODE    = /\{\{[<%].*?[%>]\}\}/
LINK_REF_DEF = /^\[[^\]\n]+\]:[ \t]+\S.*$/
HTML_TAG     = %r{</?[a-zA-Z][^>\n]*>}
MD_LINK_DEST = /\]\([^)\n]*\)/
BARE_URL     = %r{https?://\S+}
STRAIGHT     = /['"]/

# Protected regions are matched BEFORE a bare straight quote, so a quote inside
# them is returned verbatim. Order: shortcode and link-ref-def (line-anchored)
# first, then inline tags/links/URLs, then the bare quote.
BODY_TOKEN = Regexp.union(
  SHORTCODE, LINK_REF_DEF, HTML_TAG, MD_LINK_DEST, BARE_URL, STRAIGHT
)

def curl_body(text)
  text.gsub(BODY_TOKEN) do |match|
    case match
    when "'"
      "’"
    when '"'
      pre = Regexp.last_match.pre_match
      opening_quote?(pre.empty? ? nil : pre[-1]) ? "“" : "”"
    else
      match # protected region — verbatim
    end
  end
end

# ── Frontmatter pass ─────────────────────────────────────────────────────────

KEY_LINE   = /\A(\s*)([A-Za-z_][\w]*):[ \t]*(.*)\z/
BLOCK_VALUE = /\A[|>][-+0-9]*\s*\z/

# Curl the inner content of a double-quoted YAML scalar. A literal " inside is
# YAML-escaped as \" — collapse each to a directional curly quote and drop the
# backslash (curly quotes need no escaping). Apostrophes curl in place.
def curl_double_scalar_inner(inner)
  out = +""
  prev = " "
  i = 0
  while i < inner.length
    if inner[i] == "\\" && inner[i + 1] == '"'
      out << (opening_quote?(prev) ? "“" : "”")
      prev = '"'
      i += 2
    else
      ch = inner[i] == "'" ? "’" : inner[i]
      out << ch
      prev = inner[i]
      i += 1
    end
  end
  out
end

# Curl a single frontmatter scalar value, preserving its YAML quoting style.
def curl_fm_value(value)
  if (m = value.match(/\A'(.*)'\z/))           # single-quoted scalar
    inner = m[1].gsub("''", "’")               # YAML escape -> literal curly ’
    "'#{curl_double_quotes(inner)}'"
  elsif (m = value.match(/\A"(.*)"\z/))        # double-quoted scalar
    "\"#{curl_double_scalar_inner(m[1])}\""
  else                                         # plain scalar
    curl_double_quotes(value.tr("'", "’"))
  end
end

def curl_frontmatter(fm)
  in_block = false
  block_indent = 0

  fm.lines.map do |raw|
    nl = raw.end_with?("\n") ? "\n" : ""
    line = raw.chomp

    if (m = line.match(KEY_LINE))
      indent = m[1].length
      key = m[2]
      value = m[3]

      unless PROSE_KEYS.include?(key)
        in_block = false
        next raw
      end

      if value.match?(BLOCK_VALUE)             # block scalar — curl its body
        in_block = true
        block_indent = indent
        next raw
      end

      in_block = false
      "#{m[1]}#{key}: #{curl_fm_value(value)}#{nl}"
    elsif in_block && (line.strip.empty? || line[/\A\s*/].length > block_indent)
      curl_double_quotes(line.tr("'", "’")) + nl  # block continuation prose
    else
      in_block = false
      raw
    end
  end.join
end

# ── File pass ────────────────────────────────────────────────────────────────

FRONTMATTER = /\A(---\n)(.*?\n)(---\n?)/m

def curl_file(path)
  original = File.read(path)

  updated =
    if (m = original.match(FRONTMATTER))
      fm = curl_frontmatter(m[2])
      body = curl_body(m.post_match)
      "#{m[1]}#{fm}#{m[3]}#{body}"
    else
      curl_body(original)
    end

  return false if updated == original

  File.write(path, updated)
  true
end

if $PROGRAM_NAME == __FILE__
  paths  = Dir.glob(File.join(ROOT, "content/**/*.md")).sort
  edited = paths.select { |path| curl_file(path) }
  puts "Normalized straight quotes -> curly in #{edited.length} files."
  edited.first(10).each { |path| puts "  #{path.delete_prefix("#{ROOT}/")}" }
  puts "  …and #{edited.length - 10} more." if edited.length > 10
end

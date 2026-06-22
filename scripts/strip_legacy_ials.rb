#!/usr/bin/env ruby
# frozen_string_literal: true

# One-off content sweep for issue #129: strip the leftover kramdown/Middleman
# inline attribute lists (IALs) that the migration carried in raw, and restore
# the real image captions that were displaced in the process.
#
# Runs against the committed #136 baseline in content/blog/. Idempotent: once a
# file is clean none of the patterns match, so re-running is a no-op. The
# migration's skip-if-exists guard then preserves these hand-edits.
#
# Four IAL shapes are handled (counts reconcile exactly against the audit):
#
#   A. Figure shortcode whose caption= absorbed a "has-caption" IAL; the real
#      caption sits on the next line, trailed by a caption IAL:
#        {{< figure src="…" caption="{: .article-image .article-image--has-caption}" alt="X" >}}
#        The real caption text.
#        {: .caption-text .article-image__caption}
#      -> caption set to the real text; alt dropped (the shortcode falls back to
#         caption); the displaced text line and trailing IAL removed.
#
#   B. Figure shortcode whose caption= absorbed a plain "{: .article-image}" IAL
#      and that had no real caption at all:
#        {{< figure src="…" caption="{: .article-image}" alt="X" >}}
#      -> the bogus caption= attribute is removed; alt is kept.
#
#   E. A markdown linked-image that survived migration un-converted, followed by
#      a standalone article-image IAL (and optionally a caption + caption IAL):
#        [![Description](…thumb)](…full)
#        {: .article-image .article-image--has-caption}
#        The real caption text.
#        {: .caption-text .article-image__caption}
#      -> rewritten to {{< figure src="<full>" caption="<real text>" >}} so it
#         renders with the same Cloudinary/lightbox treatment as every other
#         figure. The placeholder alt is dropped.
#
#   D. A centering IAL attached to a verse / note:
#        …text…
#        {: .article-text--centered}
#      -> the IAL line is removed (the text remains as a normal paragraph).
#
# The "{: .article-button}" / inline "{: .button}" one-off (Rule F) is a single
# hand-edit in 2017-06-13-bible-first-kids.md, not handled here.

BLOG_DIR = File.expand_path("../content/blog", __dir__)

HAS_CAPTION_IAL = "{: .article-image .article-image--has-caption}"
NO_CAPTION_IAL  = "{: .article-image}"
CAPTION_IAL     = "{: .caption-text .article-image__caption}"
CENTER_IAL      = "{: .article-text--centered}"

# Quote + escape a value for a Hugo shortcode parameter, matching migrate.rb.
def quote(value)
  escaped = value.to_s.gsub("\\") { "\\\\" }.gsub('"') { '\\"' }
  %("#{escaped}")
end

# A non-blank line that is not itself an IAL — i.e. a real caption.
def caption_line?(line)
  line && !line.strip.empty? && !line.strip.start_with?("{:")
end

# Parse a markdown image line into [alt, src]. Handles the linked form
# [![alt](thumb)](full) — full-size target wins as src — and the bare form
# ![alt](url). Protocol-relative URLs are normalized to https, matching
# migrate.rb. Returns nil for anything that is not a lone image line.
def parse_md_image(line)
  if (m = line.match(%r{\A\[!\[([^\]]*)\]\([^)]*\)\]\(([^)]*)\)\z}))
    [m[1], m[2].sub(%r{\A//}, "https://")]
  elsif (m = line.match(%r{\A!\[([^\]]*)\]\(([^)]*)\)\z}))
    [m[1], m[2].sub(%r{\A//}, "https://")]
  end
end

def strip_file(path)
  lines   = File.read(path).split("\n", -1)
  out     = []
  changed = false
  i       = 0

  while i < lines.length
    line    = lines[i]
    stripped = line.lstrip

    # Rule A / B: figure shortcode that absorbed an IAL into caption=. A handful
    # of figure lines carry stray leading whitespace from the source; matching
    # the lstripped line normalizes the indent away on rewrite.
    if stripped.start_with?("{{< figure ") && stripped =~ /caption="(\{:[^"]*)"/
      ial = Regexp.last_match(1)

      if ial.include?("--has-caption") && caption_line?(lines[i + 1]) &&
         lines[i + 2]&.strip == CAPTION_IAL
        # Rule A: promote the displaced caption, drop alt + the two stray lines.
        real = lines[i + 1].rstrip
        rebuilt = stripped.sub(/caption="\{:[^"]*"/, "caption=#{quote(real)}")
                          .sub(/ alt="(?:[^"\\]|\\.)*"/, "")
        out << rebuilt
        i += 3
        changed = true
        next
      else
        # Rule B: no real caption — just drop the bogus caption= attribute.
        out << stripped.sub(/ caption="\{:[^"]*"/, "")
        i += 1
        changed = true
        next
      end
    end

    # Rule E: un-converted markdown image (linked or bare) + standalone
    # article-image IAL.
    parsed = parse_md_image(stripped)
    if parsed &&
       (lines[i + 1]&.strip == HAS_CAPTION_IAL || lines[i + 1]&.strip == NO_CAPTION_IAL)
      alt, src = parsed

      if lines[i + 1].strip == HAS_CAPTION_IAL && caption_line?(lines[i + 2]) &&
         lines[i + 3]&.strip == CAPTION_IAL
        # Has a real caption — promote it and drop the placeholder alt.
        real = lines[i + 2].rstrip
        out << "{{< figure src=#{quote(src)} caption=#{quote(real)} >}}"
        i += 4
      else
        # No caption — keep the alt when it carries real text.
        parts = ["src=#{quote(src)}"]
        parts << "alt=#{quote(alt)}" unless alt.strip.empty?
        out << "{{< figure #{parts.join(' ')} >}}"
        i += 2
      end
      changed = true
      next
    end

    # Rule D: drop a standalone centering IAL.
    if line.strip == CENTER_IAL
      i += 1
      changed = true
      next
    end

    out << line
    i += 1
  end

  return false unless changed

  File.write(path, out.join("\n"))
  true
end

edited = Dir.glob(File.join(BLOG_DIR, "*.md")).sort.select { |path| strip_file(path) }
puts "Stripped legacy IALs from #{edited.length} files:"
edited.each { |path| puts "  #{File.basename(path)}" }

#!/usr/bin/env ruby
# frozen_string_literal: true

# One-off content sweep for issue #157: update the city name spelling
# "L'viv" -> "Lviv" across content/ and data/.
#
# Lviv (the Steeles' home city) was historically transliterated with an
# apostrophe reflecting the Ukrainian soft sign — "L'viv". Official romanization
# guidance has since dropped it; the preferred English spelling is now "Lviv".
#
# Companion to scripts/decode_legacy_entities.rb (PR #155). Sweeps every Markdown
# file under content/ (the spelling appears in body, frontmatter description, and
# figure captions across 96 files, plus the static family.md / podcast.md) and
# data/archives.json (the newsletter "L'viv Angels" title that feeds the rendered
# /archives/ page). Idempotent: once a file is clean no "L'viv" remains, so
# re-running is a no-op, and the migration's skip-if-exists guard preserves the
# edits.
#
# Apostrophe variants matched, between "L" and "viv":
#   - the straight ASCII "'" (U+0027),
#   - the typographic curly "’" (U+2019) the content mostly uses, and
#   - the YAML single-quoted escaping, where a literal apostrophe is DOUBLED —
#     "L''viv" inside a `description: '...'` scalar parses back to "L'viv". The
#     {1,2} quantifier catches that doubled form, which a single-apostrophe
#     match silently skips (it left 3 rendered descriptions wrong on the first
#     pass).
#
# Possessive forms are handled by the same replace — "L'viv's" -> "Lviv's" —
# because only the city-name apostrophe is removed; the trailing possessive
# apostrophe + "s" stays put. (Curling any remaining straight possessive
# apostrophe is issue #156's job, deliberately not done here.)
#
# No tag/href protection is needed (unlike the entity-decode sweep): "L'viv"
# never appears inside a URL or slug in this content — verified before writing.
# The Wikipedia link in 2014-01-25-position-ukraine.md already points at
# ".../wiki/Lviv"; only its display text read "L'viv", and matching it to the
# URL is exactly right. Direct quotations / official names that would preserve
# the apostrophe form were reviewed and none exist.

ROOT  = File.expand_path("..", __dir__)
GLOBS = ["content/**/*.md", "data/**/*.json"].freeze

# "L" + one or two apostrophes (straight U+0027 or curly U+2019) + "viv".
LVIV = /L['’]{1,2}viv/

def normalize_file(path)
  original = File.read(path)
  updated  = original.gsub(LVIV, "Lviv")
  return false if updated == original

  File.write(path, updated)
  true
end

if $PROGRAM_NAME == __FILE__
  paths  = GLOBS.flat_map { |glob| Dir.glob(File.join(ROOT, glob)) }.sort
  edited = paths.select { |path| normalize_file(path) }
  puts "Normalized \"L'viv\" -> \"Lviv\" in #{edited.length} files:"
  edited.each { |path| puts "  #{path.delete_prefix("#{ROOT}/")}" }
end

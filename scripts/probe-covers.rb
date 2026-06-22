#!/usr/bin/env ruby
# frozen_string_literal: true

# probe-covers.rb — verify every article cover resolves on Cloudinary (issue #166).
#
# Why this exists:
#   The launch gate (#150 §1) requires that all article covers resolve to a live
#   200 — no leftover fabricated/placeholder covers that 404. The covers were
#   audited by eye, but never actually probed. This closes the gate with
#   evidence: it fetches the URL the site *actually serves* for each cover.
#
#   This is NOT redundant with probe-images.rb (#143): that script probes raw
#   image URLs and skips anything without an image extension — which silently
#   skips Cloudinary covers, since `f_auto` delivery URLs carry no extension.
#   Here we rebuild the transformed delivery URL and probe that.
#
# What it does:
#   1. Reads the `cover:` frontmatter from every article in content/blog/
#      (skipping _index.md, the list page).
#   2. Rebuilds the served URL by replicating layouts/partials/cloudinary-url.html
#      at the `hero` preset — the cover render on the article page. The three
#      source shapes (bare public ID / full Cloudinary URL / remote fetch) are
#      handled exactly as the partial does, so we probe what Hugo emits.
#   3. Probes each distinct URL's HTTP status (HEAD, with a ranged-GET retry),
#      concurrently.
#   4. Reports every non-200 as `<article>: <url> -> <status>`.
#
#   Cloudinary derivatives are all-or-nothing on the source asset: if the asset
#   exists, every transform of it resolves; if it was fabricated, every transform
#   404s. So one representative transform (hero) per cover conclusively answers
#   "does this cover resolve?" — no need to probe all six presets.
#
#   Articles with no `cover:` are intentional (graceful no-cover handling,
#   #135/#159) and are counted as "no cover", never failures.
#
# It only reads and makes network requests — it never edits content.
#
# Dependencies: Ruby stdlib only (net/http, uri, set).
#
# Usage:
#   ruby scripts/probe-covers.rb
#
# Exit status is non-zero if any cover fails, so it doubles as a re-runnable
# pre-cutover gate.

require "net/http"
require "uri"
require "set"

ROOT     = File.expand_path("..", __dir__)
BLOG_DIR = File.join(ROOT, "content", "blog")
HUGO_TOML = File.join(ROOT, "hugo.toml")
THREADS  = 12
TIMEOUT  = 25

# The article-page cover render. MUST stay in sync with the "hero" preset in
# layouts/partials/cloudinary-url.html.
HERO_TRANSFORMS = "c_limit,f_auto,q_auto:best,w_2000"

Thread.abort_on_exception = true

# --- Config -----------------------------------------------------------------

# Read cloudinaryBase from hugo.toml so the script can't drift from the site
# config. Fail loudly if it's gone rather than probing a wrong host.
def cloudinary_base
  line = File.read(HUGO_TOML)[/^\s*cloudinaryBase\s*=\s*"([^"]+)"/, 1]
  line || abort("ERROR: cloudinaryBase not found in #{HUGO_TOML}")
end

# --- Extraction & URL construction ------------------------------------------

# The single `cover:` value from an article's frontmatter, or nil. Handles both
# quoted and unquoted forms.
def cover_src(text)
  text[/^cover:\s*["']?([^"'\s]+)["']?\s*$/, 1]
end

# Rebuild the served (hero-preset) URL exactly as cloudinary-url.html does.
def served_url(src, base)
  src = "https:#{src}" if src.start_with?("//")

  if !src.start_with?("http")
    # Shape 1: bare public ID -> full /upload/ URL (transforms injected below).
    src = "#{base}/image/upload/#{src}"
  elsif !src.start_with?(base)
    # Shape 3: a remote URL not under our Cloudinary base -> deliver via fetch.
    return "#{base}/image/fetch/#{HERO_TRANSFORMS}/#{src}"
  end

  # Shape 1 & 2: inject the transforms after /upload/.
  src.sub("/upload/", "/upload/#{HERO_TRANSFORMS}/")
end

# --- Probing (mirrors probe-images.rb) --------------------------------------

def alive?(code)
  (200..399).cover?(code)
end

# HTTP status integer, or 0 on a network/timeout error. HEAD first; some hosts
# reject HEAD, so a non-alive verdict is confirmed with a 1-byte ranged GET.
def probe(url)
  uri = URI(url)
  code = request(uri, Net::HTTP::Head.new(uri))
  return code if alive?(code)

  get = Net::HTTP::Get.new(uri)
  get["Range"] = "bytes=0-0"
  request(uri, get)
end

def request(uri, req)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == "https"
  http.open_timeout = TIMEOUT
  http.read_timeout = TIMEOUT
  http.start { |conn| conn.request(req).code.to_i }
rescue StandardError
  0
end

# --- Main -------------------------------------------------------------------

base = cloudinary_base
articles = Dir.glob(File.join(BLOG_DIR, "*.md")).reject { |p| File.basename(p) == "_index.md" }.sort

# article basename => served cover URL (only articles that have a cover)
covers   = {}
no_cover = []

articles.each do |path|
  name = File.basename(path)
  src  = cover_src(File.read(path))
  if src
    covers[name] = served_url(src, base)
  else
    no_cover << name
  end
end

puts "Probing #{covers.size} cover images across #{articles.size} articles " \
     "(#{no_cover.size} articles have no cover — graceful, not failures)...\n\n"

# Probe concurrently into a thread-safe hash.
results = {}
mutex   = Mutex.new
queue   = Queue.new
covers.each_value { |u| queue << u }

workers = Array.new(THREADS) do
  Thread.new do
    loop do
      url =
        begin
          queue.pop(true)
        rescue ThreadError
          break
        end
      code = probe(url)
      mutex.synchronize { results[url] = code }
    end
  end
end
workers.each(&:join)

puts "Status summary:"
covers.values.map { |u| results[u] }.tally.sort.each do |code, n|
  puts "  #{code.zero? ? 'ERR' : code}: #{n}"
end
puts

failures = covers.reject { |_name, url| alive?(results[url]) }.sort

puts "=== Cover failures (#{failures.size}) ==="
if failures.empty?
  puts "None — every cover image resolves 200."
else
  failures.each do |name, url|
    code = results[url]
    puts "  #{name}: #{url} -> #{code.zero? ? 'ERR (network/timeout)' : code}"
  end
end

exit(failures.empty? ? 0 : 1)

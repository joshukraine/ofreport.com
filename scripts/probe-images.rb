#!/usr/bin/env ruby
# frozen_string_literal: true

# probe-images.rb — audit remote article images for availability (issue #143).
#
# Why this exists:
#   Legacy WordPress-era images are still served from the old CloudFront
#   distribution (d21yo20tm8bmc2.cloudfront.net) and delivered through
#   Cloudinary fetch (see layouts/partials/cloudinary-url.html). The article
#   migration (#127) normalized WordPress <a href="full"><img src="thumb"></a>
#   markup to use the full-size <a href> as the figure source. For some old
#   posts the full-size original was never preserved on CloudFront, so that
#   source now 404s and the image renders broken — a DATA problem, not a
#   template one.
#
# What it does:
#   1. Scans content/blog/*.md for every remote http(s) image URL — the legacy
#      CloudFront figure/markdown sources, plus full Cloudinary URLs (covers).
#      Bare Cloudinary public IDs (native figures, e.g.
#      "OFReport/.../slug_ab12") are delivered from our own Cloudinary account
#      and are out of scope for this CloudFront audit; their count is reported
#      but they are not probed.
#   2. Probes each distinct URL's HTTP status (HEAD, with a ranged-GET retry
#      for hosts that reject HEAD), concurrently.
#   3. Reports dead URLs grouped with the articles that reference them.
#   4. For each dead URL, looks up the matching Nuxt source article (same
#      filename) and tries to recover the original <img src> derivative the
#      migration discarded, probing that candidate so a working replacement can
#      be suggested.
#
# It only reads and makes network requests — it never edits content. Remediation
# is applied by hand from this report (the dead set is small and each fix wants
# a human eyeball).
#
# Dependencies: Ruby stdlib only (net/http, uri, set).
#
# Usage:
#   ruby scripts/probe-images.rb

require "net/http"
require "uri"
require "set"

BLOG_DIR = File.expand_path("../content/blog", __dir__)
NUXT_DIR = File.expand_path("../../ofreport.com-nuxt2/content/articles", __dir__)
THREADS  = 12
TIMEOUT  = 25

# A worker that raises an unexpected (non-network) error should fail loudly
# rather than silently dropping its URLs from the results.
Thread.abort_on_exception = true

# --- Extraction -------------------------------------------------------------

# Pull every image src out of a file: figure shortcodes, markdown images, and
# cover frontmatter. Returns raw (un-normalized) src strings.
def extract_srcs(text)
  srcs = []
  text.scan(/\{\{<\s*figure\s+[^>]*?src="([^"]+)"/) { |(s)| srcs << s }
  text.scan(/!\[[^\]]*\]\((https?:\/\/[^)\s]+|\/\/[^)\s]+)\)/) { |(s)| srcs << s }
  text.scan(/^cover:\s*["']?([^"'\s]+)["']?\s*$/) { |(s)| srcs << s }
  srcs
end

def normalize(url)
  url.start_with?("//") ? "https:#{url}" : url
end

# A probeable source is a full http(s) URL pointing at an image file.
def probeable?(url)
  url.start_with?("http") && url.match?(/\.(jpe?g|png|gif|webp)$/i)
end

# A bare Cloudinary public ID (no scheme) — delivered from our own account, so
# out of scope here but worth counting so coverage is honest.
def bare_cloudinary_id?(url)
  !url.start_with?("http") && !url.start_with?("//")
end

# --- Probing ----------------------------------------------------------------

def alive?(code)
  (200..399).cover?(code)
end

# Returns an HTTP status integer, or 0 on a network/timeout error. Tries HEAD
# first; some object stores reject HEAD (405) or answer oddly, so a non-alive
# verdict is confirmed with a 1-byte ranged GET before being trusted.
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

# --- Recovery (Nuxt source) -------------------------------------------------

# For a dead URL, find the original <img src> derivative the migration dropped.
# The Nuxt markup is <a href="DEAD"><img ... src="DERIVATIVE" ...></a>; the
# migration kept the href and discarded the derivative, which often survives.
#
# Scoped to the Nuxt source of the article that actually references the dead URL
# (same filename) — so generic WordPress filenames reused across posts (e.g.
# IMG_1234.jpg) can never cross-match and suggest another article's derivative.
def recovery_candidate(dead_url, blog_files)
  basename = File.basename(dead_url)
  blog_files.each do |blog_name|
    path = File.join(NUXT_DIR, blog_name)
    next unless File.file?(path)

    m = File.read(path).match(
      /<a[^>]+href="([^"]*#{Regexp.escape(basename)})"[^>]*>\s*<img[^>]+src="([^"]+)"/
    )
    return normalize(m[2]) if m
  end
  nil
end

# --- Main -------------------------------------------------------------------

blog_files = Dir.glob(File.join(BLOG_DIR, "*.md")).sort

# url => Set of referencing blog filenames
references  = Hash.new { |h, k| h[k] = Set.new }
skipped_ids = Set.new

blog_files.each do |path|
  name = File.basename(path)
  extract_srcs(File.read(path)).map { |s| normalize(s) }.each do |url|
    if probeable?(url)
      references[url] << name
    elsif bare_cloudinary_id?(url)
      skipped_ids << url
    end
  end
end

urls = references.keys.sort
puts "Probing #{urls.size} remote image URLs across #{blog_files.size} articles " \
     "(skipping #{skipped_ids.size} in-Cloudinary public-ID images — out of scope)...\n\n"

# Probe concurrently; collect into a thread-safe hash.
results = {}
mutex   = Mutex.new
queue   = Queue.new
urls.each { |u| queue << u }

workers = Array.new(THREADS) do
  Thread.new do
    loop do
      url =
        begin
          queue.pop(true)
        rescue ThreadError # queue drained
          break
        end
      code = probe(url)
      mutex.synchronize { results[url] = code }
    end
  end
end
workers.each(&:join)

puts "Status summary:"
results.values.tally.sort.each { |code, n| puts "  #{code.zero? ? 'ERR' : code}: #{n}" }
puts

dead = urls.reject { |u| alive?(results[u]) }

puts "=== Dead image sources (#{dead.size}) ==="
if dead.empty?
  puts "None — every remote image source resolved."
else
  dead.each do |url|
    files = references[url].to_a.sort
    cand  = recovery_candidate(url, files)
    puts
    puts "DEAD #{results[url].zero? ? 'ERR' : results[url]}  #{url}"
    puts "  referenced by: #{files.join(', ')}"
    if cand
      code = probe(cand)
      puts "  nuxt recovery candidate: #{cand}  -> #{alive?(code) ? "WORKS (#{code})" : "also dead (#{code})"}"
    else
      puts "  nuxt recovery candidate: none found"
    end
  end
end

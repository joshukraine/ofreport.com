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
#   1. Scans content/blog/*.md for every remote image URL (figure shortcodes,
#      markdown images, and cover frontmatter).
#   2. Probes each distinct URL's HTTP status (HEAD, with a ranged-GET retry
#      for hosts that reject HEAD).
#   3. Reports dead URLs grouped with the articles that reference them.
#   4. For each dead URL, looks up the matching Nuxt source article and tries
#      to recover the original <img src> derivative the migration discarded,
#      probing that candidate so a working replacement can be suggested.
#
# It only reads and makes network requests — it never edits content. Remediation
# is applied by hand from this report (the dead set is small and each fix wants
# a human eyeball).
#
# Dependencies: Ruby stdlib only (net/http, uri, thread, optparse).
#
# Usage:
#   ruby scripts/probe-images.rb            # probe all remote image URLs
#   ruby scripts/probe-images.rb --dead     # only print the dead URLs section
#   ruby scripts/probe-images.rb --csv FILE # also write a machine-readable CSV

require "net/http"
require "uri"
require "thread"
require "optparse"
require "set"

BLOG_DIR   = File.expand_path("../content/blog", __dir__)
NUXT_DIR   = File.expand_path("../../ofreport.com-nuxt2/content/articles", __dir__)
CLOUDINARY = "res.cloudinary.com"
THREADS    = 12
TIMEOUT    = 25

options = { dead_only: false, csv: nil }
OptionParser.new do |o|
  o.banner = "Usage: ruby scripts/probe-images.rb [options]"
  o.on("--dead", "Print only the dead-URL section") { options[:dead_only] = true }
  o.on("--csv FILE", "Write a CSV of every probed URL") { |f| options[:csv] = f }
end.parse!

# --- Extraction -------------------------------------------------------------

# Pull every remote (http/https, protocol-relative) image URL out of a file.
# Returns an array of [url, kind] where kind is :figure | :markdown | :cover.
def extract_urls(text)
  found = []

  text.scan(/\{\{<\s*figure\s+[^>]*?src="([^"]+)"/) do |(src)|
    found << [src, :figure]
  end

  text.scan(/!\[[^\]]*\]\((https?:\/\/[^)\s]+|\/\/[^)\s]+)\)/) do |(src)|
    found << [src, :markdown]
  end

  text.scan(/^cover:\s*["']?([^"'\s]+)["']?\s*$/) do |(src)|
    found << [src, :cover]
  end

  found
    .map { |url, kind| [normalize(url), kind] }
    .select { |url, _| remote_image?(url) }
end

def normalize(url)
  url = "https:#{url}" if url.start_with?("//")
  url
end

def remote_image?(url)
  return false unless url.start_with?("http")
  url.match?(/\.(jpe?g|png|gif|webp)$/i)
end

def cloudinary?(url)
  url.include?(CLOUDINARY)
end

# --- Probing ----------------------------------------------------------------

# Returns an HTTP status integer, or 0 on a network/timeout error.
def probe(url)
  status = head_status(url)
  # Some object stores reject HEAD (405) or answer it oddly; confirm with a
  # 1-byte ranged GET before trusting a non-2xx/3xx verdict.
  status = ranged_get_status(url) if status.zero? || status >= 400
  status
rescue StandardError
  0
end

def head_status(url)
  request(url, Net::HTTP::Head.new(URI(url)))
end

def ranged_get_status(url)
  req = Net::HTTP::Get.new(URI(url))
  req["Range"] = "bytes=0-0"
  request(url, req)
end

def request(url, req)
  uri = URI(url)
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
def recovery_candidate(dead_url, nuxt_files_cache)
  basename = File.basename(dead_url)
  nuxt_files_cache.each do |path, text|
    next unless text.include?(basename)

    # Match an <a href="...basename"> immediately wrapping an <img ... src="...">.
    m = text.match(
      /<a[^>]+href="([^"]*#{Regexp.escape(basename)})"[^>]*>\s*<img[^>]+src="([^"]+)"/
    )
    return normalize(m[2]) if m
  end
  nil
end

def load_nuxt_files
  return {} unless Dir.exist?(NUXT_DIR)

  Dir.glob(File.join(NUXT_DIR, "*.md")).each_with_object({}) do |path, h|
    h[path] = File.read(path)
  end
end

# --- Main -------------------------------------------------------------------

# url => { kinds: Set, files: Set }
references = Hash.new { |h, k| h[k] = { kinds: Set.new, files: Set.new } }

Dir.glob(File.join(BLOG_DIR, "*.md")).sort.each do |path|
  name = File.basename(path)
  extract_urls(File.read(path)).each do |url, kind|
    references[url][:kinds] << kind
    references[url][:files] << name
  end
end

urls = references.keys.sort
puts "Probing #{urls.size} distinct remote image URLs across #{Dir.glob(File.join(BLOG_DIR, '*.md')).size} articles...\n\n" unless options[:dead_only]

# Probe concurrently; collect into a thread-safe hash.
results = {}
mutex   = Mutex.new
queue   = Queue.new
urls.each { |u| queue << u }

workers = Array.new(THREADS) do
  Thread.new do
    until queue.empty?
      url = queue.pop(true) rescue break
      code = probe(url)
      mutex.synchronize { results[url] = code }
    end
  end
end
workers.each(&:join)

dead = urls.reject { |u| (200..399).cover?(results[u]) }
nuxt_files = dead.empty? ? {} : load_nuxt_files

unless options[:dead_only]
  by_code = results.values.group_by { |c| c }.transform_values(&:size)
  puts "Status summary:"
  by_code.sort.each { |code, n| puts "  #{code == 0 ? 'ERR' : code}: #{n}" }
  puts
end

puts "=== Dead image sources (#{dead.size}) ==="
if dead.empty?
  puts "None — every remote image source resolved."
else
  dead.each do |url|
    info = references[url]
    cand = recovery_candidate(url, nuxt_files)
    cand_status = cand ? probe(cand) : nil
    puts
    puts "DEAD #{results[url] == 0 ? 'ERR' : results[url]}  #{url}"
    puts "  referenced by: #{info[:files].to_a.sort.join(', ')}"
    if cand
      verdict = (200..399).cover?(cand_status) ? "WORKS (#{cand_status})" : "also dead (#{cand_status})"
      puts "  nuxt recovery candidate: #{cand}  -> #{verdict}"
    else
      puts "  nuxt recovery candidate: none found"
    end
  end
end

if options[:csv]
  require "csv"
  CSV.open(options[:csv], "w") do |csv|
    csv << %w[url status alive cloudinary kinds files]
    urls.each do |url|
      code = results[url]
      csv << [
        url,
        code,
        (200..399).cover?(code),
        cloudinary?(url),
        references[url][:kinds].to_a.sort.join("|"),
        references[url][:files].to_a.sort.join("|"),
      ]
    end
  end
  puts "\nWrote #{options[:csv]}"
end

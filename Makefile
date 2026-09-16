# Local harness for the site.
#
#   make preview   build + serve (the two targets below, in order).
#   make build     Build the site exactly as .github/workflows/deploy.yml does
#                  (production Jekyll build + purgecss) into _site/. That folder is
#                  byte-for-byte what the workflow pushes to gh-pages. ~5 min.
#   make serve     Serve the existing _site/ at http://localhost:4000 without rebuilding.
#   make clean     Remove build output and caches.
#
# Ruby gems are installed into vendor/bundle automatically on first build.
# Requires: ruby + bundler, node/npm (for purgecss), imagemagick (for webp images).

HOST ?= 127.0.0.1
PORT ?= 4000

.PHONY: preview build serve clean

preview: build serve

build: vendor/bundle
	@command -v npx >/dev/null 2>&1 || { echo "npx not found: install Node.js (purgecss needs it)"; exit 1; }
	JEKYLL_ENV=production bundle exec jekyll build
	npx --yes purgecss -c purgecss.config.js

serve:
	@test -d _site || { echo "_site/ not found: run 'make build' first"; exit 1; }
	@echo "Serving _site/ at http://$(HOST):$(PORT)/   (Ctrl-C to stop)"
	@cd _site && python3 -m http.server $(PORT) --bind $(HOST)

clean:
	rm -rf _site .jekyll-cache .jekyll-metadata

vendor/bundle:
	@command -v bundle >/dev/null 2>&1 || { echo "bundler not found: install Ruby, then 'gem install bundler'"; exit 1; }
	bundle config set --local path vendor/bundle
	bundle install --jobs 4

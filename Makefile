# Run what the nightly workflow runs, on your own machine.
#
#   make sync       fetch new posts, then repair anything missing
#   make full-sync  re-fetch every post, not only the new ones
#   make mirror     render the archive into ./site
#   make serve      render it and serve it at http://localhost:8000
#
# The settings come from config.env, the same file the workflow reads.

include config.env
export

ARCHIVER := .archiver
PYTHON ?= python3
PORT ?= 8000

KATEX := $(if $(MIRROR_KATEX),--katex,)
SITE := $(if $(SITE_URL),-s $(SITE_URL),)
IMAGES := $(if $(ARCHIVE_IMAGES),,--no-uploads)

.PHONY: archiver sync full-sync backfill mirror serve clean

# A checkout of the archiver at the ref config.env pins, kept out of git.
archiver:
	@if [ -d $(ARCHIVER)/.git ]; then \
	  git -C $(ARCHIVER) fetch --quiet origin; \
	else \
	  git clone --quiet https://github.com/$(ARCHIVER_REPO).git $(ARCHIVER); \
	fi
	@git -C $(ARCHIVER) checkout --quiet $(ARCHIVER_REF)
	@git -C $(ARCHIVER) --no-pager log --oneline -1

sync: archiver
	$(PYTHON) $(ARCHIVER)/archive.py -u $(DISCOURSE_URL) -t archive $(IMAGES)
	@$(MAKE) --no-print-directory backfill

# Dropping the sync metadata makes the archiver walk the whole site again.
full-sync:
	rm -f archive/.metadata.json
	@$(MAKE) --no-print-directory sync

# Both are no-ops once the archive is complete.
backfill: archiver
	$(PYTHON) $(ARCHIVER)/archive.py -u $(DISCOURSE_URL) -t archive --backfill-topics
	$(if $(ARCHIVE_IMAGES),$(PYTHON) $(ARCHIVER)/archive.py -u $(DISCOURSE_URL) -t archive --backfill-uploads)

mirror: archiver
	$(PYTHON) $(ARCHIVER)/mirror.py -u $(DISCOURSE_URL) -t archive -o site $(KATEX) $(SITE)

serve: mirror
	@echo "serving the mirror on http://localhost:$(PORT)"
	$(PYTHON) -m http.server $(PORT) -d site

clean:
	rm -rf site

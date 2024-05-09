SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
HUGO_PARAMS_contactEmail ?= $(error Please set HUGO_PARAMS_contactEmail)

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

.PHONY: updaterobots
updaterobots:
> curl -sSL \
  https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/main/robots.txt \
  -o static/robots.txt

FINDFILES=find public/ -type f \( -name '*.html' -o -name '*.js' -o -name '*.css' -o -name '*.xml' -o -name '*.svg' \)
.PHONY: compress
compress:
> ${FINDFILES} -exec gzip -v -k -f --best {} \;
> ${FINDFILES} -exec brotli -v -k -f --best {} \;

.PHONY: gitpull
gitpull:
> git pull

.PHONY: hugo
hugo:
> echo using contactEmail - ${HUGO_PARAMS_contactEmail}
> hugo --gc --minify

.PHONY: build
build: gitpull hugo compress

SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >

updaterobots:
> curl -sSL \
  https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/main/robots.txt \
  -o static/robots.txt
.PHONY: updaterobots

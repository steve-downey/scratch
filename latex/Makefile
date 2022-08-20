#! /usr/bin/make -f
# -*-makefile-*-


# These targets are only run locally
CMAKE_FLAGS?=
DEPS_DIR := .deps
MAKEFLAGS += --no-builtin-rules
VENV := .venv/
PIP := $(PYEXEC) -m pip
PIP_SYNC := $(PYEXEC) -m piptools sync
PYEXEC := $(SOURCE_VENV) python
PYEXECPATH ?= $(shell which python3.10 || which python3.9 || which python3.8 || which python3.7 || which python3)
PYTHON ?= $(shell basename $(PYEXECPATH))
REQS_MARKER := $(VENV)/bin/.pip-sync
SOURCE_VENV := . $(VENV)/bin/activate;

.DEFAULT_GOAL := help

override DEPS := $(VENV) wg21.bib

export

$(VENV):
	$(PYTHON) -m venv $(VENV)
	$(PIP) install setuptools pip pip-tools wheel
	$(PIP_SYNC) requirements.txt

.PHONY: create-venv
create-venv:  ## Set up python VM for minted
	rm -rf $(VENV)
	make $(VENV)

%.pdf : %.tex wg21.bib | $(VENV)
	mkdir -p $(DEPS_DIR)
	$(SOURCE_VENV) latexmk -shell-escape -pdflua -use-make -deps -deps-out=$(DEPS_DIR)/$@.d -MP $<

wg21.bib: ## Download bibliography
	curl https://wg21.link/index.bib > wg21.bib

.PHONY: clean
clean: ## Clean
	latexmk -c

# Include dependencies
$(foreach file,$(TARGET),$(eval -include $(DEPS_DIR)/$(file).d))


.SUFFIXES:

# Include dependencies
$(foreach file,$(TARGET),$(eval -include $(DEPS_DIR)/$(file).d))

# Help target
.PHONY: help
help: ## Show this help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'  $(MAKEFILE_LIST) | sort

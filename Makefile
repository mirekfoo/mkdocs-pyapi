help:
	@echo "Available targets:"
	@echo "  help                                     - Show this help message"
	@echo ""
	@echo "  deps-dev-install                         - Install dependencies for development"
	@echo "  deps-dev-update                          - Update dependencies for development"
	@echo ""
	@echo "  pyutils-dev-update                       - Update pyutils for development"
	@echo ""
	@echo "  mkdocs CMD=build|serve|gh-deploy         - [Build / Serve/ Deploy to GitHub Pages] web docs using mkdocs"
	@echo "  mkdocs-clean                             - Clean the web docs"
	@echo ""
	@echo "  mddocs-build                             - Build markdown docs using mddocs"
	@echo "  mddocs-clean                             - Clean the markdown docs"
	@echo "  mddocs-run                               - Run again mddocs to update docs"	
	@echo ""
	@echo "  bumpver LEVEL=major|minor|patch          - Bump version"
	
# --------------------------------------------------

STAMP = @if [ ! -d ".stamps" ]; then mkdir -p ".stamps"; fi && touch $@

# --------------------------------------------------

MKDOCS_INSTALL = .stamps/mkdocs-install.done

$(MKDOCS_INSTALL):
	pip install mkdocs mkdocs-material mkdocstrings[python] mkdocs-gen-files 
	$(STAMP)

DOCS_WEB_DIR = docs-web

# --------------------------------------------------

PYUTILS_INSTALL = $(EDIT_DEP_PYUTILS_INSTALL)

# --------------------------------------------------

mkdocs: $(MKDOCS_INSTALL) $(PYUTILS_INSTALL)
	PYTHONPATH=./src python -m mkdocs_pyapi $(CMD)

mkdocs-clean:
	rm -f $(DOCS_WEB_DIR)
	rm -rf docs-web-site

# --------------------------------------------------

MDDOCS_DEV_INSTALL = .stamps/mddocs-dev-install.done

$(MDDOCS_DEV_INSTALL):
	if [ ! -d "deps/mddocs" ]; then git clone https://github.com/mirekfoo/mddocs.git deps/mddocs; fi
	pip install -e deps/mddocs
	$(STAMP)

mddocs-dev-install: $(MDDOCS_DEV_INSTALL)

# --------------------------------------------------

MDDOCS_DIR = docs-md

PROJECT_SRC := $(wildcard src/mkdocs-pyapi/*.py)

MDDOCS_GENERATE = .stamps/mddocs_generate.done

$(MDDOCS_GENERATE): $(MDDOCS_DEV_INSTALL) $(PROJECT_SRC)
	PYTHONPATH=./src python -m mddocs 
	$(STAMP)

mddocs-build: \
	$(MDDOCS_GENERATE)

mddocs-clean:
	rm -rf $(MDDOCS_DIR)
	rm -f $(MDDOCS_GENERATE)

mddocs-run: \
	mddocs-clean \
	$(MDDOCS_GENERATE)

# --------------------------------------------------

PYUTILS_DEV_INSTALL = .stamps/pyutils-dev-install.done

# install editable pyutils AFTER mddocs to avoid unwanted pyutils reinstall due to github source-pinned dependency
$(PYUTILS_DEV_INSTALL): mddocs-dev-install
	pip install -e deps/pyutils
	$(STAMP)

pyutils-dev-install: $(PYUTILS_DEV_INSTALL)

pyutils-dev-update: $(PYUTILS_DEV_INSTALL)
	pushd deps/pyutils && git switch main && git pull && popd

deps-dev-install: pyutils-dev-install
deps-dev-update: pyutils-dev-update

# --------------------------------------------------

BUMPVER_INSTALL = .stamps/bumpver-install.done

$(BUMPVER_INSTALL):
	pip install bumpver 
	$(STAMP)

bumpver: $(BUMPVER_INSTALL)
	bumpver update --$(LEVEL)

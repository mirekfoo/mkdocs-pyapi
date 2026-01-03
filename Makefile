help:
	@echo "Available targets:"
	@echo "  help                                     - Show this help message"
	@echo ""
	@echo "  edit-deps-install                        - Install editable dependencies"
	@echo "  edit-deps-update                         - Update editable dependencies"
	@echo ""
	@echo "  pyutils-update                           - Update pyutils"
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

PIP_CONSTRAINTS_FILE = .pip/constraints.txt

define ADD_EDIT_DEP_CONSTRAINT
	@if [ ! -d ".pip" ]; then mkdir -p ".pip"; fi
	@pip show $(1) | awk '/Editable project location:/ {print "$(1) @ file://" $$4}' >>$(PIP_CONSTRAINTS_FILE)
endef

$(PIP_CONSTRAINTS_FILE):
	@touch "$(PIP_CONSTRAINTS_FILE)"

# --------------------------------------------------

EDIT_DEP_PYUTILS_INSTALL = .stamps/edit-dep-pyutils-install.done

$(EDIT_DEP_PYUTILS_INSTALL):
	pip install -e deps/pyutils
	$(call ADD_EDIT_DEP_CONSTRAINT,pyutils)
	$(STAMP)

edit-deps-install: $(EDIT_DEP_PYUTILS_INSTALL)

pyutils-update: $(EDIT_DEP_PYUTILS_INSTALL)
	pushd deps/pyutils && git switch main && git pull && popd

edit-deps-update: edit-deps-install pyutils-update

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

MDDOCS_INSTALL = .stamps/mddocs-install.done

$(MDDOCS_INSTALL): $(PIP_CONSTRAINTS_FILE)
	pip install --no-cache-dir -c $(PIP_CONSTRAINTS_FILE) git+https://github.com/mirekfoo/mddocs.git 
	$(STAMP)

mddocs-install: $(MDDOCS_INSTALL)

# --------------------------------------------------

MDDOCS_DIR = docs-md

PROJECT_SRC := $(wildcard src/mkdocs-pyapi/*.py)

MDDOCS_GENERATE = .stamps/mddocs_generate.done

$(MDDOCS_GENERATE): $(MDDOCS_INSTALL) $(PROJECT_SRC)
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

BUMPVER_INSTALL = .stamps/bumpver-install.done

$(BUMPVER_INSTALL):
	pip install bumpver 
	$(STAMP)

bumpver: $(BUMPVER_INSTALL)
	bumpver update --$(LEVEL)

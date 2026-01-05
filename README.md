# mkdocs-pyapi
Complete solution for Python project API documentation generation using MKDocs.

# Intro

This project integrates:
- [MKDocs](https://www.mkdocs.org/)
- [mkdocstrings\[python\]](https://mkdocstrings.github.io/) 
- [mkdocs-gen-files](https://github.com/oprypin/mkdocs-gen-files)
- [gen_api.py](src/mkdocs_pyapi/gen_api.py) custom script for project API crawler

into a single command `mkdocs-pyapi` to generate Python project API documentation in HTML.

# Usage 

## Setup

* Install `mkdocs-pyapi`:

```bash
pip install git+https://github.com/mirekfoo/mkdocs-pyapi.git
```

* Create `mkdocs-pyapi.yml` file in the root of your project. 
    - See examples:
        - [mkdocs-pyapi.yml](./mkdocs-pyapi.yml) for this project.
        - [mkdocs-pyapi.yml](https://github.com/mirekfoo/pyutils/blob/main/mkdocs-pyapi.yml) for [pyutils](https://github.com/mirekfoo/pyutils) project.
    - For `mkdocs` section refer to:
        - MkDocs User Guide - [Configuration](https://www.mkdocs.org/user-guide/configuration/),
        - [mkdocs.yml](https://github.com/oprypin/mkdocs-gen-files/blob/master/mkdocs.yml) in [mkdocs-gen-files](https://github.com/oprypin/mkdocs-gen-files) repository.

* Optionally create (assuming `docs-web` is your **mkdocs-pyapi** root directory):
    - `docs-web\docs\index.md` main doc page file
    - and other custom doc pages.

## Generate docs

* Run:
```bash
mkdocs-pyapi build|serve|gh-deploy
```

* for more CLI options refer to MkDocs User Guide - [CLI](https://www.mkdocs.org/user-guide/cli/)

# Dev Docs

Docs|Remarks
---|---
[Markdown docs](docs-md/docs/index.md)|Generated using [mddocs](https://github.com/mirekfoo/mddocs)

# Project Development

## Submodules

The following submodules were added to this project:

```bash
git submodule add https://github.com/mirekfoo/pyutils.git deps/pyutils
```

## Clone repository
```bash
git clone --recurse-submodules https://github.com/mirekfoo/mkdocs-pyapi.git
```

## Run procedures
* Type `make help` for available **dev** procedures

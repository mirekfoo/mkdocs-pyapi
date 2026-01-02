---
sidebar_label: gen_api
title: mkdocs_pyapi.gen_api
---

Script to generate project API (markdown) docs for further web docs generation using mkdocs.

#### get\_module\_docstring

```python
def get_module_docstring(path: str | Path) -> str | None
```

Get module docstring.

#### get\_first\_doc\_sentence

```python
def get_first_doc_sentence(doc: str) -> str
```

Get first sentence from doc string.

#### multiplex\_write

```python
def multiplex_write(fs: list, s: str)
```

Write string to multiple files.

#### multiplex\_close

```python
def multiplex_close(fs: list, s: str)
```

Close multiple files.


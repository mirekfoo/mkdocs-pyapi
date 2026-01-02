"""An overlay for mkdocs to generate python project web docs including API doc pages."""

import argparse
import sys
import os
from pathlib import Path
import yaml
#from jinja2 import Template, Environment
import runpy

from pyutils import config_util, jinja2_util

#jinja2_env = None

def run_module_with_args(module_name: str, args: list[str], cwd: str = None) -> int:
    old_argv = sys.argv
    try:
        prev_cwd = None
        if cwd:
            prev_cwd = os.getcwd()
            os.chdir(cwd)
        sys.argv = [module_name] + args
        try:
            runpy.run_module(module_name, run_name="__main__")
            return 0  # normal completion
        except SystemExit as e:
            return int(e.code) if isinstance(e.code, int) else 1
    finally:
        sys.argv = old_argv
        if prev_cwd:
            os.chdir(prev_cwd)

def run() -> int:

    #print(__file__, " sys.path = ", sys.path)

    # 2. Parses command-line arguments.
    p = argparse.ArgumentParser(
        description=(
            "HTML Documentation generator for python project(s) API.\n"
            "See https://github.com/mirekfoo/mkdocs-pyapi/blob/main/README.md for more information."
            ),
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    p.add_argument("mkdocs_command", nargs="?", help="optional mkdocs command (build|serve|gh-deploy)")
    args = p.parse_args()

    # 3. Loads the 'mddocs.yml' configuration file.
    mkdocs_pyapi_yml = Path("mkdocs-pyapi.yml")
    if not mkdocs_pyapi_yml.exists():
        raise SystemExit(f"File not found: {mkdocs_pyapi_yml}")

    config = yaml.safe_load(mkdocs_pyapi_yml.read_text())

    src_root = config_util.read_config_arg(config, "src_root", "src")
    src_root_path = Path(src_root)
    config["src_root"] = str(src_root_path.absolute())
    docs_root = config_util.read_config_arg(config, "docs_root", "docs-web")
    docs_root_path = Path(docs_root)
    config["docs_root"] = str(docs_root_path.absolute())
    site_root = config_util.read_config_arg(config, "site_root", "docs-web-site")
    site_root_path = Path(site_root)
    config["site_root"] = str(site_root_path.absolute())

    docs_root_path.mkdir(parents=True, exist_ok=True)

    docs_root_config = {}
    docs_root_config["src_root"] = str(Path(config["src_root"]).relative_to(config["docs_root"], walk_up=True))
    docs_root_config["docs_root"] = str(Path(config["docs_root"]).relative_to(config["docs_root"], walk_up=True))
    docs_root_config["site_root"] = str(Path(config["site_root"]).relative_to(config["docs_root"], walk_up=True))
    with open(Path(docs_root_path, "pyapi.yml"), "w") as f:
        f.write("# GENERATED UPON mkdocs-pyapi.yml . DO NOT EDIT.\n")
        f.write(yaml.dump(docs_root_config))


    # 5. Expands templates in the configuration and writes 'mkdocs.yml'.
    mkdocs = config_util.read_config_arg(config, "mkdocs", {})
    gen_api_py_path = Path(__file__).parent.joinpath("gen_api.py")
    config["mkdocs_pyapi"] = str(gen_api_py_path)
    mkdocs = jinja2_util.expandTemplates(mkdocs, config)

    with open(Path(docs_root_path, "mkdocs.yml"), "w") as f:
        f.write("# GENERATED UPON mkdocs-pyapi.yml . DO NOT EDIT.\n")
        yaml.dump(mkdocs, f)
    
    mkdocs_docs_path = Path(docs_root_path, config_util.read_config_harg(config, "mkdocs.docs_dir", "docs"))
    mkdocs_docs_path.mkdir(parents=True, exist_ok=True)

    print(f"Running mkdocs in {docs_root_path} ...")
    mkdocs_command = []
    if args.mkdocs_command:
        mkdocs_command.append(args.mkdocs_command)
    result = run_module_with_args("mkdocs", mkdocs_command, cwd=str(docs_root_path))
    if result != 0:
        return result

    return 0
        
def main() -> int:
    """
    Main entry point of the program.

    Returns:
        The exit code of the program.
    """
    try:
        return run()
    except Exception as e:
        print(f"Error: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
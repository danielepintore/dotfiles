#!/usr/bin/env python3

import os
from os import path
import re
import shutil
import subprocess
import sys


def convert(
    force,
    syntax,
    extension,
    output_dir,
    input_file,
    css_file,
    template_path,
    template_default,
    template_ext,
    root_path,
    custom_args,
):
    if shutil.which("pandoc") is None:
        print("Error: pandoc not found", file=sys.stderr)
        sys.exit(1)

    if syntax != "markdown":
        print("Error: Unsupported syntax", file=sys.stderr)
        sys.exit(1)

    input_file_name = path.splitext(path.basename(input_file))[0]
    output_file = path.join(output_dir, input_file_name) + path.extsep + "html"

    with open(input_file, "r", encoding="utf8") as f:
        lines = f.read()

    # Look for title in metadata
    match = re.search(
        "^(?:---|\.\.\.)$\n.*title: ([^\n]+)$\n.*^(?:---|\.\.\.)$",
        lines,
        re.MULTILINE | re.DOTALL,
    )
    title = match.group(1) if match else input_file_name.title()

    template = path.join(template_path, template_default + path.extsep + template_ext)
    command = [
        "pandoc",
        "--filter={}/.config/vimwiki/linkParser.hs".format(os.environ['HOME']),
        "--filter={}/.config/vimwiki/checkBoxParser.hs".format(os.environ['HOME']),
        "--section-divs",
        "--template={}".format(template) if path.isfile(template) else "",
        #"--variable=css={}".format(css_file) if path.isfile(css_file) else "",
        "-s",
        "--highlight-style=pygments",
        "--metadata",
        "pagetitle={}".format(title),
        custom_args if custom_args != "-" else "",
        "-f",
        "markdown",
        "-t",
        "html",
        "-o",
        output_file,
        "-",
    ]

    # Prune empty elements from command list
    command = list(filter(None, command))

    # Run command
    subprocess.run(command, check=True, encoding="utf8", input=lines)


if __name__ == "__main__":
    convert(*sys.argv[1:])

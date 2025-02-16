#!/usr/bin/env python3
"""Check and sync semantic versions across project

IEEE 1788 Interval Arithmetic native library for Ada
Copyright (C) 2024,2025 Torsten Knodt

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

As a special exception to the GNU Lesser General Public License version 3
("LGPL3"), the copyright holders of this Library give you permission to convey
to a third party a Combined Work that links statically or dynamically to this
Library without providing any Minimal Corresponding Source or Minimal
Application Code as set out in 4d or providing the installation information set
out in section 4e, provided that you comply with the other provisions of LGPL3
and provided that you meet, for the Application the terms and conditions of the
license(s) which apply to the Application.

Except as stated in this special exception, the provisions of LGPL3 will
continue to comply in full to this Library. If you modify this Library, you
may apply this exception to your version of this Library, but you are not
obliged to do so. If you do not wish to do so, delete this exception statement
from your version. This exception does not (and cannot) modify any license terms
which apply to the Application, with which you must still comply.
"""

import argparse
import pathlib
import semver
import subprocess
import sys
import tomlkit

parser = argparse.ArgumentParser(
    description="Check and sync semantic versions across project"
)
parser.add_argument(
    "files",
    nargs="*",
    help="Files to check",
    default=pathlib.Path(".").rglob("alire.toml"),
)
args = parser.parse_args()


git_version: str = (
    subprocess.check_output(["git", "describe", "--tags", "--always"], shell=False)
    .decode()
    .strip()
)

version: str | None
try:
    version = str(semver.Version.parse(git_version))
except (ValueError, TypeError):
    try:
        version = str(semver.Version.parse("0.0.1-dev+" + git_version))
    except (ValueError, TypeError):
        version = None

success: bool = True
for toml_file in args.files:
    with open(toml_file, encoding="US-ASCII") as f:
        data: tomlkit.TOMLDocument = tomlkit.load(f)

    if "version" in data:
        if data["version"] != version:
            data["version"] = version
            with open(toml_file, mode="w", encoding="US-ASCII") as f:
                tomlkit.dump(data, f)
            success = False

sys.exit(0 if success else 1)

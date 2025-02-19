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
from your version. This exception does not (and cannot) modify any license
terms which apply to the Application, with which you must still comply.
"""

import argparse
import logging
import pathlib
import subprocess
import sys

import semver
import tomlkit

LOG_LEVELS = {
    "DEBUG": logging.DEBUG,
    "INFO": logging.INFO,
    "WARNING": logging.WARNING,
    "ERROR": logging.ERROR,
    "CRITICAL": logging.CRITICAL,
}


def parse_log_level(level_str: str) -> int:
    """Parse string or int to logging level"""
    try:
        return int(level_str)
    except ValueError as exc:
        level = LOG_LEVELS.get(level_str.upper())
        if level is not None:
            return level
        raise ValueError(f"Invalid log level: {level_str}") from exc


parser = argparse.ArgumentParser(
    description="Check and sync semantic versions across project"
)
parser.add_argument(
    "files",
    nargs="*",
    help="Files to check",
    default=pathlib.Path(".").rglob("alire.toml"),
)
parser.add_argument(
    "--log-level",
    default="INFO",
    help="Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL or integer)",
    type=parse_log_level,
)
parser.add_argument(
    "--force-version",
    help="Force to set a specific semantic version",
    type=semver.version.Version.parse,
)
args: argparse.Namespace = parser.parse_args()

logging.basicConfig(level=args.log_level)

version: semver.Version
COUNT: int
try:
    version = semver.version.Version.parse(
        (
            subprocess.check_output(
                ["git", "describe", "--tags", "--abbrev=0"], shell=False
            )
            .decode()
            .strip()
        )
    )
    COUNT = int(
        subprocess.check_output(
            ["git", "rev-list", str(version) + "..HEAD", "--count", "--no-merges"],
            shell=False,
        )
        .decode()
        .strip()
    )
except (subprocess.CalledProcessError, ValueError, TypeError):
    version = semver.version.Version.parse("0.0.1")
    COUNT = int(
        subprocess.check_output(
            ["git", "rev-list", "HEAD", "--count", "--no-merges"], shell=False
        )
        .decode()
        .strip()
    )
logging.info("Raw Version=%s COUNT=%s", version, COUNT)

clean: bool = (
    subprocess.check_output(["git", "status", "--porcelain"], shell=False)
    .decode()
    .strip()
    == ""
)
logging.info("Clean=%r", clean)

build: int = COUNT + (0 if clean else 1)
logging.info("Build=%i", build)


base_branch: str = (
    subprocess.check_output(["git", "rev-parse", "--abbrev-ref", "HEAD"], shell=False)
    .decode()
    .strip()
)

merge_base: str = (
    subprocess.check_output(["git", "merge-base", "HEAD", "origin/main"], shell=False)
    .decode()
    .strip()
)

BASE_VERSION: semver.version.Version | None
if merge_base:
    base_version_str: str = (
        subprocess.check_output(
            ["git", "show", f"{merge_base}:alire.toml"], shell=False
        )
        .decode()
        .strip()
    )

    base_data = tomlkit.loads(base_version_str)

    BASE_VERSION: semver.version.Version = semver.version.Version.parse(
        str(base_data["version"])
    )
else:
    BASE_VERSION = None

logging.info("Base Version=%s", BASE_VERSION)

if build > 0:
    version = version.replace(prerelease="dev", build=build)
logging.info("Calculated Version=%s", version)

if args.force_version:
    if version != args.force_version:
        logging.warning(
            "Forced version %s != calculated version %s",
            args.force_version,
            version,
        )
    version = args.force_version

if version <= BASE_VERSION:
    logging.error(
        "The version %s we will propose will not be greater than the base version %s",
        version,
        BASE_VERSION,
    )

SUCCESS: bool = True
for toml_file in args.files:
    logging.info("Processing: %r", toml_file)
    with open(toml_file, encoding="US-ASCII") as f:
        data: tomlkit.TOMLDocument = tomlkit.load(f)

    old_version: semver.version.Version | None = (
        semver.version.Version.parse(data["version"]) if "version" in data else None
    )

    if version:
        if BASE_VERSION and version <= BASE_VERSION:
            logging.error(
                "The version %s we will propose will not be greater than the base version %s",
                version,
                BASE_VERSION,
            )
        logging.log(
            (
                logging.ERROR
                if old_version < version
                else (logging.INFO if old_version == version else (logging.WARNING))
            ),
            "%s%s%s",
            old_version,
            " == " if old_version == version else " != ",
            version,
        )
    if not version or old_version != version:
        data["version"] = str(version)
        with open(toml_file, mode="w", encoding="US-ASCII") as f:
            tomlkit.dump(data, f)
        SUCCESS = False

sys.exit(0 if SUCCESS else 1)

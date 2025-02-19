#!/usr/bin/env python3
"""Verify that Git tag matches version in alire.toml files"""

import logging
import os
import pathlib
import subprocess
import sys

import semver
import tomlkit

logging.basicConfig(level=logging.INFO)
if github_ref := os.getenv("GITHUB_REF", None):
    tag_name = pathlib.Path(github_ref).parts[-1]
else:
    tag_name = subprocess.check_output(["git", "describe", "--tags"], text=True).strip()


tag_version = semver.Version.parse(tag_name)

logging.info("Checking tag: %s", tag_version)

for toml_file in pathlib.Path(os.getenv("GITHUB_WORKSPACE", ".")).rglob("alire.toml"):
    with open(toml_file, mode="rt", encoding="us-ascii") as f:
        alire_data = tomlkit.load(f)

        file_version: semver.Version | None = (
            semver.Version.parse(str(alire_data["version"]))
            if "version" in alire_data
            else None
        )
        if not file_version:
            logging.warning("No version found in %s", toml_file)
            continue

        if tag_version != file_version:
            logging.error(
                "Version mismatch in %s: tag=%s file=%s",
                toml_file,
                tag_version,
                file_version,
            )
            sys.exit(1)

sys.exit(0)

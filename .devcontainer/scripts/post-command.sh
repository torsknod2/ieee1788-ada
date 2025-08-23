#!/bin/bash
set -x

getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print $6}' | while read -r home; do
	sudo chown -cR --reference "$home" "$home"
done
alr toolchain --select gnat_native gprbuild
alr install libadalang_tools gnatcov gnatprove
if [ -r alire.toml ]; then
	alr update
fi
pipx upgrade-all
pipx install uv
if [ -r requirements.txt ]; then
	python3 -m venv --upgrade-deps .venv
	(cd ~ && alr get libadalang)
	pip install ~/libadalang_*/python
	.venv/bin/pip install -U -r requirements.txt
fi
if [ -r .pre-commit-config.yaml ]; then
	pre-commit install --install-hooks
	pre-commit autoupdate
fi

# Ada native implementation of IEEE 1788

## Introduction

(So far partial) Ada native implementation of IEEE 1788 .
The goal is to have interval arithmetic support for all:

* integer
* modulo
* delta
* and floating point
data types in Ada.
Limitations are given by the operations available for the respective Ada data types.

## Status Badges

* [![Dependabot Updates][dependabot-badge]][dependabot-url]
* [![CI/ CD][cicd-badge]][cicd-url]
* [![Dependency Review][dep-review-badge]][dep-review-url]
* [![FlawFinder][flawfinder-badge]][flawfinder-url]
* [![OpenSSF Scorecard][scorecard-badge]][scorecard-url]
* [![OpenSSF Best Practices][best-practices-badge]][best-practices-url]

[dependabot-badge]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/dependabot/dependabot-updates/badge.svg
[dependabot-url]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/dependabot/dependabot-updates
[cicd-badge]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/cicd.yaml/badge.svg
[cicd-url]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/cicd.yaml
[dep-review-badge]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/dependency-review.yml/badge.svg
[dep-review-url]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/dependency-review.yml
[flawfinder-badge]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/flawfinder.yml/badge.svg
[flawfinder-url]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/flawfinder.yml
[scorecard-badge]: https://api.scorecard.dev/projects/github.com/torsknod2/ieee1788-ada/badge
[scorecard-url]: https://scorecard.dev/viewer/?uri=github.com/torsknod2/ieee1788-ada
[best-practices-badge]: https://bestpractices.coreinfrastructure.org/projects/10022/badge
[best-practices-url]: https://bestpractices.coreinfrastructure.org/projects/10022

## Getting Started

### Build and Test

Building and testing requires the following tools to be installed:

* Alire package manager
* GNAT native toolchain
* GPRBuild
* GNATcov (for coverage analysis)
* GNATformat (for code formatting)
* GNATprove (for formal verification)

### Testing and Analysis

```bash
# Install toolchain via Alire
alr install gnat_native gprbuild gnatcov gnatformat gnatprove

# Validation Build
alr build --validation

# Run formal verification with GNATprove
alr gnatprove --proof=progressive:all --level=4 -j0 --checks-as-errors=on --warnings=error

# Run tests with coverage
cd tests
alr build --validation --stop-after=generation
alr gnatcov instrument --level=stmt+mcdc --dump-trigger=atexit --projects=../ieee1788.gpr
alr build --validation -- --src-subdirs=gnatcov-instr --implicit-with=gnatcov_rts_full
alr run --skip-build --args "aunit_results.xml"
```

### Coverage Reports

Coverage reports can be generated in various formats:

* XCOV+
* DHTML
* HTML+
* SARIF
in the `gnatcov_out` directory.
TODO: Describe how.

### Documentation

TODO: Build documentation

## Contribute

### Pre-commit Checks

```bash
# Install and run pre-commit hooks
pip install -r requirements.txt
pre-commit run --all-files
```

TODO: Explain how other users and developers can contribute to make your code better.

If you want to learn more about creating good readme files then refer the following
[guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops).
You can also seek inspiration from the below readme files:

* [ASP.NET Core](https://github.com/aspnet/Home)
* [Visual Studio Code](https://github.com/Microsoft/vscode)
* [Chakra Core](https://github.com/Microsoft/ChakraCore)

# Ada native implementation of IEEE 1788

## Introduction

(So far partial) Ada native implementation of IEEE 1788 .
The goal is to have interval arithmetic support for all:

- integer
- modulo
- delta
- and floating point
  data types in Ada.
  Limitations are given by the operations available for the respective Ada data types.

## Maturity

This library is currently in early implementation, traceability to the
respective standard documents is not provided and even for the implemented
functionality, reviews against the standard have not even begun.
Do not use it not baselined/ unreleased or with a baseline/ release below
`1.0.0` in production, even if neither safety- nor security-relevant.

## Status Badges

- [![Best Practices][best-practices-badge]][best-practices-url]
- [![CI/ CD][cicd-badge]][cicd-url]
- [![Code Coverage][codecov-badge]][codecov-url]
- [![Dependency Review][dep-review-badge]][dep-review-url]
- [![Dependabot Updates][dependabot-badge]][dependabot-url]

[best-practices-badge]: https://bestpractices.coreinfrastructure.org/projects/10022/badge
[best-practices-url]: https://bestpractices.coreinfrastructure.org/projects/10022
[cicd-badge]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/cicd.yaml/badge.svg
[cicd-url]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/cicd.yaml
[codecov-badge]: https://codecov.io/gh/torsknod2/ieee1788-ada/graph/badge.svg?token=KSOUO8UJSL
[codecov-url]: https://codecov.io/gh/torsknod2/ieee1788-ada
[dep-review-badge]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/dependency-review.yml/badge.svg
[dep-review-url]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/dependency-review.yml
[dependabot-badge]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/dependabot/dependabot-updates/badge.svg
[dependabot-url]: https://github.com/torsknod2/ieee1788-ada/actions/workflows/dependabot/dependabot-updates

## Getting Started

### Build and Test

Building and testing requires the following tools to be installed:

- Alire package manager
- GNAT native toolchain
- GPRBuild
- GNATcov (for coverage analysis)
- GNATformat (for code formatting)
- GNATprove (for formal verification)

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

- XCOV+
- DHTML
- HTML+
- SARIF
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

- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)

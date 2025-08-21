# Copilot Instructions for IEEE 1788 Ada Library

Always reference existing repository documentation first before using search or bash commands.

## Required Reading

For general project information, build instructions, and contribution guidelines, refer to:
- [README.md](../README.md) - Project overview, build instructions, toolchain setup
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Contribution guidelines and development process
- [.github/workflows/cicd.yaml](workflows/cicd.yaml) - Complete CI/CD workflow with verified commands

## Copilot-Specific Development Notes

### Sandboxed Environment Setup
```bash
# PATH configuration for Alire in sandboxed environment
export PATH=$PATH:/home/runner/.alire/bin
```

### Critical Timing and Automation Warnings
- **Toolchain installation**: Takes 15-30 seconds total - **NEVER CANCEL**
- **GNATformat installation**: Takes 10+ minutes - Set timeout to 15+ minutes, **NEVER CANCEL**
- **Regular builds**: < 5 seconds - **NEVER CANCEL**
- **Test execution**: < 10 seconds total - **NEVER CANCEL**
- **Pre-commit hooks**: 3-10 minutes, may fail due to network issues - Set timeout to 10+ minutes

### Ada Style Validation Requirements
- `alr build --validation` will FAIL if style issues exist
- Always run `alr build` first to see style warnings before attempting `--validation`
- Known style issue pattern: Array initializers need space after `[` (check `src/ieee1788.adb`)

### Essential Validation Workflow
1. **Build validation**: `alr build` (must succeed, style warnings acceptable)
2. **Test validation**: `cd tests && alr build && alr run` (must pass all tests)
3. **Style validation**: `alr build --validation` (must succeed after fixing style issues)
4. **Formal verification**: `alr gnatprove --proof=progressive:all --level=4 -j0` (should complete without errors)

### Expected Test Output Format
```xml
<?xml version='1.0' encoding='utf-8' ?>
<TestRun>
  <Statistics>
    <Tests>[number > 0]</Tests>
    <FailuresTotal>0</FailuresTotal>
    <Failures>0</Failures>
    <Errors>0</Errors>
  </Statistics>
  <SuccessfulTests>
    <Test>
      <Name>[test name]</Name>
    </Test>
    <!-- Additional successful tests may appear here -->
  </SuccessfulTests>
</TestRun>
```

### Agent-Specific Troubleshooting
- **Network restrictions**: Alire package downloads are generally reliable, but pre-commit may timeout
- **Coverage testing**: Complex multi-step process - avoid unless specifically needed, primarily for CI
- **Missing tools**: Run `alr install gnat_native gprbuild gnatcov` if build fails
- **PATH issues**: Ensure `/home/runner/.alire/bin` is in PATH for tool access

### File Locations for Quick Reference
- Main library: `src/ieee1788.ads`, `src/ieee1788.adb`
- Test suite: `tests/src/` (separate Alire project)
- Project config: `alire.toml`, `ieee1788.gpr`
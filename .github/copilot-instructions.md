# IEEE 1788 Ada Library

Ada native implementation of IEEE 1788 interval arithmetic library using the Alire package manager and modern Ada development tools.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Environment Setup and Toolchain Installation

**Install Alire Package Manager:**
```bash
cd /tmp
wget https://github.com/alire-project/alire/releases/download/v2.0.2/alr-2.0.2-bin-x86_64-linux.zip
unzip alr-2.0.2-bin-x86_64-linux.zip
sudo cp bin/alr /usr/local/bin/
```

**Install Ada Toolchain:**
```bash
# Install basic toolchain - takes 15-30 seconds. NEVER CANCEL.
alr install gnat_native gprbuild gnatcov

# Install formal verification (optional) - takes 15 seconds. NEVER CANCEL.
alr install gnatprove

# Install code formatter (optional) - takes 10+ minutes. NEVER CANCEL. Set timeout to 15+ minutes.
alr install gnatformat
```

**Set PATH permanently:**
```bash
export PATH=$PATH:/home/runner/.alire/bin
# Add to ~/.bashrc for persistence
```

### Build and Test Workflow

**Basic Build:**
```bash
# Regular build - takes < 5 seconds. NEVER CANCEL.
alr build

# Strict validation build - takes < 5 seconds but REQUIRES style fixes. NEVER CANCEL.
alr build --validation
```

**Run Tests:**
```bash
# Build tests - takes < 10 seconds. NEVER CANCEL.
cd tests
alr build

# Run test suite - takes < 5 seconds. NEVER CANCEL.
alr run
```

**Formal Verification:**
```bash
# Run GNATprove formal verification - takes < 5 seconds. NEVER CANCEL.
alr gnatprove --proof=progressive:all --level=4 -j0 --checks-as-errors=on --warnings=error
```

### Advanced Workflows

**Coverage Testing (Complex Multi-Step Process):**
```bash
cd tests

# Step 1: Generate configuration - takes < 5 seconds. NEVER CANCEL.
alr build --validation --stop-after=generation

# Step 2: Instrument code for coverage - takes < 5 seconds. NEVER CANCEL.  
alr gnatcov instrument --level=stmt+mcdc --dump-trigger=atexit --projects=../ieee1788.gpr

# Step 3: Build and install gnatcov runtime - takes 30-60 seconds. NEVER CANCEL.
export GNATCOV_RTS_BUILD_PATH="/tmp/gnatcov_rts-build"
export GNATCOV_RTS_INSTALL_PATH="/tmp/gnatcov_rts-install"
mkdir -p "${GNATCOV_RTS_BUILD_PATH}"
cd "${GNATCOV_RTS_BUILD_PATH}"
gprbuild -p -P~/.alire/share/gnatcoverage/gnatcov_rts/gnatcov_rts_full.gpr
gprinstall -p -P~/.alire/share/gnatcoverage/gnatcov_rts/gnatcov_rts_full.gpr --prefix="${GNATCOV_RTS_INSTALL_PATH}"
export GPR_PROJECT_PATH="${GNATCOV_RTS_INSTALL_PATH}/share/gpr:${GPR_PROJECT_PATH}"

# Step 4: Build instrumented test code - takes < 10 seconds. NEVER CANCEL.
cd /path/to/tests
alr build --validation -- --src-subdirs=gnatcov-instr --implicit-with=gnatcov_rts_full

# Step 5: Run instrumented tests - takes < 5 seconds. NEVER CANCEL.
alr run --skip-build --args "results.xml"

# Coverage traces are generated as *.srctrace files
```

**Pre-commit Workflow:**
```bash
# Install pre-commit dependencies - takes 60-120 seconds. NEVER CANCEL. Set timeout to 3+ minutes.
pip install -r requirements.txt

# Run pre-commit hooks - may fail due to network issues. NEVER CANCEL. Set timeout to 10+ minutes.
pre-commit run --all-files
```

## Validation

**CRITICAL Style Requirements:**
- The codebase has strict Ada style requirements
- `alr build --validation` will FAIL if style issues exist
- Current known style issues: Array initializers need space after `[` in lines 341, 345, 438, 442 of `src/ieee1788.adb`
- Always run `alr build` first to see style warnings, then fix before running `--validation`

**Always validate changes by:**
1. **Build validation:** `alr build` (must succeed, style warnings OK)
2. **Test validation:** `cd tests && alr build && alr run` (must pass all tests)
3. **Style validation:** `alr build --validation` (must succeed after fixing style issues)
4. **Formal verification:** `alr gnatprove --proof=progressive:all --level=4 -j0` (should complete without errors)

**Never run coverage testing unless specifically needed** - it's complex and primarily for CI.

**Expected Test Output:**
```xml
<?xml version='1.0' encoding='utf-8' ?>
<TestRun>
  <Statistics>
    <Tests>1</Tests>
    <FailuresTotal>0</FailuresTotal>
    <Failures>0</Failures>
    <Errors>0</Errors>
  </Statistics>
  <SuccessfulTests>
    <Test>
      <Name>Test IEEE 1788 To_Interval function</Name>
    </Test>
  </SuccessfulTests>
</TestRun>
```

## Common Tasks and File Locations

**Key Project Files:**
- `src/ieee1788.ads` - Main library interface  
- `src/ieee1788.adb` - Main library implementation
- `tests/src/ieee1788_tests.adb` - Test runner
- `tests/src/to_interval_test.adb` - Main test implementation
- `alire.toml` - Project metadata and dependencies
- `ieee1788.gpr` - Ada project file
- `.pre-commit-config.yaml` - Pre-commit hook configuration

**Repository Structure:**
```
/home/runner/work/ieee1788-ada/ieee1788-ada/
├── src/           # Library source code
├── tests/         # Test suite (separate Alire project)
├── .github/       # CI/CD workflows and GitHub config
├── hooks/         # Version checking scripts
├── alire.toml     # Main project configuration
└── ieee1788.gpr   # Ada project definition
```

**Timing Expectations:**
- Toolchain setup: 1-2 minutes total
- Regular builds: < 5 seconds
- Tests: < 10 seconds  
- Formal verification: < 5 seconds
- Style fixes: Manual editing required
- Pre-commit hooks: 3-10 minutes (may fail due to network)

**Network Issues:**
- Pre-commit may fail with timeout errors to PyPI
- GNATformat installation may take 10+ minutes due to compilation
- Alire package downloads are generally reliable

## Troubleshooting

**Build Failures:**
- Style errors: Edit `src/ieee1788.adb` to fix spacing in array initializers
- Missing tools: Run `alr install gnat_native gprbuild gnatcov`
- Path issues: Ensure `/home/runner/.alire/bin` is in PATH

**Test Failures:**
- Library build issues: Fix library build first with `alr build`
- Missing AUnit: Should be installed automatically by Alire

**Coverage Issues:**
- Complex workflow - follow exact steps above
- Runtime missing: Build and install gnatcov_rts_full as shown
- Path issues: Set GPR_PROJECT_PATH correctly

Always run the basic validation workflow (`alr build && cd tests && alr build && alr run`) before attempting advanced features.
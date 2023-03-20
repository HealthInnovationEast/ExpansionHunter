# Changes

## 1.0.0

Improvements around:

- Stability on poor quality inputs
- Default parameters for efficient execution
  - `--cpus` set at 16 for expansion hunter, capped at 4 for other multi-process steps
  - Can still be overridden via args
- `--analysis_mode` default set to `streaming` as more efficient than `seeking`
- Documentation updated

## 0.4.2

Fix up dangling issues #5, #6

## 0.4.1

Modifications specific to deployment via github actions.

## 0.4.0

- Configuration for CloudOS (CYNAPSE)
- Added `--augment` option to reduce size of output while retaining relevant information
  - Calculate Mean Absoulte Purity from read data and add to VCF output
  - Drops BAM/CRAM output file
- Compressed json output file
- Significant improvements to CI suite

## 0.3.0

- Ensures processes can detect stubRun to set sensible resources for testing
- Add function to prevent over provisioning resources
- Doc updates

## 0.2.0

- Adds command stubs to allow use of `-stub-run` when testing overall flow
  - Useful for workflows where actual exec is prohibative in CI-testing
  - Runs prior to actual exec of test data in CI
- Tag the introspection step to be run using local executor without docker

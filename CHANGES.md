# Changes

## 0.3.0

- Ensures processes can detect stubRun to set sensible resources for testing
- Add function to prevent over provisioning resources
- Doc updates

## 0.2.0

- Adds command stubs to allow use of `-stub-run` when testing overall flow
  - Useful for workflows where actual exec is prohibative in CI-testing
  - Runs prior to actual exec of test data in CI
- Tag the introspection step to be run using local executor without docker

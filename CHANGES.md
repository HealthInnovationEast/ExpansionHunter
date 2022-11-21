# Changes

## 0.2.0

- Adds command stubs to allow use of `-stub-run` when testing overall flow
  - Useful for workflows where actual exec is prohibative in CI-testing
  - Runs prior to actual exec of test data in CI
- Tag the introspection step to be run using local executor without docker

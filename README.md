# ExpansionHunter

Nextflow for [ExpansionHunter][eh-repo] talored for multi sample execution.

## Version of workflow vs ExpansionHunter

| Workflow | ExpansionHunter |
| :------: | :-------------: |
|   all    |     v5.0.0      |

## Docker image

The docker image used by this workflow is [wtsicgp/expansion_hunter][quay-eh], repository [here][casm-repo].

## Test data/profile

The test data referred to in `example/sample_info.csv` needs to be prepared by running `example/prepare_test_data.sh`.
The script should be executed in the folder you intend to run Nextflow.

```bash
cd ExpansionHunter
./example/prepare_test_data.sh
nextflow run main.nf -profile test
```

## Release process

- Ensure all pointers to the ExpansionHunter version are updated
  - search for the last version, with and without leading `v`.
- Add the workflow to ExpansionHunter version mapping to the table in the readme
- Ensure the CI pipeline has completed successfully

<!-- links -->

[casm-repo]: https://github.com/cancerit/ExpansionHunter-docker
[eh-repo]: https://github.com/Illumina/ExpansionHunter
[quay-eh]: https://quay.io/repository/wtsicgp/expansion_hunter?tab=tags

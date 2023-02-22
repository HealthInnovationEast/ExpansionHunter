# ExpansionHunter <!-- omit in toc -->

Nextflow for [ExpansionHunter][eh-repo] talored for multi sample execution.

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)

|                Main                |               Develop               |
| :--------------------------------: | :---------------------------------: |
| [![Main][gha-main]][gha-main-view] | [![Develop][gha-dev]][gha-dev-view] |

- [Version of workflow vs ExpansionHunter](#version-of-workflow-vs-expansionhunter)
- [Usage](#usage)
- [Docker image](#docker-image)
- [Local testing](#local-testing)
- [Release process](#release-process)

## Version of workflow vs ExpansionHunter

|             Workflow             | ExpansionHunter |
| :------------------------------: | :-------------: |
| 0.1.0, 0.1.1,<br>0.2.0,<br>0.3.0 |     v5.0.0      |

## Usage

Please see [usage][eh-nf-usage] page for details.

## Docker image

The docker image used by this workflow is [wtsicgp/expansion_hunter][quay-eh], repository [here][casm-repo].

## Local testing

The test data referred to in `example/sample_info.csv` needs to be prepared by running `example/prepare_test_data.sh`.
The script should be executed in the folder you intend to run Nextflow.  Below all the commands to make sure you can run
with the current image too.

The nextflow executions below are replicated in the github action, triggered on PR, develop/main merge and tags.

```bash
cd ExpansionHunter
./example/prepare_test_data.sh
# to ensure testing with latest image for augment
docker build -t expansionhunter:local .
# stub runs
nextflow -c nextflow.stubRun.config run main.nf -profile test -stub-run
nextflow -c nextflow.stubRun.config -c local.config run main.nf -profile test -stub-run --augment --repeats $PWD/test_data/repeats.txt --multistr $PWD/test_data/multi_str.txt
# real runs
nextflow run -c main.nf -profile test
nextflow run -c local.config main.nf -profile test --augment --repeats $PWD/test_data/repeats.txt --multistr $PWD/test_data/multi_str.txt
```

## Release process

- Ensure all pointers to the ExpansionHunter version are updated
  - search for the last version, with and without leading `v`.
- Add the workflow to ExpansionHunter version mapping to the table in the readme
- Ensure the CI pipeline has completed successfully

<!-- links -->

[casm-repo]: https://github.com/cancerit/ExpansionHunter-docker
[eh-nf-usage]: docs/usage.md
[eh-repo]: https://github.com/Illumina/ExpansionHunter
[gha-dev]: https://github.com/cynapse-ccri/ExpansionHunter/actions/workflows/build.yaml/badge.svg?branch=develop
[gha-dev-view]: https://github.com/cynapse-ccri/ExpansionHunter/actions?query=branch%3Adevelop
[gha-main]: https://github.com/cynapse-ccri/ExpansionHunter/actions/workflows/build.yaml/badge.svg?branch=main
[gha-main-view]: https://github.com/cynapse-ccri/ExpansionHunter/actions?query=branch%3Amain
[quay-eh]: https://quay.io/repository/wtsicgp/expansion_hunter?tab=tags

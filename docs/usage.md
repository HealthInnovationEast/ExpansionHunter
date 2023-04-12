# Usage <!-- omit in toc -->

For descriptions of all arguments not detailed here please see the tool documentation [here][eh-usage].

All links here are pinned to the version of ExpansionHunter that this nextflow has been created for.

- [Required args](#required-args)
  - [`--sample_info`](#--sample_info)
  - [`--reference`](#--reference)
  - [`--variant_catalog`](#--variant_catalog)
- [Optional args](#optional-args)
  - [`--cpus`](#--cpus)
  - [`--region_extension_length`](#--region_extension_length)
  - [`--analysis_mode`](#--analysis_mode)
  - [`--aligner`](#--aligner)
  - [`--augment`](#--augment)
- [Resource options](#resource-options)
  - [`--memory`](#--memory)
  - [`--time`](#--time)
- [CYNAPSE](#cynapse)
  - [Profiles](#profiles)
  - [Parameters](#parameters)
  - [Host configuration](#host-configuration)
  - [Cost limit](#cost-limit)

## Required args

### `--sample_info`

Comma separated value (csv) file with compulsory header:

```
sampleId,sex,reads,read_idx
```

Each subsequent line describes an individual sample.

| `sampleId`            | `sex`       | `reads`                          | `read_idx`         |
| --------------------- | ----------- | -------------------------------- | ------------------ |
| Identifier for sample | male/female | BAM or CRAM file to be processed | Index for bam/cram |

- `sampleId` is incoprporated into `--output-prefix` in the core command.
- `sex` is passed to `--sex`, if empty it is set to the default of `female`.
- `reads` is passed to `--reads`.
- `read_idx` is required to ensure the index is staged appropriately.

### `--reference`

See core [usage][eh-usage].

### `--variant_catalog`

Passed to `--variant-cataloge`. See core [usage][eh-usage].

## Optional args

### `--cpus`

Passed through to ExpansionHunter `--threads` and sort/cram compression.  Only the expansion hunter step will use all
specified threads (max 16, default 16).  Other multi core processes are capped at 4 cpus.

Nextflow naming convention.

### `--region_extension_length`

Passed to `--region-extension-length`. See core [usage][eh-usage].

### `--analysis_mode`

Default to `streaming` as significantly faster than seeking.

Passed to `--analysis-mode`. See core [usage][eh-usage].

### `--aligner`

See core [usage][eh-usage].

### `--augment`

Process XG tags of primary BAM Expansion Hunter output to Mean Absolute Purity (MAP) and include in the VCF file.

This will result in no BAM/CRAM in the final output (just VCF, index and json).

## Resource options

### `--memory`

Change the default per-cpu memory value, default 3.5.GB

Memory is automatically scaled by CPUs and is unlikely to need any intervention, e.g.

- 1 cpu = 3.5.GB RAM
- 2 cpu = 7.GB RAM

Total memory is capped at 192.GB

### `--time`

Change the default time for the main processes, default `4h`.

See [nextflow time][nxf-time] docs for format.  This is only relevant to a subset of schedulers.

## CYNAPSE

This section details additional information to run analysis in CYNAPSE.

### Profiles

Some profiles are available (see `conf/*.config`), however the base configuration is targeted at CloudOS and pre-set to
use the `awsbatch` executor.

### Parameters

Specify the parameters required to perform an analysis, the expected items are:

- `--sample_info`
  - Make sure to split this into sensible sample groups
- `--reference`
- `--variant_catalog`
- `--augment` - optional, but expected for primary use case

### Host configuration

Once the workflow settings and parameters are defined you will need to specify the configuration for the execution node.

This can be very light-weight as it only monitors the job when under awsbatch.  Recommend:

- On-demand
- `t3a.medium` (2 CPUS / 4 GiB)
- 40 GB disk

### Cost limit

Each sample will cost ~$0.50 to run, you should scale the cost limit based on the number of samples defined in `--sample_info`.

Test runs using 20 GB input CRAM have a cost range of $0.20-0.26.

<!-- refs -->

[eh-usage]: https://github.com/Illumina/ExpansionHunter/blob/v5.0.0/docs/03_Usage.md
[nxf-time]: https://www.nextflow.io/docs/latest/process.html#process-time

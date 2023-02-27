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
  - [`--disk`](#--disk)

## Required args

### `--sample_info`

Comma seperated value file with header:

```
sampleId,sex,alignments
```

Each subsequent line describes an individual sample.

| sampleId              | sex         | reads                            | read_idx           |
| --------------------- | ----------- | -------------------------------- | ------------------ |
| Identifier for sample | male/female | BAM or CRAM file to be processed | Index for bam/cram |

- `sampleId` is incoprporated into `--output-prefix` in the core command.
- `sex` is passed to `--sex`, if empty it is set to the default of `female`.
- `reads` is passed to `--reads`.

### `--reference`

See core [usage][eh-usage].

### `--variant_catalog`

Passed to `--variant-cataloge`. See core [usage][eh-usage].

## Optional args

### `--cpus`

Passed through to ExpansionHunter `--threads` and sort/cram compression.  Nextflow naming convention.

### `--region_extension_length`

Passed to `--region-extension-length`. See core [usage][eh-usage].

### `--analysis_mode`

Passed to `--analysis-mode`. See core [usage][eh-usage].

### `--aligner`

See core [usage][eh-usage].

### `--augment`

Process XG tags of primary BAM Expansion Hunter output to Mean Absolute Purity (MAP) and include in the VCF file.

This will result in no BAM/CRAM in the final output (just VCF, index and json).

## Resource options

### `--memory`

Change the default per-cpu memory value: 3.2GB

### `--disk`

Set required disk space for job: 10GB

This should be ~ `input data x 1.5`.

<!-- refs -->

[eh-usage]: https://github.com/Illumina/ExpansionHunter/blob/v5.0.0/docs/03_Usage.md

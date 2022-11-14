# Usage

For descriptions of all arguments not detailed here please see the tool documentation [here][eh-usage].

All links here are pinned to the version of ExpansionHunter that this nextflow has been created for.

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

<!-- refs -->

[eh-usage]: https://github.com/Illumina/ExpansionHunter/blob/v5.0.0/docs/03_Usage.md

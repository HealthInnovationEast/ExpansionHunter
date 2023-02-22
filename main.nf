#!/usr/bin/env nextflow
nextflow.enable.dsl=2

def helpMessage() {
    // TODO
    log.info """
    Please see here for usage information: https://github.com/cynapse-ccri/ExpansionHunter/blob/master/docs/usage.md
    """.stripIndent()
}

// Show help message
if (params.help) {
  helpMessage()
  exit 0
}

// Header log info

def summary = [:]

if (workflow.revision) summary['Pipeline Release'] = workflow.revision

summary['Output dir']                                  = params.outdir
summary['Launch dir']                                  = workflow.launchDir
summary['Working dir']                                 = workflow.workDir
summary['Script dir']                                  = workflow.projectDir
summary['User']                                        = workflow.userName
// resources
summary['memory'] = params.memory
summary['cpus'] = params.cpus
summary['disk'] = params.disk
// then arguments
summary['sample_info']                                 = params.sample_info
summary['reference']                                   = params.reference
summary['variant_catalog']                             = params.variant_catalog
summary['region_extension_length']                     = params.region_extension_length
summary['aligner']                                     = params.aligner
summary['analysis_mode']                               = params.analysis_mode

log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
log.info "-\033[2m--------------------------------------------------\033[0m-"

// Importantly, in order to successfully introspect:
// - This needs to be done first `main.nf`, before any (non-head) nodes are launched.
// - All variables to be put into channels in order for them to be available later in `main.nf`.

ch_repository         = Channel.of(workflow.manifest.homePage)
ch_commitId           = Channel.of(workflow.commitId ?: "Not available is this execution mode. Please run 'nextflow run ${workflow.manifest.homePage} [...]' instead of 'nextflow run main.nf [...]'")
ch_revision           = Channel.of(workflow.manifest.version)

ch_scriptName         = Channel.of(workflow.scriptName)
ch_scriptFile         = Channel.of(workflow.scriptFile)
ch_projectDir         = Channel.of(workflow.projectDir)
ch_launchDir          = Channel.of(workflow.launchDir)
ch_workDir            = Channel.of(workflow.workDir)
ch_userName           = Channel.of(workflow.userName)
ch_commandLine        = Channel.of(workflow.commandLine)
ch_configFiles        = Channel.of(workflow.configFiles)
ch_profile            = Channel.of(workflow.profile)
ch_container          = Channel.of(workflow.container)
ch_containerEngine    = Channel.of(workflow.containerEngine)

/*----------------------------------------------------------------
  Setting up additional variables used for documentation purposes
-------------------------------------------------------------------*/

Channel
    .of(params.raci_owner)
    .set { ch_raci_owner }

Channel
    .of(params.domain_keywords)
    .set { ch_domain_keywords }

/*----------------------
  Setting up input data
-------------------------*/

// Define Channels from input
// only if not in dsl2

/*-----------
  Processes
--------------*/

// Do not delete this process
// Create introspection report

process obtain_pipeline_metadata {
    publishDir "${params.tracedir}", mode: "copy"

    input:
      val(repository)
      val(commit)
      val(revision)
      val(script_name)
      val(script_file)
      val(project_dir)
      val(launch_dir)
      val(work_dir)
      val(user_name)
      val(command_line)
      val(config_files)
      val(profile)
      val(container)
      val(container_engine)
      val(raci_owner)
      val(domain_keywords)

    output:
      path("pipeline_metadata_report.tsv"), emit: pipeline_metadata_report

    // same as script except ! instead of $ for variables
    shell:
      '''
      echo "Repository\t!{repository}"                  > temp_report.tsv
      echo "Commit\t!{commit}"                         >> temp_report.tsv
      echo "Revision\t!{revision}"                     >> temp_report.tsv
      echo "Script name\t!{script_name}"               >> temp_report.tsv
      echo "Script file\t!{script_file}"               >> temp_report.tsv
      echo "Project directory\t!{project_dir}"         >> temp_report.tsv
      echo "Launch directory\t!{launch_dir}"           >> temp_report.tsv
      echo "Work directory\t!{work_dir}"               >> temp_report.tsv
      echo "User name\t!{user_name}"                   >> temp_report.tsv
      echo "Command line\t!{command_line}"             >> temp_report.tsv
      echo "Configuration file(s)\t!{config_files}"    >> temp_report.tsv
      echo "Profile\t!{profile}"                       >> temp_report.tsv
      echo "Container\t!{container}"                   >> temp_report.tsv
      echo "Container engine\t!{container_engine}"     >> temp_report.tsv
      echo "RACI owner\t!{raci_owner}"                 >> temp_report.tsv
      echo "Domain keywords\t!{domain_keywords}"       >> temp_report.tsv
      awk 'BEGIN{print "Metadata_variable\tValue"}{print}' OFS="\t" temp_report.tsv > pipeline_metadata_report.tsv
      '''

    stub:
      '''
      touch pipeline_metadata_report.tsv
      '''
}

process expansion_hunter {
  input:
    tuple val(sampleId), val(sex), path(reads), path(read_idx)
    //tuple val(sampleId), val(sex), val(reads), val(read_idx)
    path(reference) //path
    path(variant_catalog) //path
    val(aligner)
    val(region_extension_length)
    val(analysis_mode)

  output:
    tuple val(sampleId), path('*.vcf'), path('*_realigned.bam'), emit: eh_data
    path '*.json.gz'

  publishDir {
      "results/${sampleId}"
  }, mode: 'copy', pattern: '*.json.gz'

  // not stricly needed here, but incase used as template later
  // makes sure pipelines fail properly, plus errors and undef values
  shell = ['/bin/bash', '-euo', 'pipefail']

  script:
    sex = sex == '' ? 'female' : sex
    """
    ExpansionHunter \
      --reference ${reference} \
      --variant-catalog ${variant_catalog} \
      --reads ${reads} \
      --sex '${sex}' \
      --output-prefix '${sampleId}' \
      --aligner '${aligner}' \
      --region-extension-length ${region_extension_length} \
      --analysis-mode '${analysis_mode}' \
      --threads ${task.cpus}
    gzip -c ${sampleId}.json > ${sampleId}.json.gz
    """

  stub:
    """
    touch ${sampleId}.vcf
    touch ${sampleId}_realigned.bam
    echo '' | gzip -c > ${sampleId}.json.gz
    """
}

process sort_n_index {
  input:
    tuple val(sampleId), path(vcf), path(bam)
    path(reference)

  output:
    tuple path('*.vcf.gz'), path('*.vcf.gz.tbi'), emit: eh_vcf
    tuple path('*.cram'), path('*.cram.crai'), emit: eh_cram

   publishDir {
      "results/${sampleId}"
  }, mode: 'copy', pattern: '*.{vcf.gz,vcf.gz.tbi,cram,crai}'

  // not stricly needed here, but incase used as template later
  // makes sure pipelines fail properly, plus errors and undef values
  shell = ['/bin/bash', '-euo', 'pipefail']

  script:
    """
    (grep -m 1 -B 100000 '^#CHR' ${vcf} && (grep -v '^#' ${vcf} | sort -k1,1 -k2,2n)) | bgzip -c > ${vcf}.gz
    tabix -p vcf ${vcf}.gz
    samtools sort -@ ${task.cpus} --write-index --output-fmt CRAM -o ${sampleId}_realigned.cram --reference ${reference} ${bam}
    """

  stub:
    """
    echo '' | gzip -c > ${vcf}.gz
    touch ${vcf}.gz.tbi
    touch ${sampleId}_realigned.cram
    touch ${sampleId}_realigned.cram.crai
    """
}

process augment {
  input:
    tuple val(sampleId), path(vcf), path(bam)
    tuple path(repeats), path(multistr)

  output:
    tuple path('*.vcf.gz'), path('*.vcf.gz.tbi'), emit: eh_vcf

   publishDir {
      "results/${sampleId}"
  }, mode: 'copy', pattern: '*.MAP.vcf.{gz,gz.tbi}'

  // not stricly needed here, but incase used as template later
  // makes sure pipelines fail properly, plus errors and undef values
  shell = ['/bin/bash', '-euo', 'pipefail']

  script:
    def raw_vcf = vcf.toString().minus('.vcf')
    """
    (grep -m 1 -B 100000 '^#CHR' ${vcf} && (grep -v '^#' ${vcf} | sort -k1,1 -k2,2n)) | bgzip -c > sorted.vcf.gz
    tabix -p vcf sorted.vcf.gz
    mkdir -p tmp
    touch tmp/annot.hdr
    mapV3.r ${repeats} ${bam} sorted.vcf ${multistr} tmp/ ./ ${raw_vcf}
    """

  stub:
    def raw_vcf = vcf.toString().minus('.vcf')
    """
    touch ${raw_vcf}.MAP.vcf.gz
    touch ${raw_vcf}.MAP.vcf.gz.tbi
    """
}


workflow {
    samples = Channel.fromPath(params.sample_info)
    sample_map = samples.splitCsv(header: true).map { row -> tuple(row.sampleId, row.sex, file(row.reads), file(row.read_idx)) }
    //sample_map = samples.splitCsv(header: true).map { row -> tuple(row.sampleId, row.sex, row.reads, row.read_idx) }


    main:
      obtain_pipeline_metadata(
        ch_repository,
        ch_commitId,
        ch_revision,
        ch_scriptName,
        ch_scriptFile,
        ch_projectDir,
        ch_launchDir,
        ch_workDir,
        ch_userName,
        ch_commandLine,
        ch_configFiles,
        ch_profile,
        ch_container,
        ch_containerEngine,
        ch_raci_owner,
        ch_domain_keywords
      )
      expansion_hunter(
        sample_map,
        params.reference,
        params.variant_catalog,
        params.aligner,
        params.region_extension_length,
        params.analysis_mode
      )
      if ( params.augment ) {
        augment(expansion_hunter.out.eh_data, tuple(params.repeats, params.multistr))
      }
      else {
        sort_n_index(expansion_hunter.out.eh_data, params.reference)
      }

}

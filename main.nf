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
summary['variant_catalogue']                           = params.variant_catalogue
summary['min_locus_coverage']                          = params.min_locus_coverage
summary['region_extension_length']                     = params.region_extension_length
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
    val repository from ch_repository
    val commit from ch_commitId
    val revision from ch_revision
    val script_name from ch_scriptName
    val script_file from ch_scriptFile
    val project_dir from ch_projectDir
    val launch_dir from ch_launchDir
    val work_dir from ch_workDir
    val user_name from ch_userName
    val command_line from ch_commandLine
    val config_files from ch_configFiles
    val profile from ch_profile
    val container from ch_container
    val container_engine from ch_containerEngine
    val raci_owner from ch_raci_owner
    val domain_keywords from ch_domain_keywords

    output:
    file("pipeline_metadata_report.tsv") into ch_pipeline_metadata_report

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
}

process expansion_hunter {
  input:
    //tuple val(sampleId), val(sex), path(alignment)
    tuple val(sampleId), val(sex), val(alignment)

  output:
    path '*.txt', emit: result

  script:
    sex = sex == '' ? 'female' : sex
    """
    echo ${sampleId}, ${sex}, ${alignment} > ${sampleId}.txt
    """
}


workflow {
    samples = Channel.fromPath(params.sample_info)
    //sample_map = pairs.splitCsv(header: true).map { row -> tuple(row.sampleId, row.sec, file(row.alignments)) }
    sample_map = samples.splitCsv(header: true).map { row -> tuple(row.sampleId, row.sex, row.alignments) }


    main:
        expansion_hunter(sample_map)
}
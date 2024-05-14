nextflow.enable.dsl = 2

params.sample_name = 'NB-8204-M-muscle'
params.outdir = "results"
params.reads = "${params.sample_name}*.fastq.gz"

log.info """\
    D N A - S E Q _ W F   P I P E L I N E
    ===================================
    sample_name         : ${params.sample_name}
    outdir              : ${params.outdir}
    """
    .stripIndent(true)

include { FASTP } from './modules/fastp/main.nf'

workflow {
    Channel
        .fromFilePairs(params.reads, checkIfExists: true)
        .set { read_pairs_ch }

    fastp_ch = FASTQC(read_pairs_ch)
}

workflow.onComplete {
    log.info ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}
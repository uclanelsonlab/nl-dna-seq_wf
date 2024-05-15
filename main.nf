nextflow.enable.dsl = 2

params.samples = "samples.csv"
params.fasta = "/var/snap/amazon-ssm-agent/7983/download/ucsc/hg38.fa"
params.index = "/var/snap/amazon-ssm-agent/7983/download/ucsc/"
params.outdir = "results"

log.info """\
    D N A - S E Q _ W F   P I P E L I N E
    ===================================
    samples             : ${params.samples}
    fasta               : ${params.fasta}
    outdir              : ${params.outdir}
    """
    .stripIndent(true)

include { FASTP } from './modules/fastp/main.nf'
include { BWA_MEM } from './modules/bwamem/main.nf'

workflow {
    Channel
        .fromPath(params.samples)
        .splitCsv(header: true, sep: ',')
        .map { row ->
            def meta = [
                id: row.sampleid,
                single_end: false
            ]
            tuple(meta, [file(row.read1), file(row.read2)])
        }
        .set { read_pairs_ch }
    index_ch = Channel.fromPath("${params.index}*.{amb,ann,bwt,pac,sa}")
        .map { it -> [it.baseName, it] }
        .groupTuple()
    fasta_ch = Channel.fromFilePairs(params.fasta)

    FASTP_RESULTS = FASTP(read_pairs_ch, false, false)
    BWA_MEM_RESULTS = BWA_MEM(FASTP_RESULTS.reads, index_ch, fasta_ch, true)
}

workflow.onComplete {
    log.info ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}
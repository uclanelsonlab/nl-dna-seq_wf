nextflow.enable.dsl = 2

params.samples = "samples.csv"
params.outdir = "results"

log.info """\
    D N A - S E Q _ W F   P I P E L I N E
    ===================================
    samples             : ${params.samples}
    outdir              : ${params.outdir}
    """
    .stripIndent(true)

include { FASTP } from './modules/fastp/main.nf'

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

    FASTP_RESULTS = FASTP(read_pairs_ch, false, false)
    FASTP_RESULTS.reads.view()
}

workflow.onComplete {
    log.info ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}
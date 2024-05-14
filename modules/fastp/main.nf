process FASTP {
    tag "$meta"
    label 'process_medium'
    cpus 32

    conda "${moduleDir}/environment.yml"

    input:
    tuple val(meta), path(reads1), path(reads2)

    output:
    tuple val(meta), path('*.fastp.fastq.gz') , optional:true, emit: reads
    tuple val(meta), path('*.json')           , emit: json
    tuple val(meta), path('*.html')           , emit: html
    tuple val(meta), path('*.log')            , emit: log

    script:
    """
    fastp \
        -w $task.cpus \
        -i ${reads1} \
        -I ${reads2} \
        -o ${meta}_R1.fastp.fastq.gz \
        -O ${meta}_R2.fastp.fastq.gz \
        -j ${meta}.fastp.json \
        -h ${meta}.fastp.html \
        --detect_adapter_for_pe 2> >(tee ${meta}.fastp.log >&2)
    """
}
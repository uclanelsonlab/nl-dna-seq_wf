process FASTP {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastp:0.23.4--h5f740d0_0' :
        'biocontainers/fastp:0.23.4--h5f740d0_0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path('*.fastp.fastq.gz') , optional:true, emit: reads
    tuple val(meta), path('*.json')           , emit: json
    tuple val(meta), path('*.html')           , emit: html
    tuple val(meta), path('*.log')            , emit: log

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    fastp \
        -w $task.cpus \
        -i ${reads[0]} \
        -I ${reads[1]} \
        -o ${prefix}_R1.fastp.fastq.gz \
        -O ${prefix}_R2.fastp.fastq.gz \
        -j ${prefix}.fastp.json \
        -h ${prefix}.fastp.html \
        --detect_adapter_for_pe 2> >(tee ${prefix}.fastp.log >&2)
    """
}
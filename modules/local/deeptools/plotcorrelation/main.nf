process DEEPTOOLS_PLOTCORRELATION {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? 'bioconda::deeptools=3.5.1' : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/deeptools:3.5.1--py_0' :
        'quay.io/biocontainers/deeptools:3.5.1--py_0' }"

    input:
    tuple val(meta), path(matrix)

    output:
    tuple val(meta), path("*.pdf"), emit: pdf
    tuple val(meta), path("*.tab"), emit: matrix
    path  "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    plotCorrelation \\
        $args \\
        --corData $matrix \\
        --plotFile ${prefix}.plotHeatmap.pdf \\
        --outFileCorMatrix ${prefix}.plotCorrelation.mat.tab

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        deeptools: \$(plotCorrelation --version | sed -e "s/plotCorrelation //g")
    END_VERSIONS
    """
}

process BASES2FASTQ {
    // tag "$meta.id"
    label 'process_high'

    if (params.enable_conda) {
        exit 1, "Conda environments cannot be used when using bases2fastq. Please use docker or singularity containers."
    }
    container "elembio/bases2fastq:1.0.0"

    input:
    tuple val(meta), path(run_manifest), path(run_dir)

    output:
    tuple val(meta), path('Samples/*/*_R*.fastq.gz'), emit: sample_fastq
    tuple val(meta), path('Samples/*/*.json')       , emit: sample_json
    tuple val(meta), path('RunStats.json')          , emit: run_stats
    tuple val(meta), path('RunManifest.json')       , emit: generated_run_manifest
    tuple val(meta), path('Metrics.csv')            , emit: metrics
    tuple val(meta), path('UnassignedSequences.csv'), emit: unassigned
    path "versions.yml"                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def runManifest = run_manifest ? "-r ${run_manifest}" : ""
    """
    bases2fastq \\
        -p $task.cpus \\
        $runManifest \\
        $args \\
        $run_dir \\
        .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bases2fastq: \$(bases2fastq --version | sed -e "s/bases2fastq version //g")
    END_VERSIONS
    """
}

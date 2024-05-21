#!/bin/env nextflow

nextflow.enable.dsl=2

include{
    SUBSAMPLE
} from "./module/processes.nf"

params.gisaid_fasta
params.gisaid_metadata
params.outDir = "$projectDir/results"

channel.fromPath("${params.gisaid_fasta}").set{gisaid_fasta_ch}
channel.fromPath("${params.gisaid_metadata}").set{gisaid_metadata_ch}

workflow {
SUBSAMPLE(
    gisaid_fasta_ch,
    gisaid_metadata_ch
)
}
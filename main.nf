#!/bin/env nextflow

nextflow.enable.dsl=2

include{
    SUBSAMPLE;
    ALIGN;
    IQTREE
} from "./module/processes.nf"

channel.fromPath("${params.gisaid_fasta}").set{gisaid_fasta_ch}
channel.fromPath("${params.gisaid_metadata}").set{gisaid_metadata_ch}
channel.fromPath("${params.align_ref}/DENV1_ref.fasta").set{align_ref_ch}

workflow {
SUBSAMPLE(
    gisaid_fasta_ch,
    gisaid_metadata_ch
)
ALIGN(
    SUBSAMPLE.out.subsampled, //subsampled from gisaid_fasta
    align_ref_ch
)
IQTREE(
    ALIGN.out
)
}
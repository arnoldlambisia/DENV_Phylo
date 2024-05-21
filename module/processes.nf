#!/bin/env nextflow

nextflow.enable.dsl=2



process SUBSAMPLE {

    publishDir "${params.outDir}", mode: "copy"

    input:
    path gisaid_fasta //This is the downloaded gisaid fasta file
    path gisaid_metadata //This is a meta file in tsv
    
    output:
    path "accession_subset.tsv"
    path "dna_fasta.fasta"
    path "dna_subsampled.fa"

    script:
    """
    data_cleanup_subset.R -f $gisaid_fasta -t $gisaid_metadata -o "accession_subset.tsv"
    seqtk subseq dna_fasta.fasta accession_subset.tsv > dna_subsampled.fa
    """
}
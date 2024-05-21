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
    path "dna_subsampled.fa", emit: subsampled

    script:
    """
    data_cleanup_subset.R -f $gisaid_fasta -t $gisaid_metadata -o "accession_subset.tsv"
    seqtk subseq dna_fasta.fasta accession_subset.tsv > dna_subsampled.fa
    """
}

process ALIGN {

    publishDir "${params.outDir}", mode: "copy"

    input:
    path subsampled_fasta //expects input from subsample
    path denv_ref //denv1 reference genome

    output:
    path "denv1_aln.fasta"

    shell:
    """
    nextalign run -r $denv_ref --include-reference -o denv1_aln.fasta $subsampled_fasta
    """
}
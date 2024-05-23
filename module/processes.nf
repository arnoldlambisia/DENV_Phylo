#!/bin/env nextflow

nextflow.enable.dsl=2

process SUBSAMPLE {

    publishDir "${params.outDir}", mode: "copy"

    input:
    path gisaid_fasta //This is the downloaded gisaid fasta file
    path gisaid_metadata //This is a meta file in tsv
    
    output:
    path "accession_subset.tsv"
    path "treetime_meta.tsv", emit: treetime_data
    path "dna_fasta.fasta"
    path "dna_subsampled.fa", emit: subsampled

    script:
    """
    data_cleanup_subset.R -f $gisaid_fasta -t $gisaid_metadata -o "accession_subset.tsv" -m "treetime_meta.tsv"
    seqtk subseq dna_fasta.fasta accession_subset.tsv > dna_subsampled.fa
    """
}

process ALIGN {

    publishDir "${params.outDir}", mode: "copy"

    input:
    path subsampled_fasta //expects input from subsample
    path denv_ref //denv1 reference genome

    output:
    path "denv1_aln.fasta" //no need to emit because it's a single output

    shell:
    """
    nextalign run -r $denv_ref --include-reference -o denv1_aln.fasta $subsampled_fasta
    """
}

process IQTREE {
    
    publishDir "${params.outDir}", mode: "copy"

    input:
    path aligned_fasta //aligned file from ALIGN process

    output:
    path "*.treefile" //no need to emit because it's a single output

    shell:
    """
    iqtree2 -s $aligned_fasta -m TEST -bb 1000 -T 4
    """
}

process TREETIME {

    publishDir "${params.outDir}/treetime", mode: "copy"

    input: 
    path aligned_fasta
    path treefile
    path treetime_data

    output:
    path "*"

    shell:
    """
    treetime --aln $aligned_fasta --tree $treefile --dates $treetime_data
    """
}
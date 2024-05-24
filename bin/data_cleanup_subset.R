#!/usr/bin/env Rscript

set.seed(1234)

# Check whether pacman is available, if not install
#if (!require("pacman")) install.packages("pacman")

#load the required packages
library(devtools)
library(tidyverse)
library(rio)
library(optparse)
library(lubridate)

option_list <- list(
  # Input file
  make_option(
    c("-t", "--tsv_file"),
    type="character",
    default=NULL,
    help="A tsv file with three columns",
    metavar="TSV_FILE"),

 make_option(
    c("-f", "--fasta"),
    type="character",
    default=NULL,
    help="A fasta file from gisaid",
    metavar="fasta"),
 
  #Output file
  make_option(
    c("-o", "--output_file"),
    type="character",
    default="sample.tsv",
    help="output file name [default= %default]",
    metavar="TSV_FILE"),
 
 make_option(
   c("-m", "--treetimemeta_file"),
   type="character",
   default="sample.tsv",
   help="output file name [default= %default]",
   metavar="TSV_FILE")
)

# Create an opt object
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

#source for script
source_url("https://raw.githubusercontent.com/lrjoshi/FastaTabular/master/fasta_and_tabular.R")

#covert fasta to csv
FastaToTabular(opt$fasta)
arbo_data <- import(opt$tsv_file)


#import csv file
arbo_fasta <- import("dna_table.csv", header = T)

#manipulate fasta header to get strain id 
arbo_fasta2 <- arbo_fasta %>% 
  separate(name, into = c("strain", "accession", "year"), sep = "\\|") %>% 
  dplyr::select(accession, sequence)

#write 2 csv
write.csv(arbo_fasta2, "dna_table.csv", row.names = FALSE)

#convert csv to fasta
TabularToFasta("dna_table.csv")

#######import metadata

#names(arbo_data)
#manipulate data for subsampling
arbo_data2 <- arbo_data %>% 
  rename("seq_length" = `Sequence Length`,
         "strain" = `Virus name`,
         "AA_mutation" = `AA Substitutions`,
         "date_collect" = `Collection date`,
         "accession" = `Accession ID`) %>% 
  dplyr::mutate(date_collect = as.Date(date_collect, tryFormats = c("%d/%m/%Y")), #check date format
                yearcollection=as.Date(cut(date_collect, breaks="year"))) %>% 
  separate(Location, into=c("continent", "country", "region", "subregion1", "subregion2", "subregion3"),
           sep="\\/", remove=FALSE, extra="warn", fill="right")
  

#check data structure
#str(arbo_data2)

#subsample data
arbo_data3 <-arbo_data2%>%
  dplyr::filter(seq_length >= 10000 & !is.na(Genotype) & !is.na(date_collect) & Host == "Human") %>% 
  group_by(country, yearcollection, Genotype)%>%
  sample_n(30, replace =T)%>%
  distinct(strain,.keep_all=TRUE)%>%
  ungroup()%>%
  dplyr::select(accession, date_collect, Genotype, country) %>% 
  dplyr::mutate(seq_id = paste(accession, country, Genotype, date_collect, sep = "|"))

 #subset accession number
 subsampling_arbodata <- arbo_data3 %>% 
  dplyr::select(accession)

#subset data for treetime
treetime_metadata <- arbo_data3 %>% 
  dplyr::mutate(dates = decimal_date(date_collect)) %>% 
  dplyr::select(accession, dates, country, Genotype)

#write table with 
write_tsv(subsampling_arbodata, opt$output_file)
write_tsv(treetime_metadata, opt$treetimemeta_file)
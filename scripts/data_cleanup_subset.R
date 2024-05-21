###load libraries
library (devtools)
library (tidyverse)
library(rio)

#set working directory
setwd("~/Downloads")

#source for script
source_url("https://raw.githubusercontent.com/lrjoshi/FastaTabular/master/fasta_and_tabular.R")

#covert fasta to csv
FastaToTabular("gisaid_arbo_2024_05_20_10.fasta")

#import csv file
arbo_fasta <- import("~/Downloads/dna_table.csv", header = T)

#manipulate fasta header to get strain id 
arbo_fasta2 <- arbo_fasta %>% 
  separate(name, into = c("strain", "accession", "year"), sep = "\\|") %>% 
  dplyr::select(accession, sequence)

#write 2 csv
write.csv(arbo_fasta2, "~/Downloads/dna_table.csv", row.names = FALSE)

#convert
TabularToFasta("dna_table.csv")

#######import metadata
arbo_data <- import("~/Downloads/gisaid_arbo_2024_05_20_10.tsv")

names(arbo_data)
#manipulate data 
arbo_data2 <- arbo_data %>% 
  rename("seq_length" = `Sequence Length`,
         "strain" = `Virus name`,
         "AA_mutation" = `AA Substitutions`,
         "date_collect" = `Collection date`,
         "accession" = `Accession ID`) %>% 
  dplyr::mutate(date_collect = as.Date(date_collect),
                yearcollection=as.Date(cut(date_collect, breaks="year"))) %>% 
  separate(Location, into=c("continent", "country", "region", "subregion1", "subregion2", "subregion3"),
           sep="\\/", remove=FALSE, extra="warn", fill="right")
  

#check data structure
str(arbo_data2)

#subsample data
subsampling_arbodata <-arbo_data2%>%
  dplyr::filter(seq_length >= 10000 & !is.na(Genotype) & !is.na(date_collect) & Host == "Human") %>% 
  group_by(country, yearcollection, Genotype)%>%
  sample_n(30, replace =T)%>%
  distinct(strain,.keep_all=TRUE)%>%
  ungroup()%>%
  dplyr::select(accession, date_collect, Genotype, country) %>% 
  dplyr::mutate(seq_id = paste(accession, country, Genotype, date_collect, sep = "|")) %>% 
  dplyr::select(accession)

#write table with 
write_tsv(subsampling_arbodata, "~/Downloads/subsampled_arbodata.tsv")
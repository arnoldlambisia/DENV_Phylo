######################### Tabular format to Fasta format###############################

#this is a script to visualize the dengue time-reolved tree generated from timetree
#Two inputs are required: nexus file and metadata


option_list <- list(
  # Input file
  make_option(
    c("-t", "--tsv_file"),
    type="character",
    default=NULL,
    help="A tsv file with three columns",
    metavar="TSV_FILE"),
  
  make_option(
    c("-n", "--nexus_file"),
    type="character",
    default=NULL,
    help="nexus file from treetime",
    metavar="fasta"),
  
  #Output file
  
  make_option(
    c("-p", "--annotated_file"),
    type="character",
    default="annotated_treetime.pdf",
    help="output file name [default= %default]",
    metavar="PDF_FILE")
)

# Create an opt object
opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

####################
denv_tree<-read.nexus(opt$nexus_file)
denv_metadata <- import(opt$tsv_file)


mr <- max(denv_metadata$dates)
mr <- date_decimal(mr)

p_denv<-ggtree(denv_tree, mrsd=mr, as.Date=TRUE,size=0.3, ladderize=TRUE) + theme_tree2()+
  scale_x_date(date_labels = "%Y",date_breaks = "3 year")+
  theme_tree2(legend.position='left')+
  theme(axis.text.x = element_text(size=20,angle=90))

plot(p_denv)


color_global=c("#0000FF","#CCCCFF","#55ACEE","#000000","#C0C0C0","#CD853F", "#800080", 
               "#FF0000","#F2D2BD","#800000","#808000","#00FF00","#008000","#FA8072","#00FFFF","#FFA500", 
               "#55ACEE","#000000","#C0C0C0","#0F4D92","#CD853F", "#000080",
               "#808000", "#FFFF00","magenta", "#e41a1c","#377eb8","#4daf4a","#984ea3","#ff7f00","#ffff33")


plot_denv <- p_denv %<+% denv_metadata + 
  geom_tippoint(aes(color = country, shape = Genotype), size=3, stroke=0.2,align=T)+
  scale_fill_manual(values = c(color_global))


plot_denv


ggsave(plot_denv, width = 16, height = 12, dpi = 600, filename = opt$annotated_file)

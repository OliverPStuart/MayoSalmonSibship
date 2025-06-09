### Reconstructing sibship with SNPs from Mayo

###
### Setup
###

# Packages
library(sequoia)
library(ggplot2)
library(dplyr)
library(magrittr)

# Directory
setwd("/Volumes/Synclair/Mayo_Salmon_SNP_Sibship/")

###
### Data
###

# Genotypes
GenoM <- GenoConvert(InFile = paste0("Data/inputfile_for_sequoia.raw"), InFormat="raw")

# Metadata
metadata <- read.csv("Data/Metadata_landscape_Genetics_Emfaf.csv")

###
### Analysis
###

# We don't expect fish from different rivers to be related, so we can save a lot
# of time by only considering relationships within rivers.

# We also know that our samples are single generation samples, so there can only
# be horizontal relationships among individual fish, no parent-offspring,
# avuncular, etc. To do this we set all fish to the same birth year in the life-
# history data.

# Get rivers
rivers <- unique(metadata$River)

# Make empty data.frame
results <- data.frame(id=character(),dam=character(),sire=character())

# Loop over rivers
for(river in rivers){
  
  # Select samples, format names to Benchmark format
  fish <- metadata %>% 
    filter(River == river) %>% 
    mutate(genID = paste0(genID,".CEL")) %>%
    pull(genID)
  
  # Subset genotypes
  GenoM_sub <- GenoM[fish,]
  
  # Generate fake life history data
  life_hist <- data.frame(ID=row.names(GenoM_sub),
                          Sex=1,BirthYear=2000)
  
  # Run the analysis
  sequoia_out_assign <- sequoia(GenoM = GenoM_sub,
                                LifeHistData = life_hist,
                                Module = "ped",
                                Err=1e-3,
                                quiet=T,
                                Tassign=3)
  
  # Extract and save parent data for all real samples
  results_i <- sequoia_out_assign$Pedigree %>%
    filter(grepl("CEL",id)) %>%
    select(id,dam,sire) %>% filter(!is.na(id)) %>%
    mutate(dam=ifelse(!is.na(dam),paste0(dam,"_",river),dam),
           sire=ifelse(!is.na(sire),paste0(sire,"_",river),sire))
  
  results <- rbind(results,results_i)
  
}

# Histogram of cluster size
results %>%
  filter(!is.na(dam),!is.na(sire)) %>%
  group_by(dam,sire) %>%
  summarise(size=n()) %>%
  pull(size) %>%
  hist(breaks=max(.)-min(.))

# Save table
write.table(results,"Analysis/sib_info.txt",
            row.names=F,col.names=T,sep="\t",quote=F)

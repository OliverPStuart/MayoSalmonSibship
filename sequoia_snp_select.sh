### Generating pruned SNPs for sibship inference

# Directory
cd /Volumes/Synclair/Mayo_Salmon_SNP_Sibship/Data

# Run PLINK
# Instructions lifted from sequoia userguide

conda activate variant

# Generate list of SNPs with
#   No missing data
#   MAF > 0.3
#   Maximum r^2 of 0.1
plink \
--file MG_MI_Ireland_25_1_05 \
--geno 0 \
--maf 0.3 \
--indep-pairwise 500kb 5 0.1 \
--chr-set 29

# This leaves us with a lot more than we need
# So we just select 1000 random ones
shuf plink.prune.in | head -n 1000 > list_snp
plink \
--file MG_MI_Ireland_25_1_05 \
--extract list_snp \
--recodeA \
--out inputfile_for_sequoia \
--chr-set 29

conda deactivate

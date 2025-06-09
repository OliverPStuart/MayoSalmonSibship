# Inferring sib clusters from Mayo salmon SNP data
Two files:
- `sequoia_snp_select.sh`: use plink to select good SNPs for sequoia (high MAF, low missing, low LD).
- `sequoia_sibship.R`: run [sequoia](https://github.com/JiscaH/sequoia) on the selected SNPs, river by river.

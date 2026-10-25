# Concordance-Analysis-of-Gremline-Variant-calling-Pipelines-for-WGS-SA-Cohort

Scripts, R code and summary results for a BSc Honours project (Bioinformatics and Computational Biology, Stellenbosch University) that compares three germline variant-calling pipelines on MGI DNBSEQ-T7 whole-genome sequencing data from 44 individuals (39 South African Coloured, 3 African, 2 European).

## What this repository contains

| Folder | Contents |
|---|---|
| `gatk/`, `deepvariant/`, `dragen_gatk/` | PBS scripts for each pipeline: alignment, calling, joint genotyping, filtering, population metrics |
| `metrics/` | Call-set statistics: Ti/Tv (known and novel), Hardy-Weinberg tests (PLINK), dbSNP concordance, quality distributions |
| `gnomad_compare/` | Normalisation of the call sets and pairwise allele overlap (Jaccard similarity, UpSet counts) |
| `rare_variant_analysis/` | gnomAD v4.1 `AF_grpmax` classification (positions, extraction, classification) and the per-individual counts used for the paired tests |
| `R/` | `Comparative_Variant_Calling_Analysis.Rmd` (call-set figures), `caller_class_tests.R` (paired tests), `upset_caller_concordance.R` (concordance figure) |
| `results/` | Summary spreadsheets (`Variant_analysis_updated.xlsx`) and the paired-test tables |
| `reference/` | Not included: https://hgdownload.soe.ucsc.edu/goldenpath/hg38/bigZips/ |


## Analysis overview

1. **Call variants** with three pipelines on the same 44 samples (GRCh38/hg38): GATK, DeepVariant with GLnexus, and open-source DRAGEN-GATK.
2. **Keep PASS records only.** DeepVariant records have no PASS label, so records with an unset filter are kept and the 100,819 flagged `MONOALLELIC` are removed. Multiallelic sites are split and indels left-aligned (`bcftools norm -m -any`).
3. **Describe the call sets:** counts, SNP/indel ratio, Ti/Tv, Het/Hom, missingness, Hardy-Weinberg, dbSNP concordance, and computational cost from PBS accounting.
4. **Measure concordance:** Jaccard similarity and the three-way overlap, shown as an UpSet plot.
5. **Classify alleles with gnomAD v4.1** by exact match and `AF_grpmax`: novel (absent), rare (0 < AF_grpmax < 0.05), common (AF_grpmax >= 0.05). Counts are reported per group (SAC, European, African).
6. **Compare callers per individual** with paired t-tests (Holm-adjusted), using four classes (novel, rare < 0.01, low-frequency 0.01 to < 0.05, common). Tests are run for SAC only (n = 39); the African (n = 3) and European (n = 2) groups are descriptive.

These tests compare what each pipeline calls. They do not measure accuracy, because no truth set was available.

## Requirements

- HPC cluster with PBS (scripts use `qsub`, including job arrays)
- Software and versions used (see the report, Table 5, for the full list): BWA-MEM 0.7.18, DRAGMAP 1.3.0, GATK 4.4.0.0 (GATK pipeline) and 4.6.2.0 (DRAGEN-GATK), DeepVariant 1.9.0, GLnexus 1.4.1, BCFtools 1.19, PLINK, FastQC 0.12.1, MultiQC 1.21
- R v4.6.1 with `readr`, `dplyr`, `tidyr`, `ggplot2`, `patchwork`, `scales` (and the packages loaded in the `.Rmd`)
- Internet access from the compute nodes to stream gnomAD v4.1 (`storage.googleapis.com/gcp-public-data--gnomad/release/4.1/vcf/genomes/`)

## How to reproduce the gnomAD classification

Set the paths at the top of each script first (`SCR` for scratch, `REF` for the hg38 FASTA, the three PASS-only VCFs and `groups.txt`).

```bash
# 1. Per-allele table with per-group counts (one task per caller)
qsub rare_variant_analysis/step1_alleles.pbs

# 2. Cohort positions, then extract only those sites from gnomAD (one task per chromosome)
qsub rare_variant_analysis/step2a_positions.pbs
qsub rare_variant_analysis/step2_gnomad.pbs

# 3. Classify alleles and count per group (one task per caller)
qsub rare_variant_analysis/step3_classify.pbs      # writes counts_<caller>.tsv

# 4. Per-individual counts per class, then the paired tests in R
qsub rare_variant_analysis/step4_persample.pbs     # writes persample_<caller>.tsv
Rscript R/caller_class_tests.R
```

`groups.txt` is a two-column, tab-separated file (`sample<TAB>group`, with group one of `SAC`, `European`, `African`).

## Data and reference files

- **Sequencing data and VCFs are not in this repository.** [TODO: state why, for example participant consent, and how to request access: contact and conditions.]
- **Do not commit** FASTQ/BAM/VCF files, `groups.txt`, sample lists or any file that links sample IDs to population labels. Add them to `.gitignore`:
  ```
  *.fastq.gz
  *.bam
  *.vcf.gz
  *.vcf.gz.tbi
  groups.txt
  sample_lists/
  ```
- **Reference files** are public: GRCh38/hg38 (`hg38.fa`), dbSNP build 138 and the Mills and 1000 Genomes gold-standard indels (used for BQSR in the GATK-based workflows), and gnomAD v4.1 genomes.
- Scripts contain absolute paths from the project's cluster. Replace them with your own, or move them into a single config file.

## Results

`results/Variant_analysis.xlsx` holds the summary tables behind the report: computational resources, call-set statistics, concordance, the gnomAD `AF_grpmax` classes by group, and per-population metrics.

## Limitations

- No truth set, so sensitivity and precision are not estimated.
- The two GATK-based workflows used different GATK versions (4.4.0.0 and 4.6.2.0).
- The African and European groups are too small for statistical inference.
- "Novel" means absent from gnomAD v4.1 by exact allele match, so it depends on the database and on how indels are represented.

## Citation

Scholtz, A. 2026. Concordance Analysis of Gremline Variant calling Pipelines for WGS SA Cohort. BSc Honours Bioinformatics and Computational Biology, Stellenbosch University

## URLs

[![TB Host Genetics](https://img.shields.io/badge/Division-TB%20Host%20Genetics-8a2be2.svg)](https://github.com/TBHostGenetics)
[![Stellenbosch University](https://img.shields.io/badge/Institution-Stellenbosch%20University-003366.svg)](https://www.sun.ac.za)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Contact

27777197@sun.ac.za. Supervisor: 

## Licence

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

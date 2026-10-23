#!/bin/bash

SAMPLES=(
549
899
906
1015
1017
1018
1019
1020
1021
1022
1023
1024
1025
1026
1027
1029
1032
1033
1035
1036
1037
1038
1041
1042
1054
1060
1064
1747
1756
)

for SAMPLE in "${SAMPLES[@]}"; do

    GVCF="${HOME}/Variantcalling/gatk/${SAMPLE}/haplotypecaller/${SAMPLE}.g.vcf.gz"
    TBI="${GVCF}.tbi"
    CSI="${GVCF}.csi"

    if [[ -s "$GVCF" && ( -s "$TBI" || -s "$CSI" ) ]]; then
        echo "SKIP ${SAMPLE}: GVCF already exists."

    else
        echo "SUBMIT ${SAMPLE}"
        qsub -v SAMPLE="${SAMPLE}" haplotypecaller.pbs
    fi

done

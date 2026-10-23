#!/bin/bash

GATK_DIR="${HOME}/Variantcalling/gatk"
BQSR_SCRIPT="${GATK_DIR}/gatk_bqsr.pbs"

SAMPLES=(
    1003 1004 1005 1007 1008 1009 1010 1011
    1013 1014 1015 1017 1018 1019 1020 1021
    1022 1023 1024 1025 1026 1027 1029 1032
    1033 1035 1036 1037 1038 1041 1042 1054
    1060 1064 1747 1756 35 47 549 73
    792 899 906
)

PREV_JOB=""

for SAMPLE in "${SAMPLES[@]}"; do

    DIR="${GATK_DIR}/${SAMPLE}"

    BAM="${DIR}/${SAMPLE}_bqsr.bam"
    BAI="${DIR}/${SAMPLE}_bqsr.bai"
    TABLE="${DIR}/${SAMPLE}_recal_data.table"

    # Skip completed samples
    if [[ -s "$BAM" && -s "$BAI" && -s "$TABLE" ]]; then
        echo "SKIP: ${SAMPLE} - already complete"
        continue
    fi

    if [[ -z "$PREV_JOB" ]]; then

        JOB=$(qsub \
            -v SAMPLE="${SAMPLE}" \
            "${BQSR_SCRIPT}")

    else

        JOB=$(qsub \
            -W depend=afterok:${PREV_JOB} \
            -v SAMPLE="${SAMPLE}" \
            "${BQSR_SCRIPT}")

    fi

    echo "SUBMITTED: ${SAMPLE} -> ${JOB}"

    PREV_JOB="${JOB}"

done

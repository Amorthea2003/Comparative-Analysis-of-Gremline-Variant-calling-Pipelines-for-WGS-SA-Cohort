#!/bin/bash

BASE_DIR="${HOME}/Variantcalling/gatk"

for dir in "${BASE_DIR}"/*/; do

    sample=$(basename "${dir}")

    DEDUP_BAM="${dir}${sample}_dedup.bam"
    FIXED_BAM="${dir}${sample}_dedup_fixed.bam"
    FIXED_BAI="${dir}${sample}_dedup_fixed.bam.bai"
    VALIDATION_FILE="${dir}${sample}_ValidateSamFile.txt"

    
    # Must have original deduplicated BAM
    

    if [[ ! -s "${DEDUP_BAM}" ]]; then
        echo "SKIP ${sample} - no deduplicated BAM"
        continue
    fi

    
    # Already successfully validated
    

    if [[ -s "${VALIDATION_FILE}" ]] && \
       ! grep -q "^ERROR:" "${VALIDATION_FILE}"; then

        echo "SKIP ${sample} - already validated successfully"
        continue
    fi

    
    # If fixed BAM already exists, only submit validation
    

    if [[ -s "${FIXED_BAM}" && -s "${FIXED_BAI}" ]]; then

        echo "SUBMIT VALIDATION ${sample}"

        qsub -v SAMPLE="${sample}" gatk_validate.pbs

        continue
    fi

    
    # Fix platform first
    

    echo "SUBMIT FIX PLATFORM ${sample}"

    FIX_JOB=$(qsub -v SAMPLE="${sample}" fix_platform.pbs)

    echo "Fix-platform job for ${sample}: ${FIX_JOB}"

    
    # Submit validation after fix-platform succeeds
    

    VALIDATE_JOB=$(qsub \
        -W depend=afterok:${FIX_JOB} \
        -v SAMPLE="${sample}" \
        gatk_validate.pbs)

    echo "Validation job for ${sample}: ${VALIDATE_JOB}"

done
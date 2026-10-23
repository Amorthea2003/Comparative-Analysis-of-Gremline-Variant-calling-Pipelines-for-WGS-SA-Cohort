#!/bin/bash


# DEEPVARIANT BATCH SUBMISSION SCRIPT


set -euo pipefail



# SETTINGS


SCRIPT="${HOME}/Variantcalling/deepvariant/deepvariant.pbs"
FASTQ_BASE="${HOME}/fastQ_files"
DV_BASE="${HOME}/Variantcalling/deepvariant"



# CHECK PBS SCRIPT


if [[ ! -f "${SCRIPT}" ]]; then

    echo "ERROR: DeepVariant PBS script not found:"
    echo "${SCRIPT}"

    exit 1

fi



# CHECK FASTQ DIRECTORY


if [[ ! -d "${FASTQ_BASE}" ]]; then

    echo "ERROR: FASTQ directory not found:"
    echo "${FASTQ_BASE}"

    exit 1

fi



# CHECK DEEPVARIANT DIRECTORY


mkdir -p "${DV_BASE}"



# FIND SAMPLE DIRECTORIES


SAMPLES=()

for FASTQ_DIR in "${FASTQ_BASE}"/*/; do

    [[ -d "${FASTQ_DIR}" ]] || continue

    SAMPLE=$(basename "${FASTQ_DIR}")

    SAMPLES+=("${SAMPLE}")

done



# CHECK SAMPLES


if [[ ${#SAMPLES[@]} -eq 0 ]]; then

    echo "ERROR: No sample directories found in:"
    echo "${FASTQ_BASE}"

    exit 1

fi



# SORT SAMPLE IDS


mapfile -t SAMPLES < <(
    printf '%s\n' "${SAMPLES[@]}" | sort -n
)



# GET CURRENT PBS JOBS


CURRENT_JOBS=$(qstat -u "${USER}" 2>/dev/null || true)



# DISPLAY SUBMISSION PLAN


echo
echo "============================================================"
echo "DEEPVARIANT BATCH SUBMISSION"
echo "============================================================"

echo "PBS script:"
echo "${SCRIPT}"

echo
echo "FASTQ directory:"
echo "${FASTQ_BASE}"

echo
echo "DeepVariant output directory:"
echo "${DV_BASE}"

echo
echo "Samples found: ${#SAMPLES[@]}"

echo
printf '%s\n' "${SAMPLES[@]}"

echo
echo "============================================================"



# COUNTERS


SUBMITTED=0
SKIPPED_DONE=0
SKIPPED_RUNNING=0
FAILED=0



# SUBMIT EACH SAMPLE


for SAMPLE in "${SAMPLES[@]}"; do

    FASTQ_DIR="${FASTQ_BASE}/${SAMPLE}"
    SAMPLE_DIR="${DV_BASE}/${SAMPLE}"

    DONE="${SAMPLE_DIR}/deepvariant.done"


    echo
    echo "------------------------------------------------------------"
    echo "Sample: ${SAMPLE}"
    echo "FASTQ:  ${FASTQ_DIR}"
    echo "Output: ${SAMPLE_DIR}"
    echo "------------------------------------------------------------"


    
    # SKIP ALREADY COMPLETED SAMPLES
    

    if [[ -s "${DONE}" ]]; then

        echo "STATUS: ALREADY COMPLETED"
        echo "Completion marker:"
        echo "${DONE}"

        ((SKIPPED_DONE+=1))

        continue

    fi


    
    # CHECK WHETHER SAMPLE IS ALREADY RUNNING/QUEUED
    

    if echo "${CURRENT_JOBS}" | grep -qE "DeepVaria.*${SAMPLE}|${SAMPLE}.*DeepVaria"; then

        echo "STATUS: ALREADY QUEUED/RUNNING"

        ((SKIPPED_RUNNING+=1))

        continue

    fi


    
    # SUBMIT JOB
    

    echo "STATUS: SUBMITTING"

    if JOB_ID=$(qsub -v SAMPLE="${SAMPLE}" "${SCRIPT}"); then

        echo "Submitted successfully."
        echo "Sample: ${SAMPLE}"
        echo "Job ID: ${JOB_ID}"

        ((SUBMITTED+=1))

    else

        echo "ERROR: Failed to submit sample ${SAMPLE}."

        ((FAILED+=1))

    fi

done



# SUMMARY


echo
echo
echo "============================================================"
echo "DEEPVARIANT SUBMISSION SUMMARY"
echo "============================================================"

echo "Total samples found:       ${#SAMPLES[@]}"
echo "New jobs submitted:        ${SUBMITTED}"
echo "Already completed:         ${SKIPPED_DONE}"
echo "Already queued/running:    ${SKIPPED_RUNNING}"
echo "Submission failures:       ${FAILED}"

echo
echo "Check jobs with:"
echo
echo "qstat -u \$USER"

echo
echo "Check DeepVariant completion markers with:"
echo
echo "find ${DV_BASE} -name deepvariant.done"

echo
echo "============================================================"



# EXIT STATUS


if [[ ${FAILED} -gt 0 ]]; then
    exit 1
fi

exit 0
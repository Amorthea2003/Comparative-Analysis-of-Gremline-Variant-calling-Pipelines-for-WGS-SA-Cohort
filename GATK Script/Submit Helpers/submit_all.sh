#!/bin/bash

for SAMPLE_DIR in ~/fastQ_files/*/; do

    SAMPLE=$(basename "${SAMPLE_DIR}")

    echo "Submitting sample ${SAMPLE}..."

    qsub -v SAMPLE="${SAMPLE}" gatk_preproccessing.pbs

done
#!/bin/bash

for SAMPLE in 1003 1004 1014 1017 1018 1035 1064 1747 35 47 73 792 899 906
do
    echo "Submitting recovery for ${SAMPLE}"
    qsub -v SAMPLE="${SAMPLE}" gatk_recovery.pbs
done

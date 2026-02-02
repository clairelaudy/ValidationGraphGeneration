#!/bin/sh

CONTAINER="../test_size_ontology.sif"

if [[ ! -f $CONTAINER ]] ; then
    echo "ERROR: I do not see the apptainer container: test_size_ontology.sif, please build it here before running this script." >&2
    exit 1
fi

SIZE=""
if [[ -z "$1" ]] ; then
    echo "Usage: $0 <size>" >&2
    exit 2
else
    SIZE="$1"
fi

module load apptainer

export APPTAINER_BINDPATH=$(pwd):/output/

apptainer run $CONTAINER parent_class $SIZE $SLURM_JOB_ID


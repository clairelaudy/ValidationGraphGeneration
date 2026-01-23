#!/bin/sh

if [[ ! -f test_ontology_size.sif ]] ; then
    echo "ERROR: I do not see the apptainer container: test_ontology_size.sif, please build it here before running this script." >&2
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

export APPTAINER_BINDPATH=$(pwd):/experiments

apptainer run test_ontology_size.sif simplest $SIZE $SLURM_JOB_ID


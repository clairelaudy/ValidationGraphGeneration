#!/bin/sh

module load apptainer

export APPTAINER_BINDPATH=/home/claudy/experiments:/experiments

apptainer run test_ontology_size.sif simplest $1 $SLURM_JOB_ID

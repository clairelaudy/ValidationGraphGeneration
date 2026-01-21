#!/usr/bin/bash

set -ex

apptainer cache clean -f
apptainer build -F test_ontology_size.sif /Users/claudy/work/projects/ValidationGraphGeneration/test_ontology_size.def


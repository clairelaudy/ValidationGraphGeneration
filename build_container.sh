#!/usr/bin/bash

set -ex

apptainer cache clean -f
apptainer build -F test_ontology_size.sif ~/ValidationGraphGeneration/test_ontology_size.def


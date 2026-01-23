#!/bin/sh

for i in $(seq 10 1000 10000) ; do
  sbatch --job-name=tso$i ./run_test_size_ontology.sh $i 

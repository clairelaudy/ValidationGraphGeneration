#!/usr/bin/bash

rm -rf experiments/*

cp -rf /Users/claudy/work/projects/ValidationGraphGeneration ~/

APPTAINER_BINDPATH=~/ValidationGraphGeneration:/ValidationGraphGeneration,/home/claudy.linux/experiments:/experiments \
  apptainer run test_ontology_size.sif simplest 10 1 DEBUG
  
cat /tmp/validation_graph.log 

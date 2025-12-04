#!/bin/sh
set -e

PATH_TO_SCENARIO=$1
NUMBER_OF_PERSONS=$2

if [ $# -ne 2 ] ; then
  echo "Usage: $0 <path_to_scenario> <number_of_persons>" 1>&2
  exit 2
fi

export PYTHONPATH="$PYTHONPATH:$HOME/work/projects/biocypher/:$HOME/work/projects/ontoweaver/"

uv sync

echo "** Clean biocypher output directory"
rm -rf biocypher-out/
rm -rf "output/$PATH_TO_SCENARIO/"

echo "** Generate CSV data"
uv run src/generate_full_data.py $NUMBER_OF_PERSONS output/data.csv

echo "** Populate the ontology with data"
uv run ontoweave output/data.csv:"input/$PATH_TO_SCENARIO/mapping.yaml" -s "input/$PATH_TO_SCENARIO/schema_config.yaml" -C "input/$PATH_TO_SCENARIO/biocypher_config.yaml" --register src/pets_transformer.py --debug

echo "** Copy Biocypher output to working directory"
mkdir "output/$PATH_TO_SCENARIO/"
cp biocypher-out/*/biocypher.ttl  "output/$PATH_TO_SCENARIO/biocypher.ttl"

echo "** Launch reasoner to infer new information"
robot reason --reasoner hermit --input "output/$PATH_TO_SCENARIO/biocypher.ttl" --output "output/$PATH_TO_SCENARIO/reasoned.ttl" --axiom-generators "PropertyAssertion EquivalentObjectProperty InverseObjectProperties ObjectPropertyCharacteristic SubObjectProperty" 

echo "** Export owl ontology to BioPathNet format"
import_file=$(uv run ontoweave "output/$PATH_TO_SCENARIO/reasoned.ttl":automap -s "input/$PATH_TO_SCENARIO/schema_config.yaml" -C "input/$PATH_TO_SCENARIO/biocypher_config_2_biopathnet.yaml" --debug)

cat $(dirname $import_file)/*


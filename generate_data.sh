#!/bin/sh
set -ex

PATH_TO_SCENARIO=$1
NUMBER_OF_PERSONS=$2
NUMBER_OF_ABLATION=$3
EDGE_TO_LEARN=$4
LEARNING_GRAPH_FILE=$5

if [ $# -ne 5 ] ; then
  echo "Usage: $0 <path_to_scenario> <number_of_persons> <number_of_learning_edges_to_remove> <type_of_edge_to_remove> <output_learning_graph_file_name>" 1>&2
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
# uv run ontoweave output/data.csv:"input/$PATH_TO_SCENARIO/mapping.yaml" -s "input/$PATH_TO_SCENARIO/schema_config.yaml" -C "input/$PATH_TO_SCENARIO/biocypher_config.yaml" --register src/pets_transformer.py --debug
uv run src/csv2owl.py output/data.csv "input/$PATH_TO_SCENARIO/mapping.yaml" "input/$PATH_TO_SCENARIO/biocypher_config.yaml" "input/$PATH_TO_SCENARIO/schema_config.yaml" #--register src/pets_transformer.py --debug

echo "** Copy Biocypher output to working directory"
mkdir "output/$PATH_TO_SCENARIO/"
cp biocypher-out/*/biocypher.ttl  "output/$PATH_TO_SCENARIO/biocypher.ttl"

echo "** Launch reasoner to infer new information"
robot reason --reasoner hermit --input "output/$PATH_TO_SCENARIO/biocypher.ttl" --output "output/$PATH_TO_SCENARIO/reasoned.ttl" --axiom-generators "PropertyAssertion EquivalentObjectProperty InverseObjectProperties ObjectPropertyCharacteristic SubObjectProperty" 

echo "** Export owl ontology to BioPathNet format"
import_file=$(uv run ontoweave "output/$PATH_TO_SCENARIO/reasoned.ttl":automap -s "input/$PATH_TO_SCENARIO/schema_config.yaml" -C "input/$PATH_TO_SCENARIO/biocypher_config_2_biopathnet.yaml" --debug)
out=$(dirname $import_file)

echo "OUTPUT BRG graph :"
cp "$out/train1.txt" "output/$PATH_TO_SCENARIO/brg.txt"
cat "output/$PATH_TO_SCENARIO/brg.txt" 

echo "OUTPUT Semantic Network :"
cp "$out/train2.txt" "output/$PATH_TO_SCENARIO/semantic_graph.txt"
cat "output/$PATH_TO_SCENARIO/semantic_graph.txt"

echo "OUTPUT entity_types.txt :"
cat "$out/entity_types.txt"

echo "Ablation of data in the learning graph"
uv run src/data_ablation.py $4 $3 "output/$PATH_TO_SCENARIO/semantic_graph.txt" "output/$PATH_TO_SCENARIO/$LEARNING_GRAPH_FILE" "output/$PATH_TO_SCENARIO/test.txt"


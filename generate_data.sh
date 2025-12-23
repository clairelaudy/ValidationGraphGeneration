#!/bin/sh
# /// script
# dependencies = [
#    "biocypher<1.0.0,>=0.11.0",
#    "pooch<2.0.0,>=1.7.0",
#    "pandas<3.0.0,>=2.3.1",
#    "numpy<3.0.0,>=2.2.4",
#    "owlready2<1.0,>=0.49",
#    "jsonargparse<5.0,>=4.39",
#    "xdg-base-dirs<7.0.0,>=6.0.2",
#    "pandera[io]<1.0.0,>=0.27.0",
#    "alive-progress<4.0,>=3.2",
#    "fsspec<2026.0.0,>=2025.10.0",
#    "natsort>5.0.0",
#    "lxml>6.0.0",
#    "jmespath>=1.0.1",
# ]
# ///

set -ex

NAME_OF_SCENARIO=$1
NUMBER_OF_PERSONS=$2
NUMBER_OF_ABLATION=$3
EDGE_TO_LEARN=$4
RATIO_VALID=$5


PATH_TO_SCENARIO=${NAME_OF_SCENARIO}_${NUMBER_OF_PERSONS} 

LEARNING_GRAPH_FILE=${PATH_TO_SCENARIO}_${NUMBER_OF_ABLATION}_${EDGE_TO_LEARN}


echo "** Generate CSV data"
uv run src/generate_full_data.py $NUMBER_OF_PERSONS output/$PATH_TO_SCENARIO/data.csv

echo "** Populate the ontology with data"
src/csv2owl.py output/$PATH_TO_SCENARIO/data.csv "input/$NAME_OF_SCENARIO/mapping.yaml" "input/$NAME_OF_SCENARIO/biocypher_config.yaml" "input/$NAME_OF_SCENARIO/schema_config.yaml" #--register src/pets_transformer.py --debug

echo "** Copy Biocypher output to working directory"
cp biocypher-out/*/biocypher.ttl  "output/$PATH_TO_SCENARIO/biocypher.ttl"

echo "** Launch reasoner to infer new information"
robot reason --reasoner hermit --input "output/$PATH_TO_SCENARIO/biocypher.ttl" --output "output/$PATH_TO_SCENARIO/reasoned.ttl" --axiom-generators "PropertyAssertion EquivalentObjectProperty InverseObjectProperties ObjectPropertyCharacteristic SubObjectProperty" 

cat biocypher_config_template.yaml | sed "s,{{ONTOLOGY_URL}},output/$PATH_TO_SCENARIO/reasoned.ttl," > input/$NAME_OF_SCENARIO/biocypher_config_2_bioPathNet.yaml

echo "** Export owl ontology to BioPathNet format"
import_file=$(ontoweave "output/$PATH_TO_SCENARIO/reasoned.ttl":automap -s "input/$NAME_OF_SCENARIO/schema_config.yaml" -C "input/$NAME_OF_SCENARIO/biocypher_config_2_bioPathNet.yaml")
out=$(dirname $import_file)

echo "OUTPUT BRG graph :"
cp "$out/train1.txt" "output/$PATH_TO_SCENARIO/brg.txt"
cat "output/$PATH_TO_SCENARIO/brg.txt" 

echo "OUTPUT Semantic Network :"
cp "$out/train2.txt" "output/$PATH_TO_SCENARIO/semantic_graph.txt"
cat "output/$PATH_TO_SCENARIO/semantic_graph.txt"

echo "OUTPUT entity_types.txt :"
cp "$out/entity_types.txt" "output/$PATH_TO_SCENARIO/entity_types.txt"
cat "output/$PATH_TO_SCENARIO/entity_types.txt"

echo "OUTPUT entity_names.txt :"
cp "$out/entity_names.txt" "output/$PATH_TO_SCENARIO/entity_names.txt"
cat "output/$PATH_TO_SCENARIO/entity_names.txt"

echo "** Ablation of data in the learning graph"
uv run src/data_ablation.py $EDGE_TO_LEARN $NUMBER_OF_ABLATION "output/$PATH_TO_SCENARIO/semantic_graph.txt" "output/$PATH_TO_SCENARIO/${LEARNING_GRAPH_FILE}_learning.txt" "output/$PATH_TO_SCENARIO/${LEARNING_GRAPH_FILE}_test.txt"

echo "** Make validation dataset"
uv run src/make_validation_set.py ${EDGE_TO_LEARN} ${RATIO_VALID} "output/${PATH_TO_SCENARIO}/${LEARNING_GRAPH_FILE}_learning.txt" "output/$PATH_TO_SCENARIO/${LEARNING_GRAPH_FILE}_valid.txt"


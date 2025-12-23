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


PATH_TO_DATA=${NUMBER_OF_PERSONS}
PATH_TO_SCENARIO=${NUMBER_OF_PERSONS}/${NAME_OF_SCENARIO}
LEARNING_GRAPH_FILE=${NAME_OF_SCENARIO}_${NUMBER_OF_PERSONS}_${NUMBER_OF_ABLATION}_${EDGE_TO_LEARN}


echo "** Populate the ontology with data" 1>&2
src/csv2owl.py output/$PATH_TO_DATA/data.csv "input/$NAME_OF_SCENARIO/mapping.yaml" "input/$NAME_OF_SCENARIO/biocypher_config.yaml" "input/$NAME_OF_SCENARIO/schema_config.yaml" #--register src/pets_transformer.py --debug

echo "** Copy Biocypher output to working directory" 1>&2
cp biocypher-out/*/biocypher.ttl  "output/$PATH_TO_SCENARIO/biocypher.ttl"
rm biocypher-out/*/biocypher.ttl

echo "** Launch reasoner to infer new information" 1>&2
robot reason --reasoner hermit --input "output/$PATH_TO_SCENARIO/biocypher.ttl" --output "output/$PATH_TO_SCENARIO/reasoned.ttl" --axiom-generators "PropertyAssertion EquivalentObjectProperty InverseObjectProperties ObjectPropertyCharacteristic SubObjectProperty" 

cat biocypher_config_template.yaml | sed "s,{{ONTOLOGY_URL}},output/$PATH_TO_SCENARIO/reasoned.ttl," > input/$NAME_OF_SCENARIO/biocypher_config_2_bioPathNet.yaml

echo "** Export owl ontology to BioPathNet format" 1>&2
import_file=$(ontoweave "output/$PATH_TO_SCENARIO/reasoned.ttl":automap -s "input/$NAME_OF_SCENARIO/schema_config.yaml" -C "input/$NAME_OF_SCENARIO/biocypher_config_2_bioPathNet.yaml")
out=$(dirname $import_file)

echo "OUTPUT BRG graph :" 1>&2
cp "$out/train1.txt" "output/$PATH_TO_SCENARIO/brg.txt"
#cat "output/$PATH_TO_SCENARIO/brg.txt" 1>&2

echo "OUTPUT Semantic Network :" 1>&2
cp "$out/train2.txt" "output/$PATH_TO_SCENARIO/semantic_graph.txt"
#cat "output/$PATH_TO_SCENARIO/semantic_graph.txt"

echo "OUTPUT entity_types.txt :" 1>&2
cp "$out/entity_types.txt" "output/$PATH_TO_SCENARIO/entity_types.txt"
#cat "output/$PATH_TO_SCENARIO/entity_types.txt"

echo "OUTPUT entity_names.txt :" 1>&2
cp "$out/entity_names.txt" "output/$PATH_TO_SCENARIO/entity_names.txt"
#cat "output/$PATH_TO_SCENARIO/entity_names.txt"

echo "** Ablation of data in the learning graph" 1>&2
uv run src/data_ablation.py $EDGE_TO_LEARN $NUMBER_OF_ABLATION "output/$PATH_TO_SCENARIO/semantic_graph.txt" "output/$PATH_TO_SCENARIO/${LEARNING_GRAPH_FILE}_learning.txt" "output/$PATH_TO_SCENARIO/${LEARNING_GRAPH_FILE}_test.txt"

echo "** Make validation dataset"
uv run src/make_validation_set.py ${EDGE_TO_LEARN} ${RATIO_VALID} "output/${PATH_TO_SCENARIO}/${LEARNING_GRAPH_FILE}_learning.txt" "output/$PATH_TO_SCENARIO/${LEARNING_GRAPH_FILE}_valid.txt"


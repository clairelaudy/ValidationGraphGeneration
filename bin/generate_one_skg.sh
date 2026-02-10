#!/bin/sh
# /// script
# dependencies = [
#    "ontoweaver",
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
PATH_TO_EXPE=$2
TYPE_OF_GRAPH=$3

BIN_DIR=$(realpath $(dirname $0))

mkdir -p input
echo $PWD
cp -r "$BIN_DIR/../input/$NAME_OF_SCENARIO" input/

echo "** Populate the ontology with data" 1>&2
$BIN_DIR/../src/generation/csv2owl.py "output/$PATH_TO_EXPE/data_$TYPE_OF_GRAPH.csv" "$BIN_DIR/../input/$NAME_OF_SCENARIO/ontology.ttl" "$BIN_DIR/../input/$NAME_OF_SCENARIO/mapping.yaml" "$BIN_DIR/../input/$NAME_OF_SCENARIO/biocypher_config.yaml" "$BIN_DIR/../input/$NAME_OF_SCENARIO/schema_config.yaml" #--register src/pets_transformer.py --debug

echo "** Copy Biocypher output to working directory" 1>&2
cp biocypher-out/*/biocypher.ttl  "output/$PATH_TO_EXPE/biocypher.ttl"
rm biocypher-out/*/biocypher.ttl

echo "** Launch reasoner to infer new information" 1>&2
robot reason --reasoner hermit --input "output/$PATH_TO_EXPE/biocypher.ttl" --output "output/$PATH_TO_EXPE/reasoned_$TYPE_OF_GRAPH.ttl" --axiom-generators "PropertyAssertion EquivalentObjectProperty InverseObjectProperties ObjectPropertyCharacteristic SubObjectProperty" 
chmod a-w "output/$PATH_TO_EXPE/reasoned_$TYPE_OF_GRAPH.ttl"

cat $BIN_DIR/../input/biocypher_config_template.yaml | sed "s,{{ONTOLOGY_URL}},output/$PATH_TO_EXPE/reasoned_$TYPE_OF_GRAPH.ttl," > input/$NAME_OF_SCENARIO/biocypher_config_2_bioPathNet.yaml

echo "** Export owl ontology to BioPathNet format" 1>&2
import_file=$(uv run ontoweave "output/$PATH_TO_EXPE/reasoned_$TYPE_OF_GRAPH.ttl":automap -s "$BIN_DIR/../input/$NAME_OF_SCENARIO/schema_config.yaml" -C "input/$NAME_OF_SCENARIO/biocypher_config_2_bioPathNet.yaml")
echo "show output of ontoweave: "
out=$(dirname $import_file)

echo "OUTPUT Semantic Network :" 1>&2
cp "$out/skg.txt" "output/$PATH_TO_EXPE/graph_$TYPE_OF_GRAPH.txt"
#cat "output/$PATH_TO_SCENARIO/semantic_graph.txt"

echo "OUTPUT brg.txt :" 1>&2
cat "$out/brg.txt" >> "output/$PATH_TO_EXPE/brg.txt"
#cat "output/$PATH_TO_SCENARIO/entity_types.txt"

echo "OUTPUT entity_types.txt :" 1>&2
cat "$out/entity_types.txt" >> "output/$PATH_TO_EXPE/entity_types.txt"
#cat "output/$PATH_TO_SCENARIO/entity_types.txt"

echo "OUTPUT entity_names.txt :" 1>&2
cat "$out/entity_names.txt" >> "output/$PATH_TO_EXPE/entity_names.txt"
#cat "output/$PATH_TO_SCENARIO/entity_names.txt"


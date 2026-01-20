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
NUMBER_OF_LEARNING_DATA=$2

PATH_TO_EXPE="${NAME_OF_SCENARIO}/${NUMBER_OF_LEARNING_DATA}"

if [ $# -ne 2 ] ; then
echo "Usage: $0 <name_of_scenario> <nb_of_persons_in_data>" 1>&2
  exit 2
fi


#EXPE=experiments/$(date -Iseconds|sed "s/:/_/g")
EXPE=experiments/xxx
mkdir -p $EXPE

cd $EXPE
#git clone ../.. .
git clone ../.. graphGeneration

export PYTHONPATH="$PYTHONPATH:$HOME/work/projects/biocypher/:$HOME/work/projects/ontoweaver/src/:$HOME/work/projects/ValidationGraphGeneration/src/"
#export PATH="$PATH:$HOME/work/projects/ontoweaver/bin/:$HOME/work/projects/ValidationGraphGeneration/bin/"
export PATH="$PATH:$HOME/work/projects/ontoweaver/bin/:$HOME/work/projects/ValidationGraphGeneration/$EXPE/graphGeneration/bin/:$HOME/work/projects/ValidationGraphGeneration/$EXPE/graphGeneration/src/generation/"

uv sync

#Generate learning data and skg
echo "Generate CSV data for learning skg" 1>&2
uv run generate_full_data.py ${NUMBER_OF_LEARNING_DATA} "output/${PATH_TO_EXPE}/data.csv"

echo "** Populate the ontology with data" 1>&2
csv2owl.py "output/$PATH_TO_EXPE/data.csv" "graphGeneration/input/$NAME_OF_SCENARIO/mapping.yaml" "graphGeneration/input/$NAME_OF_SCENARIO/biocypher_config.yaml" "graphGeneration/input/$NAME_OF_SCENARIO/schema_config.yaml" #--register src/pets_transformer.py --debug

echo "** Copy Biocypher output to working directory" 1>&2
cp biocypher-out/*/biocypher.ttl  "output/$PATH_TO_EXPE/biocypher.ttl"
rm biocypher-out/*/biocypher.ttl

echo "** Launch reasoner to infer new information" 1>&2
/usr/bin/time -o "output/$PATH_TO_EXPE/time.txt" robot reason --reasoner hermit --input "output/$PATH_TO_EXPE/biocypher.ttl" --output "output/$PATH_TO_EXPE/reasoned.ttl" --axiom-generators "PropertyAssertion EquivalentObjectProperty InverseObjectProperties ObjectPropertyCharacteristic SubObjectProperty" 

#!/usr/bin/bash
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

main () {
    NAME_OF_SCENARIO=$1
    NUMBER_OF_LEARNING_DATA=$2
    SEED=$3
    FIXED_EXPE=$4

    PATH_TO_EXPE="${NAME_OF_SCENARIO}/${NUMBER_OF_LEARNING_DATA}"

    if [[ $# -lt 2 || $# -gt 4 ]] ; then
      echo "Usage: $0 <name_of_scenario> <nb_of_persons_in_data> [seed] [fixed_expe_name]" 1>&2
      exit 2
    fi

    if [[ ! -f config/env.sh ]] ; then
        echo "ERROR: config/env.sh not found, please edit this file to set your PATH and PYTHONPATH (it can be empty as well)." 1>&2
        exit 3
    else
        source config/env.sh
    fi

    if [[ -z "$SEED" ]] ; then
        SEED=0
    fi

    EXPE=""
    if [[ -z "$FIXED_EXPE" ]] ; then
        EXPE="experiments/$(date -Iseconds|sed 's/:/_/g')"
    else
        EXPE="experiments/$FIXED_EXPE"
    fi
    mkdir -p $EXPE

    cd $EXPE
    #git clone ../.. .
    #git clone ../.. graphGeneration
    rm -rf graphGeneration
    git clone --branch main --single-branch --recurse-submodules https://github.com/clairelaudy/ValidationGraphGeneration graphGeneration

    XPDIR=$(pwd)
    export PATH="$PATH:$XPDIR/graphGeneration/bin/:$XPDIR/graphGeneration/src/generation/"

    uv sync

    #Generate learning data and skg
    echo "Generate CSV data for learning skg" 1>&2
    uv run generate_full_data.py --seed $SEED ${NUMBER_OF_LEARNING_DATA} "output/${PATH_TO_EXPE}/data.csv"

    echo "** Populate the ontology with data" 1>&2
    csv2owl.py "output/$PATH_TO_EXPE/data.csv" "graphGeneration/input/$NAME_OF_SCENARIO/mapping.yaml" "graphGeneration/input/$NAME_OF_SCENARIO/biocypher_config.yaml" "graphGeneration/input/$NAME_OF_SCENARIO/schema_config.yaml" #--register src/pets_transformer.py --debug

    echo "** Copy Biocypher output to working directory" 1>&2
    cp biocypher-out/*/biocypher.ttl  "output/$PATH_TO_EXPE/biocypher.ttl"
    rm biocypher-out/*/biocypher.ttl

    LOG_FILE="$EXPE/scen-${NAME_OF_SCENARIO}_nb-${NUMBER_OF_LEARNING_DATA}_seed-${SEED}_expe-${FIXED_EXPE}.log"
    echo -n "Number of owl:Class: " > $LOG_FILE
    grep -o "a owl:Class" "output/$PATH_TO_EXPE/biocypher.ttl" | wc -l >> $LOG_FILE
    echo -n "Number of owl:NamedIndividual: " >> $LOG_FILE
    grep -o "owl:NamedIndividual" "output/$PATH_TO_EXPE/biocypher.ttl" | wc -l >> $LOG_FILE
    
    echo "** Launch reasoner to infer new information" 1>&2
    /usr/bin/time -o "output/$PATH_TO_EXPE/time_reasoner.txt" robot reason --reasoner hermit --input "output/$PATH_TO_EXPE/biocypher.ttl" --output "output/$PATH_TO_EXPE/reasoned.ttl" --axiom-generators "PropertyAssertion EquivalentObjectProperty InverseObjectProperties ObjectPropertyCharacteristic SubObjectProperty"

    echo "$EXPE"
}

{ time main $*; } 1> /tmp/validation_graph.out 2> >(tee /tmp/validation_graph.log)
EXPE=$(cat /tmp/validation_graph.out)
cp /tmp/validation_graph.log "$EXPE/scen${1}_nb${2}_seed${3}_fixed${4}.log"

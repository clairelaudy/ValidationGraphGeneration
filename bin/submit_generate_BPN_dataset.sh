#!/bin/sh
# To be ran from the experiment directory.
# Not from the source repository.

EXPE=$(date -Iseconds | sed s/:/_/g)
if [[ -n "$1" ]] ; then
    EXPE=$1
fi
mkdir -p $EXPE
echo "Output directory: $EXPE" >&2
cd $EXPE

VGG_BIN="../$(dirname $0)"

NAME_OF_SCENARIO=simplest
NUMBER_OF_LEARNING_DATA=100
NUMBER_OF_VALIDATION_DATA=10
NUMBER_OF_TEST_DATA=10
EDGE_TO_LEARN=hasChild
NUMBER_OF_ABLATION=2

sbatch --job-name=gBPN_${NAME_OF_SCENARIO} \
    --error=gBPN_n${NAME_OF_SCENARIO}_s%j.log \
    --output=gBPN_n${NAME_OF_SCENARIO}_s%j.out \
    $VGG_BIN/run_generate_BPN_dataset.sh ${NAME_OF_SCENARIO} ${NUMBER_OF_LEARNING_DATA} ${NUMBER_OF_VALIDATION_DATA} ${NUMBER_OF_TEST_DATA} ${EDGE_TO_LEARN} ${NUMBER_OF_ABLATION} 


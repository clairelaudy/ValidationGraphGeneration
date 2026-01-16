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
#    "faker",
#    "pandas",
#    "petname",
#    "ontoweaver",
# ]
# ///

set -ex

NAME_OF_SCENARIO=$1
NUMBER_OF_LEARNING_DATA=$2
NUMBER_OF_VALIDATION_DATA=$3
NUMBER_OF_TEST_DATA=$4
EDGE_TO_LEARN=$5
NUMBER_OF_ABLATION=$6

PATH_TO_EXPE="${NAME_OF_SCENARIO}/${NUMBER_OF_LEARNING_DATA}/${NUMBER_OF_VALIDATION_DATA}/${NUMBER_OF_TEST_DATA}/${EDGE_TO_LEARN}/${NUMBER_OF_ABLATION}"

if [ $# -ne 6 ] ; then
echo "Usage: $0 <name_of_scenario> <nb_of_persons_in_learning_data> <nb_of_persons_in_validation_graph> <nb_of_persons_in_test_graph> <edge_to_learn> <nb_of_ablation_in_test_graph>" 1>&2
  exit 2
fi

#Generate the independant learing, validation and test skgs
./bin/prepare_expe.sh ${NAME_OF_SCENARIO} ${NUMBER_OF_LEARNING_DATA} ${NUMBER_OF_VALIDATION_DATA} ${NUMBER_OF_TEST_DATA} ${EDGE_TO_LEARN} ${NUMBER_OF_ABLATION}

#EXPE=experiments/$(date -Iseconds|sed "s/:/_/g")
EXPE=experiments/xxx
#mkdir -p $EXPE

cd $EXPE
# #git clone ../.. .
# git clone ../.. graphGeneration

export PYTHONPATH="$PYTHONPATH:$HOME/work/projects/biocypher/:$HOME/work/projects/ontoweaver/src/:$HOME/work/projects/ValidationGraphGeneration/src/"
export PATH="$PATH:$HOME/work/projects/ontoweaver/bin/:$HOME/work/projects/ValidationGraphGeneration/bin/"
export PATH="$PATH:$HOME/work/projects/ontoweaver/bin/:$HOME/work/projects/ValidationGraphGeneration/$EXPE/graphGeneration/bin/:$HOME/work/projects/ValidationGraphGeneration/$EXPE/graphGeneration/src/generation/"

# uv sync



# #Generate learning data and skg
# echo "Generate CSV data for learning skg" 1>&2
# uv run generate_full_data.py ${NUMBER_OF_LEARNING_DATA} "output/${PATH_TO_EXPE}/data_learning.csv"
# echo "Generate learning skg" 1>&2
# generate_one_skg.sh ${NAME_OF_SCENARIO} ${PATH_TO_EXPE} "learning"


# #Generate validation data and skg
# echo "Generate CSV data for validation skg" 1>&2
# uv run generate_full_data.py ${NUMBER_OF_VALIDATION_DATA} "output/${PATH_TO_EXPE}/data_validation.csv"
# echo "Generate validation skg" 1>&2
# generate_one_skg.sh ${NAME_OF_SCENARIO} ${PATH_TO_EXPE} "validation"

# #Generate test data and skg
# echo "Generate CSV data for test skg" 1>&2
# uv run generate_full_data.py ${NUMBER_OF_TEST_DATA} "output/${PATH_TO_EXPE}/data_test.csv"
# echo "Generate ground truth for test skg" 1>&2
# generate_one_skg.sh ${NAME_OF_SCENARIO} ${PATH_TO_EXPE} "test"
# mv "output/${PATH_TO_EXPE}/graph_test.txt" "output/${PATH_TO_EXPE}/graph_test_gt.txt"
 
# echo "** Ablation of data in the test skg" 1>&2
# uv run data_ablation.py $EDGE_TO_LEARN $NUMBER_OF_ABLATION "output/${PATH_TO_EXPE}/graph_test_gt.txt" "output/${PATH_TO_EXPE}/graph_test.txt"

# #Remove duplicates in brg.txt entity_types.txt and entity_names.txt

# sort -u "output/${PATH_TO_EXPE}/brg.txt" > "output/${PATH_TO_EXPE}/brg_no_duplicates.txt"
# rm "output/${PATH_TO_EXPE}/brg.txt" y
# mv "output/${PATH_TO_EXPE}/brg_no_duplicates.txt" "output/${PATH_TO_EXPE}/brg.txt"

# sort -u "output/${PATH_TO_EXPE}/entity_types.txt" > "output/${PATH_TO_EXPE}/entity_types_no_duplicates.txt"
# rm "output/${PATH_TO_EXPE}/entity_types.txt" y
# mv "output/${PATH_TO_EXPE}/entity_types_no_duplicates.txt" "output/${PATH_TO_EXPE}/entity_types.txt"

# sort -u "output/${PATH_TO_EXPE}/entity_names.txt" > "output/${PATH_TO_EXPE}/entity_names_no_duplicates.txt"
# rm "output/${PATH_TO_EXPE}/entity_names.txt" 
# mv "output/${PATH_TO_EXPE}/entity_names_no_duplicates.txt" "output/${PATH_TO_EXPE}/entity_names.txt"


# Add the lines of graph_validation.txt that contain ${EDGE_TO_PREDICT} in edges_for_validation.txt
# And the other ones in graph_learning_with_validation_and_test.txt
# And add all the validation graph to the ground truth graph
grep "${EDGE_TO_LEARN}" "output/${PATH_TO_EXPE}/graph_validation.txt" >> "output/${PATH_TO_EXPE}/edges_for_validation.txt"
grep -v "${EDGE_TO_LEARN}" "output/${PATH_TO_EXPE}/graph_validation.txt" > "output/${PATH_TO_EXPE}/graph_learning_dup.txt"
cat "output/${PATH_TO_EXPE}/graph_learning.txt" "output/${PATH_TO_EXPE}/graph_validation.txt" > "output/${PATH_TO_EXPE}/ground_truth_dup.txt"
 

# Add the nodes and edges of the test graph to the ground truth graph
cat "output/${PATH_TO_EXPE}/graph_test_gt.txt" >> "output/${PATH_TO_EXPE}/ground_truth_dup.txt"

# And add the edges to be queried in a edges_to_predict.txt file for BioPathNet
uv run generate_edges_to_predict.py ${EDGE_TO_LEARN} "output/${PATH_TO_EXPE}/graph_test_gt.txt" "output/${PATH_TO_EXPE}/edges_to_predict.txt" 

# sort output/${PATH_TO_EXPE}/graph_test_gt.txt > output/${PATH_TO_EXPE}/graph_test_gt_s.txt 
# sort output/${PATH_TO_EXPE}/graph_test.txt > output/${PATH_TO_EXPE}/graph_test_s.txt 
# comm -23 output/${PATH_TO_EXPE}/graph_test_gt_s.txt output/${PATH_TO_EXPE}/graph_test_s.txt > output/${PATH_TO_EXPE}/edges_to_predict.txt
# rm output/${PATH_TO_EXPE}/graph_test_gt_s.txt output/${PATH_TO_EXPE}/graph_test_s.txt 

# Remove duplicates
sort -u "output/${PATH_TO_EXPE}/ground_truth_dup.txt" > "output/${PATH_TO_EXPE}/ground_truth.txt"
sort -u "output/${PATH_TO_EXPE}/graph_learning_dup.txt" > "output/${PATH_TO_EXPE}/graph_learning_with_validation_and_test.txt"
rm "output/${PATH_TO_EXPE}/ground_truth_dup.txt"
rm "output/${PATH_TO_EXPE}/graph_learning_dup.txt"


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


if [ $# -ne 5 ] ; then
  echo "Usage: $0 <path_to_scenario> <number_of_persons> <number_of_learning_edges_to_remove> <type_of_edge_to_remove> <validation_ratio>" 1>&2
  exit 2
fi

./generate_data.sh ${NAME_OF_SCENARIO} ${NUMBER_OF_PERSONS} ${NUMBER_OF_ABLATION} ${EDGE_TO_LEARN} ${RATIO_VALID}

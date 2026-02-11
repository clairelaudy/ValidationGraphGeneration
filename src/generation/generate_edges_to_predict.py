#!/usr/bin/env -S uv run --script
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
#    "neo4j_utils",
#    "faker",
#    "petname",
#    "ontoweaver",
# ]
# ///

import argparse
from itertools import combinations  

# Generation of a file containing the edges to predicts, given a test graph file and a type of edge to predict
# Takes:
#   - the type of the relation to be predicted;
#   - the path to the initial test graph file
#   - the path to the new test file.
# Produces:
#   - a tsv test file for BioPathNet with the edges that should be queried for prediction by BPN.

def generate_all_combinations(relation, initial_file, output_file):
    output_lines = []

    nodes = set()
    with open(initial_file, 'r') as fin:
        with open(output_file, 'w') as fout:
            input_lines = fin.readlines()
            for line in input_lines:
                s, r, t = line.split()
                nodes.add(s)
                nodes.add(t)

            combinations = list(combinations(list(nodes), 2))

            for c in combinations:
                (f,s) = c
                fout.write('\t'.join([f, relation, s]))
                fout.write("\n")

if __name__ == "__main__":

    parser= argparse.ArgumentParser()
    parser.add_argument("relation")
    parser.add_argument("initial_file")
    parser.add_argument("output_file")
    asked = parser.parse_args()

    generate_all_combinations(asked.relation, asked.input_file, asked.output_file)

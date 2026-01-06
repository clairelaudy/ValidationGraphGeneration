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
import string
import random

# Ablation of data to test BioPathNet.
# Takes:
#   - the type of the relation to be deleted from the training data;
#   - the number of edges to delete from the initial network;
#   - a (path to) tsv file representing a sematic network that can be given as input to BioPathNet;
#   - the path to the output new training file
#   - the path to the new test file.
# Produces:
#   - a new tsv training file for BioPathNet with some of the edges from the initial network removed;
#   - a tsv test file for BioPathNet with the edges that were removed from the inital network.


if __name__ == "__main__":

    parser= argparse.ArgumentParser()
    parser.add_argument("relation_to_delete")
    parser.add_argument("nb_of_deletion")
    parser.add_argument("initial_file")
    parser.add_argument("output_file")
    asked = parser.parse_args()
    
    nb_del = int(asked.nb_of_deletion)
    test_lines = []
    output_lines = []
    
    with open(asked.initial_file, 'r') as fin:
        with open(asked.output_file, 'w') as fout:
            input_lines = fin.readlines()
            random.shuffle(input_lines)

            index = 0
            while nb_del > 0 and index < len(input_lines):
                input = input_lines[index].strip().split()
                assert len(input)==3
                if asked.relation_to_delete in input[1]:
                    nb_del -= 1
                    test_lines.append(input_lines[index])
                else:
                    output_lines.append(input_lines[index])
                index += 1
            output_lines.extend(input_lines[index:])

            for line in output_lines:
                fout.write(f"{line}")

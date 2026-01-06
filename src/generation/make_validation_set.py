import argparse
import logging

# Construction of a validation set from an semantic graph and a type of edge to be predicted.
# Takes:
#  - the type of the relation to be deleted from the training data;
#  - the purcentage of data to be transfer to the validation set;
#  - a (path to) tsv file representing a sematic network that can be given as input to BioPathNet;
#  - the path to the new validation file
# Produces:
#  - a new tsv validation file for BioPathNet with some edges from the initial network file;
#  - an updated version of the tsv training file


if __name__ == "__main__":

    parser= argparse.ArgumentParser()
    parser.add_argument("relation_to_delete")
    parser.add_argument("ratio_valid")
    parser.add_argument("initial_train_file")
    parser.add_argument("output_valid_file")
    asked = parser.parse_args()

    logging.info(asked)
    
    ratio_valid = float(asked.ratio_valid)
    valid_lines = []
    output_lines = []
    
    with open(asked.initial_train_file, 'r') as finput:
        input_lines = finput.readlines()
        index = 0
        nb_edges = 0
        while index < len(input_lines):
            input = input_lines[index].strip().split()
            assert len(input)==3
            if asked.relation_to_delete in input[1]:
                nb_edges += 1
            index += 1

        nb_del = int(ratio_valid*nb_edges)
        logging.info(f"Number of edges for validation = %s", nb_del)
        
        index = 0
        while nb_del > 0 and index < len(input_lines):
            input = input_lines[index].strip().split()
            assert len(input)==3
            if asked.relation_to_delete in input[1]:
                nb_del -= 1
                valid_lines.append(input_lines[index])
            else:
                output_lines.append(input_lines[index])
            index += 1
        output_lines.extend(input_lines[index:])
        
    with open(asked.initial_train_file, 'w') as finput:
        with open(asked.output_valid_file, 'w') as fout:
            for line in output_lines:
                finput.write(f"{line}")
            for line in valid_lines:
                fout.write(f"{line}")


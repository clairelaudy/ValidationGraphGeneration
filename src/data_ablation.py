import argparse
import string

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
    parser.add_argument("initial_train_file")
    parser.add_argument("output_train_file")
    parser.add_argument("output_test_file")
    asked = parser.parse_args()
    
    nb_del = int(asked.nb_of_deletion)
    test_lines = []
    output_lines = []
    
    with open(asked.initial_train_file, 'r') as finput:
        with open(asked.output_train_file, 'w') as ftrain_out:
            with open(asked.output_test_file, 'w') as ftest:
                input_lines = finput.readlines()
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
                    ftrain_out.write(f"{line}")
                for line in test_lines:
                    ftest.write(f"{line}")

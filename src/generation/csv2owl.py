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

import sys
import argparse
import logging

import yaml
import pandas as pd

import biocypher
import ontoweaver

from pets_transformer import pets_transformer

def export_csv_2_owl(data_file, mapping_filename, biocypher_config, schema_config):

    logging.getLogger("ontoweaver").setLevel('INFO')

    # Load the data from the csv file with the ontoweaver mapping:
    filename_to_mapping = {data_file : mapping_filename}

    logging.info(f"Load CSV data from `{data_file}'")
    logging.info(f"With mapping from `{mapping_filename}'")

    ontoweaver.transformer.register(pets_transformer)

    nodes, edges = ontoweaver.extract(filename_to_mapping)
    bc_nodes, bc_edges = ontoweaver.ow2bc(nodes), ontoweaver.ow2bc(edges)

    # Detect potential duplicates to be fused:
    on_ID = ontoweaver.serialize.ID()
    congregater = ontoweaver.congregate.Nodes(on_ID)
    for n in congregater(bc_nodes):
        pass

    # Initialize Biocypher in order to have acces to the ontology:
    logging.info('Initialize Biocypher instance...')

    logging.getLogger("biocypher").setLevel('WARNING')
    bc = biocypher.BioCypher(
        biocypher_config_path = biocypher_config,
        schema_config_path = schema_config
    )

    # Define a custome fusion strategy:
    as_keys  = ontoweaver.merge.string.UseKey()
    as_sub_type = ontoweaver.merge.string.CommonSubType(bc._get_ontology())
    in_lists = ontoweaver.merge.dictry.Append()
    fuser = ontoweaver.fuse.Members(ontoweaver.base.Node,
            merge_ID    = as_keys,
            merge_label = as_sub_type,
            merge_prop  = in_lists,
        )

    # Fuse redundant nodes:
    fusioner = ontoweaver.fusion.Reduce(fuser)
    fusioned = fusioner(congregater)

    # Import OW triples into BC triples
    bc.write_nodes( ontoweaver.ow2bc(fusioned) )
    bc.write_edges( bc_edges )

    # Write BioCypher KG as a turtle ontology file:


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("data_filename")
    parser.add_argument("mapping_filename")
    parser.add_argument("biocypher_config")
    parser.add_argument("schema_config")
    args = parser.parse_args()
    print(args, file=sys.stderr)

    export_csv_2_owl(args.data_filename, args.mapping_filename, args.biocypher_config, args.schema_config)



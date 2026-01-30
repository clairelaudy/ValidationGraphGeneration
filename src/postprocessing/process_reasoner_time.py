#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#    "pandas<3.0.0,>=2.3.1",
#    "numpy<3.0.0,>=2.2.4",
#    "jsonargparse<5.0,>=4.39",
#    "matplotlib",
# ]
# ///

import argparse
import subprocess, sys
import pandas as pd
import matplotlib.pyplot as plt
from os import walk
from pprint import pprint
import re
import logging

def find_time(s):
    list_times = re.findall(r'[0-9]+', s)
    if len(list_times)<4:
        list_times.insert(0, 0)
    hours = int(list_times[0])
    minutes = int(list_times[1])
    seconds = int(list_times[2])

    time = 3600*hours+60*minutes+seconds
    return time


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("expe_dir")
    parser.add_argument("output_csv")
    args = parser.parse_args()

    cat_cmd = ["cat"]
    suppr_warnings_cmd = ["grep", "-v", "WARNING"]
    pipe_cmd = ["|"]
    tail_cmd = ["tail", "-n", "12"]
    expe_dir = args.expe_dir

    # data = pd.DataFrame()
    # data.columns = ['dataset id', 'scenario', 'nb of classes', 'nb of individuals', 'nb of nodes', 'reasoning time', 'data generation time']
    row_list = []

    files = []
    result = ""
    for (dirpath, dirnames, filenames) in walk(expe_dir):
        files.extend(filenames)
        break
    for f in files:
        try:
            if f.endswith(".log"):
                file = expe_dir+f
                try:
                    # single_command=tail_cmd+file
                    # print(single_command)
                    # result = subprocess.check_output(single_command)
                    # print(file)
                    # cat = subprocess.Popen(cat_cmd+file, check=True, stdout=subprocess.PIPE)
                    # print(cat.stdout)
                    # suppr_warnings = subprocess.Popen(suppr_warnings_cmd, stdin=cat.stdout, stdout=subprocess.PIPE)
                    # print(suppr_warnings.stdout)
                    # tail = subprocess.check_output(tail_cmd, stdin=suppr_warnings.stdout, stdout=subprocess.PIPE)
                    # print(tail)
                    # result, _ = tail.communicate()

                    result = subprocess.check_output(f"cat {file} | grep -v WARNING | tail -n 12", shell=True)
                    logging.info(result)
                    
                except subprocess.CalledProcessError as cpe:
                    result = cpe.output
                finally:
                    lines = []
                    data = {}
                    for line in result.splitlines():
                        lines.append(line.decode())
                    data['scenario'] = lines[0].partition("Scenario: ")[2]
                    nb_classes = int(lines[1].partition(" owl:Class: ")[2])
                    data['nb of classes'] = nb_classes
                    nb_indiv = int(lines[2].partition(" owl:NamedIndividual: ")[2])
                    data['nb of individuals'] = nb_indiv
                    data['nb of nodes'] = nb_classes+nb_indiv
                
                    data['reasoning time'] = find_time(lines[6])
                    data['data gegeration time'] = find_time(lines[9]) 
                
                    row_list.append(data)
        except:
            logging.warning(f"Couldn't read results from `{f}'")

    data = pd.DataFrame(row_list)
    #print("datadframe = ")
    pprint(data)
    data.to_csv("".join([args.expe_dir, "test.csv"]))
    data.plot(kind='scatter', x='nb of nodes', y='reasoning time')
    plt.show()
    plt.savefig("".join([args.expe_dir, "test.svg"]))


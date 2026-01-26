
A python project for creating synthetic data for egdge prediction in semantic knowledge graph.


# Installation

## In a container

You can look at the `test_size_ontology.def` Apptainer script, that is essentially
an executable description on how to install everything.


## Manual installation

The project is written in Python and uses uv.
You can install the necessary dependencies in a virtual environment like this:

```sh
git clone git@github.com:clairelaudy/ValidationGraphGeneration.git
uv sync
```

ROBOT (from OBO project) has to be installed. Follow the instruction given here:
http://robot.obolibrary.org/

To run the project, just run one of the script in `bin/`.
From those scripts, uv will create a virtual environment according to
`pyproject.toml` and activate it when running the project.


# Typical use

## Experiment on scalability

### Prepare

You first need to build a container holding the script:

```sh
cd some_experiment_dir
some/path/to/ValidationGraphGeneration/bin/build_container.sh
```

This will create a directory named after the date of build,
and then put an SIF container file in it, ready to be executed.
It also creates an archive of the source code
that's been last commited to the repository.


### Submit jobs

From the experiment directory, you can submit a series of jobs on
a SLURM HPC cluster:

```sh
cd some_experiment_dir
some/path/to/ValidationGraphGeneration/bin/submit_test_size_ontology.sh
```


### Quick look at results

The `*.log` files in the root directory contains potential errors,
you may look at them first.
They also contain the time taken by the jobs, which you can rapidly
look at:

```sh
module load gnuplot
cat tso_n*.log | grep user | grep -v "\s+0m" | cut -f2 | cut -dm -f1 | gnuplot -p -e 'set terminal dumb; plot "-"'
```

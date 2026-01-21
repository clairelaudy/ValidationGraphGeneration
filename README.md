
A python project for creating synthetic data for egdge prediction in semantic knowledge graph.


# Installation

The project is written in Python and uses uv.
You can install the necessary dependencies in a virtual environment like this:

```sh
git clone git@github.com:clairelaudy/ValidationGraphGeneration.git
uv sync
touch config/env.sh
```

ROBOT (from OBO project) has to be installed. Follow the instruction given here: 
http://robot.obolibrary.org/

To run the project, just run one of the script in `bin/`.
From those scripts, uv will create a virtual environment according to
`pyproject.toml` and activate it when running the project.

If you need to setup environment variables specifically for the project,
you can put them in `config/env.sh`. An example is given in `config/env-dist.sh`

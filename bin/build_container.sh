#!/usr/bin/bash

set -e
set -o pipefail

function git_rev()
{
    last_commit_date=$(git log -1 --format=%ci | awk '{print $1"_"$2;}' | sed "s/:/-/g")
    branch=$(git rev-parse --abbrev-ref HEAD)
    echo "${branch}_${last_commit_date}"
}

function git_archive()
{
    project=$(basename $(pwd))
    name=${project}_$(git_rev)
    branch=$(git rev-parse --abbrev-ref HEAD)
    git config tar.tar.xz.command "xz -c"
    git archive --prefix=$name/ --format tar.xz ${branch} > $name.tar.xz
    echo $name.tar.xz
}

if [[ ! -f "test_size_ontology.def" ]] ; then
    echo "ERROR: run this script from within the ValidationGraphGeneration repository." >&2
    exit 2
fi

# If the repository is not clean
# (i.e. there are uncommitted changes)
if ! git diff-index --quiet HEAD -- ; then
    echo "ERROR: this repository has uncommited changes, I would archive the last committed version. Please commit before running this script, or else you will not build what you expects." >&2
    exit 1
fi

ARCHIVE=$(git_archive .)

if command -v module ; then
    module load apptainer
fi
# apptainer cache clean -f
apptainer build -F test_size_ontology__$(git_rev).sif test_size_ontology.def

echo "Archived code version in: $ARCHIVE" >&2


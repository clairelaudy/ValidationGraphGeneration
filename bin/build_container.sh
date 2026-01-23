#!/usr/bin/bash

set -e
set -o pipefail

function git_archive()
{
    last_commit_date=$(git log -1 --format=%ci | awk '{print $1"_"$2;}' | sed "s/:/-/g")
    project=$(basename $(pwd))
    branch=$(git rev-parse --abbrev-ref HEAD)
    name=${project}_${branch}_${last_commit_date}
    git config tar.tar.xz.command "xz -c"
    git archive --prefix=$name/ --format tar.xz ${branch} > $name.tar.xz
    echo $name.tar.xz
}

VGG=$(dirname $0)/..

CUR=$(pwd)
cd $VGG
ARCHIVE=$(git_archive $VGG)
mv $ARCHIVE $CUR
cd $CUR
echo "Archived code version in: $ARCHIVE"

if command -v module ; then
    module load apptainer
fi
apptainer cache clean -f
apptainer build -F test_ontology_size.sif $VGG/test_ontology_size.def


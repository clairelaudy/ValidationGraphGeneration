#!/bin/sh

EXPE=$(date -Iseconds | sed s/:/_/g)
if [[ -n "$1" ]] ; then
    EXPE=$1
fi
echo "Output directory: $EXPE" >&2
cd $EXPE

VGG_BIN=$(dirname $0)

for i in $(seq 10 1000 10000) ; do
  sbatch --job-name=tso$i $VGG_BIN/run_test_size_ontology.sh $i
done


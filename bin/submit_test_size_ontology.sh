#!/bin/sh
# To be ran from the experiment directory.
# Not from the source repository.

EXPE=$(date -Iseconds | sed s/:/_/g)
if [[ -n "$1" ]] ; then
    EXPE=$1
fi
mkdir -p $EXPE
echo "Output directory: $EXPE" >&2
cd $EXPE

VGG_BIN="../$(dirname $0)"

for i in $(seq 1000 50000 500000) ; do
    sbatch --job-name=tso_$i \
        --error=tso_n${i}_s%j.log \
        --output=tso_n${i}_s%j.out \
        $VGG_BIN/run_test_size_ontology.sh $i
done


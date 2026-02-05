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

sbatch --job-name=tso_$i \
    --error=tso_n${i}_s%j.log \
    --output=tso_n${i}_s%j.out \
    $VGG_BIN/run_generate_BPN_dataset.sh simplest 100 10 10 hasChild 2


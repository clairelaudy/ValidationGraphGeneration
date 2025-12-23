#!/bin/sh
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
# ]
# ///


set -e

EXPE=experiments/$(date -Iseconds|sed "s/:/_/g")
mkdir -p $EXPE

cd $EXPE
git clone ../.. .

export PYTHONPATH="$PYTHONPATH:$HOME/work/projects/biocypher/:$HOME/work/projects/ontoweaver/"

uv sync

#Nombre de personnes primaires à générer dan sle fichier csv :
declare -a arr_nb_p=("100"
)

#Number of edge to erase from the complete skg:
declare -a arr_ablation=("1"
"10"
)

#Ratio of validation data for the learning phase:
declare -a arr_ratio_valid=("0.25"
)


for p in "${arr_nb_p[@]}"
do

  echo "** Generate CSV data" 1>&2
  uv run src/generate_full_data.py ${p} "output/${p}/data.csv"
  
  for a in "${arr_ablation[@]}"
  do
    for v in "${arr_ratio_valid[@]}"
    do
      echo "*** Generate data for simplest scenario" 1>&2
      #Names of the different 'simple' scenarios:
      declare -a arr_scenarios=("simplest")
      
      for i in "${arr_scenarios[@]}"
      do
        #types of the edges to test with the scenario declarede above:
        declare -a arr_edge=("childOf"
        "parentOf"
        )
        for e in "${arr_edge[@]}"
        do
          ./prepare_expe.sh ${i} ${p} ${a} ${e} ${v}
        done
      done

      echo "*** Generate data for _has_role scenarios" 1>&2
      declare -a arr_scenarios=(
        "parent_has_role"
        "relatives_has_role"
#        "dataproperties_has_role"
      )
      for i in "${arr_scenarios[@]}"
      do
        declare -a arr_edge=("childOf"
                          "parentOf"
                          )
        for e in "${arr_edge[@]}"
        do
          ./prepare_expe.sh ${i} ${p} ${a} ${e} ${v}
        done
      done

      echo "*** Generate data for _class scenarios" 1>&2
      declare -a arr_scenarios=("parent_class"
        "relatives_class"
#        "dataproperties_class"
      )    
      for i in "${arr_scenarios[@]}"
      do
        declare -a arr_edge=("is_a"
                          )
        for e in "${arr_edge[@]}"
        do
          ./prepare_expe.sh ${i} ${p} ${a} ${e} ${v}
        done
      done

    done
  done
done


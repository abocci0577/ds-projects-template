#!/bin/bash --login

# create the conda environment
conda env create --prefix $ENV_PREFIX --file environment.yml --force
conda activate $ENV_PREFIX
. postBuild

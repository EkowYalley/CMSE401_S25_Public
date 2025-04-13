#!/bin/bash 

#SBATCH -N 3

#SBATCH --mem=5GB

mpirun ./run-demo.sh



scontrol show job $GalaxSee 

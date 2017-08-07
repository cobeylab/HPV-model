#!/bin/bash


#SBATCH --job-name=d051
#SBATCH --output=d051.txt
#SBATCH --error=d051.txt 
#SBATCH --time=36:00:00
#SBATCH --array=1-100
#SBATCH --ntasks=1
#SBATCH --partition=broadwl
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=3000


Rscript experiment_profile_d0.R $SLURM_ARRAY_TASK_ID 

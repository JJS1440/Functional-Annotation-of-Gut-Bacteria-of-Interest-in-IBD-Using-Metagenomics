#!/bin/bash
#SBATCH --job-name=list
#SBATCH --output=list%j.out
#SBATCH --error=list%j.err
#SBATCH --ntasks=1

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

python list_of_files_2_decompress_processer.py
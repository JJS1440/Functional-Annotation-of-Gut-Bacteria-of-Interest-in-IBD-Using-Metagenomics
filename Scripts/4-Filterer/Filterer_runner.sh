#!/bin/bash
#SBATCH --job-name=S4
#SBATCH --output=S4.out
#SBATCH --error=S4.err
#SBATCH --cpus-per-task=23

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

echo "Starting script at: $(date)"

python3 Filterer.py

echo "Script finished at: $(date)"


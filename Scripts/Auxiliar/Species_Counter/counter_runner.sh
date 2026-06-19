#!/bin/bash
#SBATCH --job-name=species_matrix
#SBATCH --output=species_matrix_%j.out
#SBATCH --error=species_matrix_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=28

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
#export PATH=$PATH:/aplic/anaconda/2024.02/bin
source activate jaume_env

ulimit -s unlimited

echo "Starting script at: $(date)"

python3 counter.py

echo "Script finished at: $(date)"
#!/bin/bash
#SBATCH --job-name=go_terms
#SBATCH --output=go_terms.out
#SBATCH --error=go_terms.err
#SBATCH --cpus-per-task=1
#SBATCH --partition=irbio01


. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

echo "Starting script at: $(date)"

python Go_terms_count.py

echo "Script finished at: $(date)"
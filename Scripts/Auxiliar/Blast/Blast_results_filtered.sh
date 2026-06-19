#!/bin/bash
#SBATCH --job-name=blast_filter
#SBATCH --output=blast_filter.out
#SBATCH --error=blast_filter.err
#SBATCH --cpus-per-task=22


. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

echo "Starting script at: $(date)"

python3 Blast_results_filtered.py

echo "Script finished at: $(date)"
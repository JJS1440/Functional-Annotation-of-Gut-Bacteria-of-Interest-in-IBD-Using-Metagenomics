#!/bin/bash
#SBATCH --job-name=gene_finder_info
#SBATCH --output=gene_finder_info.out
#SBATCH --error=gene_finder_info.err
#SBATCH --cpus-per-task=1


. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

echo "Starting script at: $(date)"

python3 gene_counts_info.py

echo "Script finished at: $(date)"
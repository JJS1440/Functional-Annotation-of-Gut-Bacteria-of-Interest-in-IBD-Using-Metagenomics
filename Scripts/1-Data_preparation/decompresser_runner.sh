#!/bin/bash
#SBATCH --job-name=decompression
#SBATCH --output=decompression_output_%j.out
#SBATCH --error=decompression_error_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=14
#SBATCH --partition=irbio01

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

python3 /home/BITamonleon/JaumeJurado/Chron/Scripts/Run/Decompresser.py
#!/bin/bash
#SBATCH --job-name=db_creation
#SBATCH --output=db_creation.out
#SBATCH --error=db_creation.err
#SBATCH --cpus-per-task=1


. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

echo "Starting script at: $(date)"

cur_path="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Blast/Database"

cd $cur_path || exit 1

makeblastdb \
  -in uniprot_sprot.fasta \
  -dbtype prot \
  -out uniprot_db \
  -parse_seqids

echo "Script finished at: $(date)"
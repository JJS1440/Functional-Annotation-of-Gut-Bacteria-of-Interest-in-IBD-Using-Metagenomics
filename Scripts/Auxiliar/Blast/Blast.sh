#!/bin/bash
#SBATCH --job-name=blast
#SBATCH --output=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Blast/Results/logs/blast%j.out
#SBATCH --error=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Blast/Results/logs/blast%j.err
#SBATCH --cpus-per-task=4
#SBATCH --partition=irbio01
#SBATCH --array=0-21%11


. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

echo "Starting script at: $(date)"

db="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Blast/Database/uniprot_db"
genes="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Genes_identification/Genes_fastas"

mapfile -t fasta_files < <(find "$genes" -type f -name "*.fasta" | sort)

current_fasta="${fasta_files[$SLURM_ARRAY_TASK_ID]}"

id=$(basename "$current_fasta" | sed 's/_genes\.fasta//')

echo "$id"

blastx \
  -query "$current_fasta" \
  -db "$db" \
  -out "blast_${id}.txt" \
  -outfmt 6 \
  -evalue 1e-5 \
  -num_threads "$SLURM_CPUS_PER_TASK"

echo "Script finished at: $(date)"
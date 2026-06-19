#!/bin/bash
#SBATCH --job-name=BWA
#SBATCH --output=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/BWA/log/Index/BWA_Index_%j.out
#SBATCH --error=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/BWA/log/Index/BWA_Index_%j.err
#SBATCH --cpus-per-task=1
#SBATCH --partition=irbio01
#SBATCH --array=0-22

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

INPUT_DIR_REF="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Genome_retriver/Ref_genomes"
OUTPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/BWA/Index"

FILES=($(find "$INPUT_DIR_REF" -name "*.fasta" | sort))

echo "$SLURM_ARRAY_TASK_ID"

for f in "${FILES[@]}"; do
    echo "$f"
done

file="${FILES[$SLURM_ARRAY_TASK_ID]}"

cp "$file" "$OUTPUT_DIR"

echo "copying $file"

base=$(basename "$file" .fasta)

file_bwa="$OUTPUT_DIR/$base.fasta"

bwa index "$file_bwa"

echo "Indexing $file_bwa"

echo "Finished"
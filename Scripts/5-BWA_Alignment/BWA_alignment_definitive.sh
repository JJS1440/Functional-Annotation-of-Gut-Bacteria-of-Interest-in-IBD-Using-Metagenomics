#!/bin/bash
#SBATCH --job-name=BWA
#SBATCH --output=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/BWA/log/Alignment/BWA_Index_%j.out
#SBATCH --error=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/BWA/log/Alignment/BWA_Index_%j.err
#SBATCH --cpus-per-task=1
#SBATCH --partition=irbio01
#SBATCH --array=0-21

OUTPUT_PATH="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/BWA/Alignment"
INDEX_FILES="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/BWA/Index"
REF_GENOME_PATH="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Genome_retriver/Ref_genomes"

FILES_2_ALIGN="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Filterer/Step4"

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

FILES=($(find "$FILES_2_ALIGN" -name "*.fastq"))

FILES_NAMES=($(find "$FILES_2_ALIGN" -name "*.fastq" -printf "%f\n"))


FIRST_PARTS=()

for f in "${FILES_NAMES[@]}"; do
    IFS='_.'
    read -ra PARTS <<< "$f"
    IFS=' '

    ids+=("${PARTS[0]}")
done

mapfile -t unique_ids < <(printf "%s\n" "${ids[@]}" | sort -u)

echo "${unique_ids[$SLURM_ARRAY_TASK_ID]}"

reference="${INDEX_FILES}/${unique_ids[$SLURM_ARRAY_TASK_ID]}.fasta"

echo "$reference"

# Paired healthy
paired1="$FILES_2_ALIGN/${unique_ids[$SLURM_ARRAY_TASK_ID]}_healthy_R1_paired.fastq"
paired2="$FILES_2_ALIGN/${unique_ids[$SLURM_ARRAY_TASK_ID]}_healthy_R2_paired.fastq"
output="$OUTPUT_PATH/${unique_ids[$SLURM_ARRAY_TASK_ID]}_healthy_paired_alignment.sam"

bwa mem "$reference" "$paired1" "$paired2" > "$output"

# Paired ill
paired1="$FILES_2_ALIGN/${unique_ids[$SLURM_ARRAY_TASK_ID]}_ill_R1_paired.fastq"
paired2="$FILES_2_ALIGN/${unique_ids[$SLURM_ARRAY_TASK_ID]}_ill_R2_paired.fastq"
output="$OUTPUT_PATH/${unique_ids[$SLURM_ARRAY_TASK_ID]}_ill_paired_alignment.sam"

bwa mem "$reference" "$paired1" "$paired2" > "$output"

# Unpaired healthy
unpaired="$FILES_2_ALIGN/${unique_ids[$SLURM_ARRAY_TASK_ID]}_healthy_unpaired.fastq"
output="$OUTPUT_PATH/${unique_ids[$SLURM_ARRAY_TASK_ID]}_healthy_unpaired_alignment.sam"

bwa mem "$reference" "$unpaired" > "$output"

# Unpaired ill
unpaired="$FILES_2_ALIGN/${unique_ids[$SLURM_ARRAY_TASK_ID]}_ill_unpaired.fastq"
output="$OUTPUT_PATH/${unique_ids[$SLURM_ARRAY_TASK_ID]}_ill_unpaired_alignment.sam"

bwa mem "$reference" "$unpaired" > "$output"
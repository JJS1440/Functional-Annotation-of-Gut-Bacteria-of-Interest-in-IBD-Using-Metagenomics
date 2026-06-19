#!/bin/bash
#SBATCH --job-name=trimming
#SBATCH --output=/home/BITamonleon/JaumeJurado/Chron/Data/Outputs/Quality_Control/Trimmomatic/log/trimming_output_%j.out
#SBATCH --error=/home/BITamonleon/JaumeJurado/Chron/Data/Outputs/Quality_Control/Trimmomatic/log/trimming_error_%j.err
#SBATCH --cpus-per-task=3
#SBATCH --partition=irbio01
#SBATCH --array=0-27%14

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

INPUT_DIR="/home/BITamonleon/JaumeJurado/Chron/Data/Sequences/Decompressed"
OUTPUT_DIR="/home/BITamonleon/JaumeJurado/Chron/Data/Outputs/Quality_Control/Trimmomatic/"
ADAPTERS="/home/BITamonleon/JaumeJurado/Chron/Data/adapters.fa"

FILES=($(find "$INPUT_DIR" -name "*_R1_001.fastq"))
SAMPLE=${FILES[$SLURM_ARRAY_TASK_ID]}

R1=$SAMPLE
R2=${R1/_R1_001.fastq/_R2_001.fastq}

echo "Archivos encontrados:"
echo "Sample: $SAMPLE"
echo "R1: $R1"
echo "R2: $R2"

TRIMMED_R1="${OUTPUT_DIR}/$(basename ${R1/.fastq/_paired.fastq})"
TRIMMED_R2="${OUTPUT_DIR}/$(basename ${R2/.fastq/_paired.fastq})"
UNPAIRED_R1="${OUTPUT_DIR}/$(basename ${R1/.fastq/_unpaired.fastq})"
UNPAIRED_R2="${OUTPUT_DIR}/$(basename ${R2/.fastq/_unpaired.fastq})"

echo "Paired_R1: $TRIMMED_R1"
echo "Paired_R2: $TRIMMED_R2"
echo "Unpaired_R1: $UNPAIRED_R1"
echo "Unpaired_R2: $UNPAIRED_R2"

# Trimming command
trimmomatic PE -threads $SLURM_CPUS_PER_TASK \
    $R1 $R2 \
    $TRIMMED_R1 $UNPAIRED_R1 \
    $TRIMMED_R2 $UNPAIRED_R2 \
    ILLUMINACLIP:$ADAPTERS:2:30:10 \
    LEADING:3 TRAILING:3 SLIDINGWINDOW:4:20 MINLEN:36

echo "Process Finished"
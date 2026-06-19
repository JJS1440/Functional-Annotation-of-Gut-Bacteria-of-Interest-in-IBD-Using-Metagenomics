#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --output=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Quality_Control/Fast_QC_2/log/fastqc_output_%j.out
#SBATCH --error=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Quality_Control/Fast_QC_2/log/fastqc_error_%j.err
#SBATCH --cpus-per-task=1
#SBATCH --partition=irbio01
#SBATCH --array=0-111%40

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

#OUTPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Quality_Control/Fast_QC/"
OUTPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Quality_Control/Fast_QC_2/"
#INPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Sequences/Decompressed"
INPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Quality_Control/Trimmomatic/"

FILES=($(find "$INPUT_DIR" -name "*.fastq"))

FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

echo "Processing: $FILE"

fastqc -o $OUTPUT_DIR $FILE
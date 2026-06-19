#!/bin/bash
#SBATCH --job-name=multiqc
#SBATCH --output=multiqc_output.out
#SBATCH --error=multiqc_error.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=irbio01

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

#INPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Quality_Control/Fast_QC/"
#OUTPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Quality_Control/Multi_QC/"
INPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Quality_Control/Fast_QC_2/"
OUTPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Quality_Control/Multi_QC_2/"

if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

multiqc -o "$OUTPUT_DIR" "$INPUT_DIR" &> "$OUTPUT_DIR/log/multiqc_run.log"
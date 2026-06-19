#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --output=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Kraken_analysis/logs/kraken_analysis_%j.out
#SBATCH --error=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Kraken_analysis/logs/kraken_analysis_%j.err
#SBATCH --cpus-per-task=5
#SBATCH --partition=irbio01
#SBATCH --array=0-27%7
#SBATCH --nodelist=node3
#SBATCH --mem=105G

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

OUTPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Kraken_analysis"
REPORT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Kraken_analysis/Reports"
INPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Quality_Control/Trimmomatic"
DB_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Kraken_db"

if [ -d "$OUTPUT_DIR" ]; then
    echo "The directory $OUTPUT_DIR already exists."
else
    echo "The directory $OUTPUT_DIR does not exist. Creating..."
    mkdir -p "$OUTPUT_DIR"
    echo "The directory $OUTPUT_DIR has been created."
fi

if [ -d "$REPORT_DIR" ]; then
    echo "The directory $REPORT_DIR already exists."
else
    echo "The directory $REPORT_DIR does not exist. Creating..."
    mkdir -p "$REPORT_DIR"
    echo "The directory $REPORT_DIR has been created."
fi

paired_files=($(find "$INPUT_DIR" -maxdepth 1 -name "*R1_001_paired.fastq"))
unpaired_files=($(find "$INPUT_DIR" -maxdepth 1 -name "*R1_001_unpaired.fastq"))

paired_1=${paired_files[$SLURM_ARRAY_TASK_ID]}
paired_2="${paired_1/_R1_001_paired.fastq/_R2_001_paired.fastq}"

unpaired_1=${unpaired_files[$SLURM_ARRAY_TASK_ID]}
unpaired_2="${unpaired_1/_R1_001_unpaired.fastq/_R2_001_unpaired.fastq}"

echo ""

# -----------------------------------------------------------------------------------

echo "Processing paired:"
echo "$paired_1"
echo "$paired_2"

filename=$(basename "$paired_1")
base="${filename%_R1_001_paired.fastq}_paired_kraken2"
output_file="$OUTPUT_DIR/${base}.out"
report_file="$REPORT_DIR/${base}.report"

kraken2 \
    --db "$DB_DIR" \
    --threads $SLURM_CPUS_PER_TASK \
    --paired "$paired_1" "$paired_2" \
    --output "$output_file" \
    --report "$report_file" \
    --use-names

echo "Completed"
echo ""

# -----------------------------------------------------------------------------------

echo "Processing unpaired:"
echo "$unpaired_1"

filename=$(basename "$unpaired_1")
base="${filename%_unpaired.fastq}_unpaired_kraken2"
output_file="$OUTPUT_DIR/${base}.out"
report_file="$REPORT_DIR/${base}.report"

kraken2 \
    --db "$DB_DIR" \
    --threads $SLURM_CPUS_PER_TASK \
    --unpaired "$unpaired_1" \
    --output "$output_file" \
    --report "$report_file" \
    --use-names

echo "Completed"
echo ""
echo "Processing unpaired:"
echo "$unpaired_2"

filename=$(basename "$unpaired_2")
base="${filename%_unpaired.fastq}_unpaired_kraken2"
output_file="$OUTPUT_DIR/${base}.out"
report_file="$REPORT_DIR/${base}.report"

kraken2 \
    --db "$DB_DIR" \
    --threads $SLURM_CPUS_PER_TASK \
    --unpaired "$unpaired_2" \
    --output "$output_file" \
    --report "$report_file" \
    --use-names

echo "Completed"

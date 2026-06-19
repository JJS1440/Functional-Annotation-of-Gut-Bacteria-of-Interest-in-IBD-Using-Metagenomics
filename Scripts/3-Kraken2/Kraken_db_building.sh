#!/bin/bash
#SBATCH --job-name=database
#SBATCH --output=database_output_%j.out
#SBATCH --error=database_error_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
#export PATH=$PATH:/aplic/anaconda/2024.02/bin
source activate jaume_env

ulimit -s unlimited

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

OUTPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Kraken_db/"

# Checking if the directory exists, if not the script crates it
if [ -d "$OUTPUT_DIR" ]; then
    echo "The directory $OUTPUT_DIR already exists."
    echo "Proceeding with the script"
else
    echo "The directory $OUTPUT_DIR does not exist. Creating..."
    mkdir -p "$OUTPUT_DIR"
    echo "The directory $OUTPUT_DIR has been created."
fi

kraken2-build --download-taxonomy --db $OUTPUT_DIR

kraken2-build --download-library human --db $OUTPUT_DIR

kraken2-build --download-library bacteria --db $OUTPUT_DIR

kraken2-build --build --db $OUTPUT_DIR --threads $THREADS

echo "Process finished"

: << 'comment'
To execute script in background:
nohup sh ./Kraken_db_building.sh > Kraken_db_building_3.log 2>&1 &


SLURM:
#SBATCH --job-name=database
#SBATCH --output=database_output_%j.out
#SBATCH --error=database_error_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=irbio01
comment

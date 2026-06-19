#!/bin/bash
#SBATCH --job-name=copy_files
#SBATCH --output=copy_files_%j.out
#SBATCH --error=copy_files_%j.err
#SBATCH --ntasks=8

SOURCE_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Sequences/Compressed/BATCH2/"
DEST_DIR="/home/BITamonleon/Sequences/BATCH2/"

FILES=$(find "$SOURCE_DIR" -type f)
FILES_ARRAY=($FILES)
NUM_FILES=${#FILES_ARRAY[@]}

echo "Total number of files: $NUM_FILES" >> copy_files_${SLURM_JOB_ID}.out
echo "Starting copying process..." >> copy_files_${SLURM_JOB_ID}.out

for ((i=0; i<NUM_FILES; i+=8)); do
    echo "Ciclo $i - $((i+8))" >> copy_files_${SLURM_JOB_ID}.out
    for ((j=i; j<i+8 && j<NUM_FILES; j++)); do
        echo "Copiando: ${FILES_ARRAY[j]}" >> copy_files_${SLURM_JOB_ID}.out
        cp "${FILES_ARRAY[j]}" "$DEST_DIR" &
    done
    wait
done

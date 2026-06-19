#!/bin/bash
#SBATCH --job-name=taxid_retriever
#SBATCH --output=taxid_retriever.out
#SBATCH --error=taxid_retriever.err
#SBATCH --cpus-per-task=1

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

export TAXONKIT_DB="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Kraken_db/taxonomy"

OUTPUT_DIR="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Tax_id_retriver/"

if [ -d "$OUTPUT_DIR" ]; then
    echo "The directory $OUTPUT_DIR already exists."
    echo "Proceeding with the script"
else
    echo "The directory $OUTPUT_DIR does not exist. Creating..."
    mkdir -p "$OUTPUT_DIR"
    echo "The directory $OUTPUT_DIR has been created."
fi

OUTPUT_FILE="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Tax_id_retriver/tax_ids.txt"
INPUT_FILE="/home/BITamonleon/JaumeJurado/TFG/Data/Bacteria_names.txt"

> "$OUTPUT_FILE"

while IFS= read -r bacteria_name
do
    # Searching for tax id
    tax_id=$(echo "$bacteria_name" | taxonkit name2taxid --data-dir "$TAXONKIT_DB" --threads 1)

    # Checking if id found
    if [ -n "$tax_id" ]; then
        echo "$tax_id" >> "$OUTPUT_FILE"
    else
        echo " Not found Tax ID" >> "$OUTPUT_FILE"
    fi
done < "$INPUT_FILE"

echo "$tax_id[@]"

echo "Process finished"
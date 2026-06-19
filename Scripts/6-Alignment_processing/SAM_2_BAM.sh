#!/bin/bash
#SBATCH --job-name=SAM_2_BAM
#SBATCH --output=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/SAM_2_BAM/log/SAM_2_BAM_%j.out
#SBATCH --error=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/SAM_2_BAM/log/SAM_2_BAM_%j.err
#SBATCH --partition=irbio01
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

echo "Starting script at: $(date)"

alignment_path="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/BWA/Alignment/"
BAM_path="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/SAM_2_BAM/1-BAM"
Ordering_path="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/SAM_2_BAM/2-Ordered"
Indexing_path="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/SAM_2_BAM/3-Indexed"

mkdir -p "$BAM_path"
mkdir -p "$Ordering_path"
mkdir -p "$Indexing_path"

# Converting to BAM

echo ""
echo "##################################"
echo "#        Conversion to BAM       #"
echo "##################################"
echo ""

FILES_NAMES=($(find "$alignment_path" -name "*.sam" -printf "%f\n" | sort))

for f in "${FILES_NAMES[@]}"; do

    base="${f%.sam}"
    echo "Converting: $f -> ${base}.bam"
    samtools view -Sb "$alignment_path/$f" > "${BAM_path}/${base}.bam"
done

echo ""
echo "Converting to BAM finished at $(date)"
echo ""

# Ordering the files

echo ""
echo "##################################"
echo "#            Ordering            #"
echo "##################################"
echo ""

FILES_NAMES=($(find "$BAM_path" -name "*.bam" -printf "%f\n" | sort))

for f in "${FILES_NAMES[@]}"; do

    base="${f%_alignment.bam}"

    echo "Ordering: $f -> ${base}_ordered.bam"

    samtools sort "$BAM_path/$f" -o "${Ordering_path}/${base}_ordered.bam"
    
done

echo ""
echo "Ordering finished at $(date)"
echo ""

# Indexing

echo ""
echo "##################################"
echo "#            Indexing            #"
echo "##################################"
echo ""

FILES_NAMES=($(find "$Ordering_path" -name "*.bam" -printf "%f\n" | sort))

for f in "${FILES_NAMES[@]}"; do

    base="${f%_ordered.bam}"

    echo "Indexing: $f -> ${base}.bam"

    samtools index "$Ordering_path/$f"
    
    mv "${Ordering_path}/${f}.bai" "${Indexing_path}/${f}.bai"

done

echo ""
echo "Script finished at: $(date)"
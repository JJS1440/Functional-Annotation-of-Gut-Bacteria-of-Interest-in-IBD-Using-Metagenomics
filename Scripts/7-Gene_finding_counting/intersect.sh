#!/bin/bash
#SBATCH --job-name=intersect
#SBATCH --output=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Alignment_processing/Intersect/log/intersect_%j.out
#SBATCH --error=/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Alignment_processing/Intersect/log/intersect_%j.err
#SBATCH --cpus-per-task=1
#SBATCH --partition=irbio01
#SBATCH --array=0-21

. /etc/profile

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

module load anaconda/2024.02
source activate jaume_env

ulimit -s unlimited

ordered_path="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Alignment_processing/SAM_2_BAM/2-Ordered"
intersect_path="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Alignment_processing/Intersect"
ref_path="/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Genome_retriver/Ann_genomes"

mkdir -p "$intersect_path"

ids=("495" "732" "851" "860" "1019" "1308" "1352" "1655" "1685" "1747" "28026" "28251" "28449" "33039" "39491" "43675" "46125" "187327" "712122" "712624" "1796613" "1867719")
id="${ids[$SLURM_ARRAY_TASK_ID]}"

echo "Species id: $id"
echo ""

reference="${ref_path}/${id}.gff"

echo "Processing healthy"
echo ""

h_paired="${ordered_path}/${id}_healthy_paired_ordered.bam"
h_unpaired="${ordered_path}/${id}_healthy_unpaired_ordered.bam"

h_out_paired="${intersect_path}/${id}_healthy_paired_intersect.bed"
h_out_unpaired=${intersect_path}/${id}_healthy_unpaired_intersect.bed

bedtools intersect -a "$h_paired" -b "$reference" -wa -wb -bed > "$h_out_paired"
bedtools intersect -a "$h_unpaired" -b "$reference" -wa -wb -bed > "$h_out_unpaired"

echo "Processing ill"
echo ""

i_paired="${ordered_path}/${id}_ill_paired_ordered.bam"
i_unpaired="${ordered_path}/${id}_ill_unpaired_ordered.bam"

i_out_paired="${intersect_path}/${id}_ill_paired_intersect.bed"
i_out_unpaired=${intersect_path}/${id}_ill_unpaired_intersect.bed

bedtools intersect -a "$i_paired" -b "$reference" -wa -wb -bed > "$i_out_paired"
bedtools intersect -a "$i_unpaired" -b "$reference" -wa -wb -bed > "$i_out_unpaired"

echo "Script finished"
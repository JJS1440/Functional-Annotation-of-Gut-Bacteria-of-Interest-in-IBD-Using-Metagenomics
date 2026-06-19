import os
import pandas as pd
from joblib import Parallel, delayed
from collections import defaultdict

output_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Taxa_identification"
input_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Kraken_analysis"

os.makedirs(output_path, exist_ok=True)

# Función para agrupar el nombre del sample base
def extract_sample_name(filename):
    for suffix in ["_paired", "_R1_001_unpaired", "_R2_001_unpaired"]:
        if filename.endswith(suffix + "_kraken2.out"):
            return filename.replace(suffix + "_kraken2.out", "")
    return filename.replace("_kraken2.out", "")

def count_species_in_file(file_path):

    counts = defaultdict(int)

    with open(file_path, "r") as file:

        for line in file:
            split_line = line.split("\t")

            if split_line[0] == "C":
                species = split_line[2]
                counts[species] += 1

    return extract_sample_name(os.path.basename(file_path)), counts

file_list = [
    os.path.join(input_path, f)
    for f in os.listdir(input_path)
    if f.endswith("kraken2.out")
]

print(f"Archivos encontrados: {len(file_list)}")
for f in file_list:
    print(f)

results = Parallel(n_jobs=28)(delayed(count_species_in_file)(f) for f in file_list)

merged_counts = defaultdict(lambda: defaultdict(int))

for sample_name, species_counts in results:
    for species, count in species_counts.items():
        merged_counts[sample_name][species] += count

df = pd.DataFrame.from_dict(merged_counts, orient="index").fillna(0).astype(int)
df.index.name = "Sample\Species"

df.to_csv(os.path.join(output_path, "species_matrix.csv"))

def species_counter_in_files(file_list):

    unique_species = set()

    for file_path in file_list:
        with open(file_path, "r") as file:
            for line in file:
                split_line = line.split("\t")
                if split_line[0] == "C":
                    specie = split_line[2]
                    unique_species.add(specie)

    return len(unique_species)

c = species_counter_in_files(file_list)
print(f'Number of species found in files: {c}')

df = pd.read_csv(os.path.join(output_path, "species_matrix.csv"))
num_columnas = df.shape[1]
print(f"Number of columns: {num_columnas}")
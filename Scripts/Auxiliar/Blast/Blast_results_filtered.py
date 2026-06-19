import pandas as pd
import os
from joblib import Parallel, delayed

def read_file(file_path):

    with open(file_path) as f:
        return f.read().splitlines()

def filter(blast_result):

    rows = []
    blast_res_list = []

    for line in blast_result:

        sep_info = line.split("\t")

        gene_id = sep_info[0]
        blast_res = sep_info[1]
        e_val = float(sep_info[-2])
        bit_score = float(sep_info[-1])

        if e_val <= 1e-10 and bit_score >= 80:
            rows.append((gene_id, blast_res, line))
            blast_res_list.append(blast_res)

    return rows, blast_res_list

def save_df(df, genes_list, output_path, id_species):

    output_file = os.path.join(output_path, f"{id_species}_blast_filtered.csv")

    df_out = pd.DataFrame(df, columns=["gene_id", "blast_res", "line"])
    df_out.to_csv(output_file, sep="\t", index=False)

    output_file = os.path.join(output_path, f"{id_species}_gene_list.txt")

    with open(output_file, "w") as f:
        for gene in genes_list:
            f.write(gene + "\n")

def log_writter(log_path, proc_id, msg):

    log_file = os.path.join(log_path, f'{proc_id}.log')

    with open(log_file, "a") as file:
        file.write(str(msg) + "\n")

def start(input_path, output_path, ids_species, proc_id, log_path):

    for id_species in ids_species[proc_id]:

        read_file_path = os.path.join(input_path, f'blast_{id_species}.txt')
        blast_result = read_file(read_file_path)
        log_writter(log_path, proc_id, f"Species id: {id_species} --> Blast results read successfully")

        df, gene_list = filter(blast_result)
        log_writter(log_path, proc_id, f"Species id: {id_species} --> Filtering completed")

        save_df(df, gene_list, output_path, id_species)
        log_writter(log_path, proc_id, f"Species id: {id_species} --> Finished saving dataframe")

input_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Blast/Results"
output_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Blast/Filtered_results"
log_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Blast/Filtered_results/logs"

os.makedirs(output_path, exist_ok=True)
os.makedirs(log_path, exist_ok=True)

species = [495, 732, 851, 860, 1019, 1308, 1352, 1655, 1685, 1747, 28026, 28251, 28449, 33039, 39491,
           43675, 46125, 187327, 712122, 712624, 1796613, 1867719]

n_threads = 22

ids_per_thread = [species[i::n_threads] for i in range(n_threads)]

processes_ids = list(range(0, 22))

Parallel(n_jobs=n_threads)(
    delayed(start)(input_path, output_path, ids_per_thread, proc_id, log_path) for proc_id in processes_ids
    )
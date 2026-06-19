import csv
import pandas as pd
import os

def filename_extraction(dataframe):
    count_EC = 0
    count_CU = 0
    count_Control = 0

    files = os.listdir("/home/BITamonleon/Sequences/Sequences/Compressed")

    list_files = dict()
    not_downloaded = []

    for i in range(len(dataframe)):

        cur_row = dataframe.iloc[i]

        if cur_row["oral_fecal"] == "fecal":

            if cur_row["DE_3M_6M_CO"] == "debut" or cur_row["DE_3M_6M_CO"] == "control":
                
                cur_file_id = cur_row["CODIGO_TUBO_GAIA"].split("_")
                status = cur_row["Tipo_enfermedad"]
                
                file_id = "_".join(cur_file_id[0:-2])

                if file_id not in list_files:

                    if status == "EC":
                        list_files[file_id] = status + f"_{count_EC}"
                        count_EC += 1
                    elif status == "CU":
                        list_files[file_id] = status + f"_{count_CU}"
                        count_CU += 1
                    elif status == "Control":
                        list_files[file_id] = status + f"_{count_Control}"
                        count_Control += 1

    return list_files

def get_sample(file_id, files_status):
    return files_status[file_id]

def count_genes(file_2_read, df, files_status):

    with open(file_2_read, "r") as file:

        for line in file:

            sep_line = line.strip().split("\t")
            sample_ = (sep_line[3].split("."))[0]
            sample = get_sample(sample_, files_status)

            info = sep_line[-1].split(";")

            if sep_line[14] == 'gene':

                id = (info[0].split("=")[-1]).replace("gene-", "")
                name = info[1].split("=")[-1]
                
                if id == name:
                    name = ""
                
                if sample not in df:
                    df[sample] = {}

                if sample in df:
                    
                    if id in df[sample]:
                        df[sample][id]["Count"] += 1
                    
                    else:
                        df[sample][id] = {"Name": name, "Count": 1, "Ontology":""}
                
            if sep_line[14] == "CDS":

                id = (info[1].split("=")[-1]).replace("gene-", "")
                ontology_info = "None"

                if sample in df and id in df[sample]:
                    if df[sample][id]["Ontology"] == "":
                        for item in info:

                            if item.startswith("Ontology_term="):
                                ontology_info=item.replace("Ontology_term=", "").replace(",", "/")
                            
                        df[sample][id]["Ontology"] = ontology_info

    return df

def save_csv(df, output_file):

    with open(output_file, "w", newline="") as f:
        writer = csv.writer(f)

        writer.writerow(["Sample", "GeneID", "Name", "Count", "Ontology"])

        for sample, genes in df.items():

            for gene_id, info in genes.items():

                writer.writerow([
                    sample,
                    gene_id,
                    info.get("Name", ""),
                    info.get("Count", 0),
                    info.get("Ontology", "")
                ])

def log_writter(log_path, msg):

    log_file = os.path.join(log_path, "gene_counts_info.log")

    with open(log_file, "a") as file:
        file.write(str(msg) + "\n")

def data_reader(file_):

    lines = []
    samples_ids = set()

    with open(file_, "r") as file:

        header = file.readline().strip().split(",")

        for line in file:

            lines.append(line.strip().split(","))
            
            sample = (line.strip().split(","))[0]
            samples_ids.add(sample)

    return header, lines, sorted(samples_ids)

def add_gene(df, gene):
    if gene not in df.index:
        df.loc[gene] = 0
    return df

def dataframe_gene_creator(header, lines, samples_ids):
    df = pd.DataFrame(columns=samples_ids)
    df.index.name = "genes"

    for line in lines:

        sample = line[0]
        gene = line[2]
        n = line[3]

        if line != "":

            if gene not in df.index:
                add_gene(df, gene)
                df.loc[gene, sample] = df.loc[gene, sample] + int(n)
            
            else:
                df.loc[gene, sample] = df.loc[gene, sample] + int(n)
    
    return df

def start(input_path, output_path, metadata_path, species):

    df = dict()

    metadata = pd.read_excel(metadata_path, sheet_name="metadata")
    files_status = filename_extraction(metadata)

    log_writter(log_path, "Dataframe creation:")

    for i in species:
        
        i = str(i)

        log_writter(log_path, f"\n\tSpecies: {i}")

        files = [f"{i}_healthy_paired_intersect.bed", 
                 f"{i}_healthy_unpaired_intersect.bed",
                 f"{i}_ill_paired_intersect.bed",
                 f"{i}_ill_unpaired_intersect.bed"]
        
        for j in files:

            df = count_genes(os.path.join(input_path, j), df, files_status)
            log_writter(log_path, f"\t\tData frame created for file {j}")

    output_file = os.path.join(output_path, f"counts_genes_info.csv")

    log_writter(log_path, f"Saving dataframe in {output_file}")
    save_csv(df, output_file)


    header, lines, samples_ids = data_reader("/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Genes_identification/Gene_count_everything/counts_genes_info.csv")
    df = dataframe_gene_creator(header, lines, samples_ids)
    df.to_csv("/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Genes_identification/Gene_count_everything/gene_counts.csv")

input_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Alignment_processing/Intersect"
output_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Genes_identification/Gene_count_everything"
log_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Genes_identification/Gene_count_everything/logs"
metadata_path = "/home/BITamonleon/JaumeJurado/TFG/Data/metadata.xlsx"

os.makedirs(output_path, exist_ok=True)
os.makedirs(log_path, exist_ok=True)

species = [495, 732, 851, 860, 1019, 1308, 1352, 1655, 1685, 1747, 28026, 28251, 28449, 33039, 39491,
           43675, 46125, 187327, 712122, 712624, 1796613, 1867719]

start(input_path, output_path, metadata_path, species)
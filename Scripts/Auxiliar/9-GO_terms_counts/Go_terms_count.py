import os
import csv

def read_csv(input_file, df, healthy_ill):

    with open(input_file, newline="") as f:
        reader = csv.reader(f)
        next(reader)

        for row in reader:

            go_terms = row[-1].split("/")
            counts = int(row[2])

            for term in go_terms:

                if term and term != "None":

                    if term not in df:
                        df[term] = {"count_ill": 0, "count_healthy": 0}

                    df[term][healthy_ill] += counts

    return df

def save_to_csv(df, output_file):

    with open(output_file, "w", newline="") as f:
        writer = csv.writer(f)

        writer.writerow(["GO_term", "count_ill", "count_healthy"])

        for term, counts in df.items():
            writer.writerow([
                term,
                counts["count_ill"],
                counts["count_healthy"]
                ])

def go_terms_separated(species, input_path, output_path):

    for specie_id in species:

        df = {}

        healthy_file = os.path.join(input_path, f"{specie_id}_healthy.csv")
        ill_file = os.path.join(input_path, f"{specie_id}_ill.csv")

        df = read_csv(healthy_file, df, "count_healthy")
        df = read_csv(ill_file, df, "count_ill")

        out_file = os.path.join(output_path, f"{specie_id}_go_term_count.csv")

        save_to_csv(df, out_file)

def go_terms(species, input_path, output_path):
    
    df = {}
    
    for specie_id in species:

        healthy_file = os.path.join(input_path, f"{specie_id}_healthy.csv")
        ill_file = os.path.join(input_path, f"{specie_id}_ill.csv")

        df = read_csv(healthy_file, df, "count_healthy")
        df = read_csv(ill_file, df, "count_ill")

    out_file = os.path.join(output_path, "total_go_term_count.csv")
    
    save_to_csv(df, out_file)


def start(species, input_path, output_path):

    go_terms_separated(species, input_path, output_path)
    go_terms(species, input_path, output_path)


species = [495, 732, 851, 860, 1019, 1308, 1352, 1655, 1685, 1747, 28026, 28251, 28449, 33039, 39491,
           43675, 46125, 187327, 712122, 712624, 1796613, 1867719]

input_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Genes_identification/Separated_counts"
output_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Go_terms/Results_by_species"

os.makedirs(output_path, exist_ok=True)

start(species, input_path, output_path)
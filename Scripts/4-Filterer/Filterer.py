import os
import re
from joblib import Parallel, delayed
import numpy as np
import pandas as pd

def process_file(file_path, tax_ids, output_file, process_state):

    if process_state == 1:
        if "paired" in file_path and not "unpaired" in file_path:
            name_of_file = (os.path.basename(file_path)).split("_")[:-2]
            name_of_file = "_".join(name_of_file)
        
        elif "unpaired" in file_path:
            name_of_file = (os.path.basename(file_path)).split("_")[:-4]
            name_of_file = "_".join(name_of_file)
    
    else: name_of_file = "Not required"

    # Open file for reading
    with open(file_path, 'r') as file:
        
        output_lines = []
        
        # Scan the file line by line
        for line in file:
            split_line = line.split("\t")

            split_line[1] = name_of_file + "." + split_line[1]
            
            # Filter only classified lines
            if split_line[0] == 'C':
                # Check if the tax_id is present in the corresponding column
                if any( " " + (str(tax_id) + ")") in split_line[2] for tax_id in tax_ids):

                    if process_state == 1:

                        # Extraction of the file name from the path
                        file_name = file_path.split("/")[-1]

                        # Separation of file identification parameters
                        f = re.split(r"[_\.]", file_name)

                        if f[-3] == "unpaired":

                            num = f[-5] # Extracting the pair from which the seq comes
                            pair_state = f[-3] # Extracting if it comes from paired or unpaired

                        else:
                            num = "NA"
                            pair_state = f[-3]
                        
                        line_ = "\t".join(split_line)

                        # Appending identification of the file into 2 new cols
                        output_lines.append(f"{line_.strip()}\t{pair_state}\t{num}\n")
                    
                    elif process_state == 2:
                        output_lines.append(line)
    
    # If we find any matching lines, write them to the output file
    if output_lines:
        # Use the 'with' block to ensure proper file handling
        with open(output_file, 'a') as out_file:
            out_file.writelines(output_lines)

def primary_filter(chunk, input_dir, tax_ids, output_dir, proc_id, process_state):

    for file in chunk:

        file_path = input_dir + "/" + file
        output_file = output_dir + "/" + "Primary_filter_" + str(proc_id) + ".txt"

        process_file(file_path, tax_ids, output_file, process_state)


# Path specification
input_directory = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Kraken_analysis"
output_directory_1 = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Filterer/Step1"
output_directory_2 = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Filterer/Step2"
output_directory_3 = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Filterer/Step3"
output_directory_4 = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Filterer/Step4"

# Output dir creation
os.makedirs(output_directory_1, exist_ok=True)
os.makedirs(output_directory_2, exist_ok=True)
os.makedirs(output_directory_3, exist_ok=True)
os.makedirs(output_directory_4, exist_ok=True)

# Ids we are interested in
'''
#For steps 1-3
tax_ids = [28449, 39491, 1019, 33039, 46125, 1747, 1685, 1308, 495, 1655, 851, 39492,
           1867719, 732, 187327, 28026, 860, 43675, 28251, 1352, 1796613, 712624, 712122]
'''

#For step 4
tax_ids = [28449, 39491, 1019, 33039, 46125, 1747, 1685, 1308, 495, 1655, 851,
           1867719, 732, 187327, 28026, 860, 43675, 28251, 1352, 1796613, 712624, 712122]

# Number of threads that will be used durin the primary filtering
n_threads = 14

# Getting the file names we want to scan
files_to_scan = [f for f in os.listdir(input_directory) if f.endswith('.out')]

# Dividing all the files to scan into 4 chunks
chunks = np.array_split(files_to_scan, n_threads)

print("Starting primary filtering", flush=True)

# Parallelization of the primary filter process
Parallel(n_jobs=n_threads)(
    delayed(primary_filter)(chunk, input_directory, tax_ids, output_directory_1, i, 1) for i, chunk in enumerate(chunks)
    )

print("Finished primary filtering", flush=True)



# ----------------------------------------------------------------------------------------------------------

def secondary_filter(files, input_dir, tax_ids, output_dir, process_state):

    for tax_id in tax_ids:

        tax_id = str(tax_id)

        print(f'Extracting {tax_id}')

        output_file = output_dir + "/" + tax_id + ".txt"

        for file in files:

            file_path = input_dir + "/" + file

            process_file(file_path, [tax_id], output_file, process_state)

# Redefine new input directory
input_directory = output_directory_1

# Number of threads that will be used durin the primary filtering
n_threads = 23

# Getting the file names we want to scan
files_to_scan = [f for f in os.listdir(input_directory)]

chunks_ids = np.array_split(tax_ids, n_threads)

print("Starting secondary filtering", flush=True)

Parallel(n_jobs=n_threads)(
    delayed(secondary_filter)(files_to_scan, input_directory, chunk_id, output_directory_2, 2) for chunk_id in chunks_ids
    )

print("Finished secondary filtering", flush=True)

# ----------------------------------------------------------------------------------------------------------

def seq_finder(file, input_path, output_path, seq_to_find, id_specie, file_type, paired_type, location_file):
    
    # Construct the path
    path = input_path + str(file)
    
    # Variable definition
    stop = False
    # Open file for reading
    with open(path, "r") as r_file:

        # Check if we want to stop reading
        while stop == False:
            # Read 4 lines at each time
            lines = [r_file.readline() for _ in range(4)]

            if not lines[0]:
                print("unable to find")
                break         

            # Get the header
            header = lines[0]
            split_head = header.lstrip('@').split()
            
            new_h = "@" + location_file + "." + split_head[0] + " " + split_head[1] + "\n"

            lines[0] = new_h

            # Checks if there is a match for a determined sequence
            if seq_to_find in split_head:
                #print("passed")

                if file_type == "unpaired":
                    output_file = output_path + "/" + id_specie + "_unpaired" + ".fastq"
                
                elif file_type == "paired":
                    output_file = output_path + "/" + id_specie + "_paired" + "_" + paired_type + ".fastq"

                # Open file to write the sequence that matches
                with open(output_file, "a") as file_a:
                    file_a.writelines(lines)
                
                break

def tertiary_filter(input_filtering_files, input_path, output_path, input_directory_2):

    for input_filtering_file in input_filtering_files:

        if (str(input_filtering_file) + ".txt") in os.listdir(input_directory):
            input_filtering_file = input_path + "/" + str(input_filtering_file) + ".txt"

            # We open the file from which we will extract the sequences names and file_names we are interested in
            with open(input_filtering_file, 'r') as file:
                # We read line by line
                for line in file:
                    # Split line
                    split_line = line.split("\t")

                    id_specie = os.path.splitext(os.path.basename(input_filtering_file))[0]

                    if id_specie:

                        seq_to_find = split_line[1].split(".")

                        # Check what type of sequence is it
                        if split_line[-2] == "paired":

                            file_name_1 = (seq_to_find[0] + "_R1_001_paired.fastq")
                            file_name_2 = (seq_to_find[0] + "_R2_001_paired.fastq")
                            #print(f'Paired: {seq_to_find}\n{split_line}\n{file_name_1}\n\n')
                            seq_finder(file_name_1, input_directory_2, output_path, seq_to_find[1], id_specie, split_line[-2], "R1", seq_to_find[0])
                            seq_finder(file_name_2, input_directory_2, output_path, seq_to_find[1], id_specie, split_line[-2], "R2", seq_to_find[0])
                            
                            
                        elif split_line[-2] == "unpaired":

                            file_name_1 = (seq_to_find[0].strip() + "_" + split_line[-1].strip("\n") + "_001_unpaired.fastq").strip()
                            #print(f'Unpaired: {seq_to_find}\n{split_line}\n{file_name_1}\n\n')
                            seq_finder(file_name_1, input_directory_2, output_path, seq_to_find[1], id_specie, split_line[-2], "", seq_to_find[0])


# Redefine new input directory
input_directory = output_directory_2
input_directory_2 = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Quality_Control/Trimmomatic/"

# Number of threads that will be used durin the primary filtering
n_threads = 21

# Getting the file names we want to scan
files_to_scan = [f for f in os.listdir(input_directory)]

chunks = np.array_split(tax_ids, n_threads)

print("Starting tertiary filtering", flush=True)

Parallel(n_jobs=n_threads)(
    delayed(tertiary_filter)(chunk, input_directory, output_directory_3, input_directory_2) for chunk in chunks
    )

print("Finished tertiary filtering", flush=True)

# -------------------------------------------------------

def ill_healty_files_extractor(metadata):
    ill_file_ids, healthy_file_ids = [], []

    for row in metadata.to_numpy():
        file = row[2]
        state = row[9]
        
        file_list = file.split("_")
        file_list = file_list[:-2]

        file_id = "_".join(file_list)

        if state == "Control":
            healthy_file_ids.append(file_id)
        else:
            ill_file_ids.append(file_id)
    
    return ill_file_ids, healthy_file_ids

def ill_healthy_separator(input_directory, output_directory, id, ill_file_ids):

    file_suffixes = ["_paired_R1.fastq", "_paired_R2.fastq", "_unpaired.fastq"]

    for suffix in file_suffixes:
        stop = False
        output_lines_healthy = []
        output_lines_ill = []
        file_to_read = input_directory + "/" + str(id) + suffix

        with open(file_to_read, "r") as file:
            while stop == False:
                lines = [file.readline().strip() for _ in range(4)]

                if not any(lines):
                    stop = True
                    break
                
                header = lines[0]
                sep_header = re.split(r"[ .]", header.lstrip("@"))
                
                lines = [line + '\n' for line in lines]

                if sep_header[0] in ill_file_ids:
                    output_lines_ill.extend(lines)
                else:
                    output_lines_healthy.extend(lines)
        
        if "unpaired" in suffix:
            healthy_file_path = output_directory + "/" + str(id) + "_healthy_unpaired.fastq"
            ill_file_path = output_directory + "/" + str(id) + "_ill_unpaired.fastq"
        else:
            if "1" in suffix:
                healthy_file_path = output_directory + "/" + str(id) + "_healthy_R1_paired.fastq"
                ill_file_path = output_directory + "/" + str(id) + "_ill_R1_paired.fastq"
            else:
                healthy_file_path = output_directory + "/" + str(id) + "_healthy_R2_paired.fastq"
                ill_file_path = output_directory + "/" + str(id) + "_ill_R2_paired.fastq"
        
        with open(healthy_file_path, "a") as file:
            file.writelines(output_lines_healthy)
        with open(ill_file_path, "a") as file:
            file.writelines(output_lines_ill)

def ill_healthy_separator_filter(input_directory, output_directory, ill_file_ids, chunk):
    for id in chunk:
        ill_healthy_separator(input_directory, output_directory, id, ill_file_ids)

input_directory = output_directory_3
metadata_path = "/home/BITamonleon/JaumeJurado/TFG/Data/metadata.xlsx"

metadata = pd.read_excel(metadata_path, sheet_name = "metadata")

n_threads = 22

chunks = np.array_split(tax_ids, n_threads)

ill_file_ids, healthy_file_ids = ill_healty_files_extractor(metadata)

print("Separating ill and healthy")

Parallel(n_jobs=n_threads)(
    delayed(ill_healthy_separator_filter)(input_directory, output_directory_4, ill_file_ids, chunk) for chunk in chunks
    )

print("Finished filter 4")

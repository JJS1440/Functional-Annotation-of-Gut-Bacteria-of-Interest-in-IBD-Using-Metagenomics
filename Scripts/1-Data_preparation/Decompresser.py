import gzip
import shutil
import os
from joblib import Parallel, delayed

def decompresser(gz_file, output_file):
    if os.path.exists(gz_file):
        with gzip.open(gz_file, 'rb') as f_in, open(output_file, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)
        return f'{output_file} decompressed successfully'
    else:
        return f'File {gz_file} not found, skipping.'

def chunk_list(lst, n_chunks):
    avg_chunk_size = len(lst) // n_chunks
    remainder = len(lst) % n_chunks
    chunks = []
    start = 0

    for i in range(n_chunks):
        end = start + avg_chunk_size + (1 if i < remainder else 0)
        chunks.append(lst[start:end])
        start = end

    return chunks

def parallelization(chunk, input_path, output_path):
    os.makedirs(output_path, exist_ok=True)
    logs = []

    for file in chunk:
        if not file.strip():
            continue

        file_parts = file.split("_")
        if len(file_parts) > 2:
            file_parts[-2] = 'R2'
            file_2 = '_'.join(file_parts)

            if file != file_2:
                gz_file_1 = os.path.join(input_path, file + ".fastq.gz")
                gz_file_2 = os.path.join(input_path, file_2 + ".fastq.gz")
                output_file_1 = os.path.join(output_path, file + ".fastq")
                output_file_2 = os.path.join(output_path, file_2 + ".fastq")

                logs.append(decompresser(gz_file_1, output_file_1))
                logs.append(decompresser(gz_file_2, output_file_2))
        else:
            logs.append(f'The file {file} has an unexpected format')

    return logs

file_names_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Files_2_decompres.txt"
log_file = "/home/BITamonleon/JaumeJurado/TFG/Scripts/Run/decompression.log"

with open(file_names_path, "r") as f:
    filenames = [name.strip() for line in f for name in line.split(",") if name.strip()]

n_jobs = 14
file_chunks = chunk_list(filenames, n_jobs)

input_path = "/home/BITamonleon/JaumeJurado/Chron/Data/Sequences/Compressed/"
output_path = "/home/BITamonleon/JaumeJurado/Chron/Data/Sequences/Decompressed/"

logs_list = Parallel(n_jobs=n_jobs)(
    delayed(parallelization)(chunk, input_path, output_path) for chunk in file_chunks
)

with open(log_file, "a") as log:
    for logs in logs_list:
        log.write("\n".join(logs) + "\n")
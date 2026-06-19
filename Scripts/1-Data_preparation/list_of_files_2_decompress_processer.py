import os
import pandas as pd

metadata_path = "/home/BITamonleon/JaumeJurado/TFG/Data/metadata.xlsx"

df = pd.read_excel(metadata_path, sheet_name="metadata")

def filename_extraction(dataframe):
    count = 0
    files = os.listdir("/home/BITamonleon/JaumeJurado/TFG/Data/Sequences/Compressed/")

    list_files = []
    not_downloaded = []

    for i in range(len(dataframe)):

        cur_row = dataframe.iloc[i]

        if cur_row["oral_fecal"] == "fecal":

            if cur_row["DE_3M_6M_CO"] == "debut" or cur_row["DE_3M_6M_CO"] == "control":
                
                cur_file_id_1 = cur_row["CODIGO_TUBO_GAIA"]

                cur_file_id_ = cur_file_id_1.split("_")
                cur_file_id_[-2] = "R2"

                cur_file_id_2 = '_'.join(cur_file_id_)

                if any(cur_file_id_1 in file_name for file_name in files):
                    list_files.append(cur_file_id_1)
                    count += 1
                elif any(cur_file_id_2 in file_name for file_name in files):
                    list_files.append(cur_file_id_2)
                    count += 1
                else:
                    not_downloaded.append(cur_file_id_1)
                    not_downloaded.append(cur_file_id_2)

    print(f'{count} files found')
    return list_files,not_downloaded, count

def saver(filenames, output_path, not_downloaded):

    with open(output_path, "w") as file:

        for i in filenames:
            file.write(i + ",")

        file.write(f'\nFiles that are not in the system but in the metadata:\n')

        for i in not_downloaded:
            file.write(i + f'\n')

print("Script started")

files_names, not_downloaded, count = filename_extraction(df)

output_path = "/home/BITamonleon/JaumeJurado/TFG/Data/Outputs/Files_2_decompres.txt"

saver(files_names, output_path, not_downloaded)

print("Script Finished")
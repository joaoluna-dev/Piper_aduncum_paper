import os
import json

dic = {}

def get_genes(name):
    counter = 0
    genes = []
    with open(name, "r") as file:
        molecule_file = name.split("_")
        molecule_name = molecule_file[0]
        #get target names
        molecule_file_names = file.readlines()
        for i in molecule_file_names:
            counter += 1
            if counter == 1:
                continue
            else:
                i_processed = i.strip("\n")
                genes.append(i_processed)
        dic[molecule_name] = genes

def run_analysis(dictionary):
    all_names = set()
    for i in dictionary:
        all_names.update(dictionary[i])
    return all_names

def write_file(names_set):
    with open("Intersection_target_names.csv", "w+") as intersec:
        intersec.write("Names \n")
        for name in names_set:
            intersec.write(f"{name} \n")
    print("csv file created.")

def write_json(dictionary):
    with open("Molecules_and_targets.json", "w+") as molecules_json:
        json.dump(dictionary, molecules_json)
    print("json file created.")

#------------------------------------------------------------------------------------#

files = os.listdir()
for filename in files:
    if ".csv" in filename and "target" not in filename:
        get_genes(filename)
names = run_analysis(dic)
write_file(names)
write_json(dic)
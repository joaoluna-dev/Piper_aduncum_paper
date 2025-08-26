import os
import json

dic = {}

def get_omim_genes(name):
    genes = []
    with open(name, "r") as omim_file:
        gene_names = omim_file.readlines()
        for line in gene_names:
            if "#" in line or "*" in line:
                elements_line = line.split("\t")
                full_gene_name = elements_line[1]
                splitted_gene_name = full_gene_name.split(" ")
                gene_symbol = splitted_gene_name[1]
                genes.append(gene_symbol)
            else:
                continue
        dic[name] = genes

def get_genecards_genes(name):
    genes = []
    counter = 0 #ignore header
    with open(name, "r") as gc_file:
        gene_names = gc_file.readlines()
        for line in gene_names:
            counter += 1
            if counter == 1:
                continue
            else:
                elements_line = line.split(',')
                genes_symbol = elements_line[0]
                processed_genes_symbol = genes_symbol.strip('"')
                genes.append(processed_genes_symbol)
        dic[name] = genes

def run_analysis(dictionary):
    kidney_terms = set()
    hepatic_terms = set()
    for i in dictionary:
        if "kidney" in i:
            kidney_terms.update(dictionary[i])
        elif "hepatic" in i:
            hepatic_terms.update(dictionary[i])
    return kidney_terms, hepatic_terms

def write_csv_file(kidney_set, hepatic_set):
    with open("All_names.csv", "w+") as csv_file:
        csv_file.write('"Kidney genes","Hepatic genes"\n')
        for kidney, hepatic in zip(kidney_set, hepatic_set):
            csv_file.write(f"{kidney},{hepatic}\n")
    print("csv file created.")

def write_json_file(dictionary):
    with open("OMIM_and_GeneCards_analysis.json", "w+") as genes_json:
        json.dump(dictionary, genes_json)
    print("json file created.")

#---------------------------------------------------------------------------------------------#

files = os.listdir()
for file in files:
    if "tsv" in file:
        get_omim_genes(file)
    elif "csv" in file:
        get_genecards_genes(file)
    elif file == "All_names.csv":
        continue
    else:
        continue
kidney_names, hepatic_names = run_analysis(dic)
write_csv_file(kidney_names, hepatic_names)
write_json_file(dic)
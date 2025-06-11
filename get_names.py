#Created by Neuroimmunogenetics Lab - iLIKA
#João Gabriel

def get_values(read_csv, threshold):
    counter = 0
    good_values = []
    for line in read_csv:
        counter += 1
        if counter == 1:
            continue
        else:
            element = line.split('","')
            if float(element[5]) > threshold:
                good_values.append(line)
    return good_values

def get_gene_names(filtered_values):
    gene_names = []
    for n in filtered_values:
        element = n.split('","')
        gene_names.append(element[1])
    return gene_names

def write_csv(list_name, mol):
    with open(f"{mol}_protein_threshold_names.csv", "w") as vals:
        vals.write("Names \n")
        for i in list_name:
            vals.write(i)
            vals.write("\n")
    print(".csv file created")

#----------------------------------------------------#

print("Welcome! Make sure the .csv file exported from SwissTargetPrediction is in the actual directory.")
mol_name = input("Insert the molecule name: ")
filename = input("Insert the .csv filename: ")
thrshld = int(input("Insert the threshold value of the analysis: "))
with open(filename, "r") as file:
    table_list = file.readlines()
values = get_values(table_list, thrshld)
names = get_gene_names(values)
write_csv(names, mol_name)
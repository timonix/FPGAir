import csv
import sys
from pathlib import Path
from decimal import Decimal
import datetime

BASE_DIR = Path(__file__).parent
variable_dict = {}
instruction_mapping = {}
ram_dict = {}
metadata_dict = {}
output_lines = []
frac_bits = 20
ram_bits = 32

def load_instruction_map(csv_file):
    
    mapping = {}
    with open(csv_file, newline='', encoding="utf-8") as f:
        reader = csv.reader(f)
        for row in reader:
            if len(row) < 2:
                continue
            binary, command = row[0].strip(), row[1].strip().upper()
            mapping[command] = binary
    return mapping

def str_value_to_bin(input_str : str):
    """ Returns a 32 bit binary string."""
    if "'" in input_str:    # If the input is an ASCII string
        ascii_str = input_str.replace("'", "")
        ascii_str = ascii_str.replace("\n", "")
        # ascii_str.strip()
        value = 0
        for ch in ascii_str:
            value = value << 8
            value = value | ord(ch)
        return format(value, "032b")
    
    value = float(input_str.strip())
    scaled_value = int(round(value * (1 << frac_bits)))
    mask = (1 << ram_bits) - 1
    fixed_val = scaled_value & mask
    return format(fixed_val, "032b")

def create_RAM_file(input_folder, ram_file):
    ram_lines = []
    address_counter = 0

    for input_file in input_folder.glob("*.txt"):
        with open(input_file, "r", encoding="utf-8") as f:
            lines = f.readlines()

        for line in lines:
            # if line.upper().startswith("LD $"):
            #     dummy, value = line.split('$')
            #     value_bin = str_value_to_bin(value)
            #     ram_dict[value_bin] = address_counter
            #     address_counter += 1
            #     ram_lines.append(value_bin)

            if line[0:4].upper().startswith("LD #"):
                dummy, value = line.split('#')
                if is_number(value.strip()):
                    value_bin = str_value_to_bin(value)
                    ram_dict[value_bin] = address_counter
                    address_counter += 1
                    ram_lines.append(value_bin)

            elif line[0:4].upper().startswith("LD '"):
                value = line[3:]
                value_bin = str_value_to_bin(value)
                ram_dict[value_bin] = address_counter
                address_counter += 1
                ram_lines.append(value_bin)

            elif line[0:1].startswith("#"):
                name, value = line.split('=')
                name = name.strip()[1:]
                # value_bin = format(int(value.strip()), "032b")
                value_bin = str_value_to_bin(value)
                
                if value_bin not in ram_lines:
                    ram_dict[value_bin] = address_counter
                    address_counter += 1
                    ram_lines.append(value_bin)

            # elif line.upper().startswith("DEFINE "):
            #     dummy, var_and_value_str = line.split('$')
                
            #     value_bin = str_value_to_bin(value)
            #     ram_dict[value_bin] = address_counter
            #     address_counter += 1
            #     ram_lines.append(value_bin)

    with open(ram_file, "w", encoding="utf-8") as f:
        f.write("\n".join(ram_lines))
            

def read_variables(input_folder):
    for input_file in input_folder.glob("*.txt"):
        with open(input_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
        
        for line in lines:
            if line.startswith("$"):
                name, value = line.split('=')
                name = name.strip()[1:]
                if value.strip().startswith("b"):
                    value_bin = value.strip()[1:]
                else:
                    value_bin = format(int(value.strip()), "08b")
                variable_dict[name] = value_bin
            
            elif line.startswith("#"):
                name, value = line.split('=')
                name = name.strip()[1:]
                # value_bin = format(int(value.strip()), "032b")
                value_bin = str_value_to_bin(value)
                variable_dict[name] = value_bin

                

def assemble(input_folder, output_file):
    for input_file in input_folder.glob("*.txt"):
        with open(input_file, "r", encoding="utf-8") as f:
            lines = f.readlines()
    
        for line in lines:
            line = line.strip()
            if not line or line.startswith("//"):  # skip empty/comment lines
                continue
            
            

            instruction_bin_str = instruction_assembler(line)
            if instruction_bin_str:
                output_lines.append(instruction_bin_str)
            # else:
            #     print(f"⚠️ Unknown incantation: {line}")
            #     output_lines.append("????????")  # placeholder

    with open(output_file, "w", encoding="utf-8") as f:
        f.write("\n".join(output_lines))

def is_number(value_str):
    try:
        float(value_str)
        return True
    except:
        return False

def instruction_assembler(instruction : str):
    instruction_string = instruction.upper()
    instruction_string = instruction_string.replace("->", " ")

    if instruction_string in instruction_mapping:
        return instruction_mapping[instruction_string]

    if "LD $" in instruction_string:
        instruction_name, variable_name = instruction_string.split("$")
        instruction_name = instruction_name.strip()
        variable_name = variable_name.strip()
        bin_instr = int(instruction_mapping[instruction_name], 2)
        bin_value = int(variable_dict[variable_name], 2)
        return bin(bin_instr | bin_value)[2:]
    
    elif "LD '" in instruction_string:
        value = instruction[3:]
        bin_value = str_value_to_bin(value)
        ram_address = ram_dict[bin_value]
        bin_instr = int(instruction_mapping["LDADDR"], 2)
        
        return bin(bin_instr | ram_address)[2:]

    elif "LD #" in instruction_string:
        instruction_name, value = instruction_string.split("#")
        bin_instr = int(instruction_mapping["LDADDR"], 2)

        if is_number(value_str=value):  # Hardcoded number
            bin_value = str_value_to_bin(value)
            ram_address = ram_dict[bin_value]
        else:                           # Variable -> get value from variable dict
            bin_value = variable_dict[value]
            # bin_value = str_value_to_bin(variable_value)
            ram_address = ram_dict[bin_value]
        
        return bin(bin_instr | ram_address)[2:]
        
    elif "LABEL" in instruction_string:
        instruction_name, label_name = instruction_string.split(" ")
        label_name = label_name.strip()
        metadata_dict[label_name] = len(output_lines)
        return '00000001'

    return False

def create_metadata_file(metadata_file, input_folder):
    metadata_lines = []

    metadata_lines.append(str(datetime.datetime.now())[:19])

    metadata_lines.append("\n--- Input files assembled ---")
    for input_file in input_folder.glob("*.txt"):
        metadata_lines.append(input_file.name)
    metadata_lines.append("-----------------------------\n")

    for data_name in metadata_dict:
        metadata_lines.append(f"{data_name} {metadata_dict[data_name]}")

    with open(metadata_file, "w", encoding="utf-8") as f:
        f.write("\n".join(metadata_lines))

def main(csv_path, input_path, output_path, ram_path, metadata_path):

    print("-----")
    print(f"Generating output based on file at: {input_path}")
    print("-----")

    csv_file = Path(csv_path)
    input_folder = Path(input_path)
    output_file = Path(output_path)
    ram_file = Path(ram_path)
    metadata_file = Path(metadata_path)

    global instruction_mapping
    instruction_mapping = load_instruction_map(csv_file)
    create_RAM_file(input_folder, ram_file)
    read_variables(input_folder)
    assemble(input_folder, output_file)
    create_metadata_file(metadata_file, input_folder)
    print(f"✨ Assembling complete. Behold thy ROM: {output_file}")

if __name__ == "__main__":
    
    csv_file_path = BASE_DIR / "instruction_map.csv"
    # input_file_path = BASE_DIR / "input.txt"
    input_folder_path = BASE_DIR / "input files"
    output_file_path = BASE_DIR / "output.rom"
    ram_file_path = BASE_DIR / "ram.ram"
    metadata_file_path = BASE_DIR / "metadata.txt"
    
    main(csv_file_path, input_folder_path, output_file_path, ram_file_path, metadata_file_path)


# TODO
# write HEX in input files
# hex(ord(value))
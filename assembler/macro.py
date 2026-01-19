
from pathlib import Path
import re
import os


class Macros():

    macros = []

    def __init__(self, input_folder_path, output_file_path):
        self.output_file_path = output_file_path
        self.clear_macro_folder(self.output_file_path)

        for macro_file in input_folder_path.glob("*.macro"):
            with open(macro_file, "r", encoding="utf-8") as f:
                lines = f.readlines()

                for line in lines:

                    if line == "\n" or line.startswith("//"):
                        continue

                    if line.startswith("%macro"):
                        split_line = line.strip().split(" ")
                        macro_name = split_line[1].strip()
                        variables = split_line[2:]
                        current_macro = Macro(macro_name=macro_name, variables=variables)
                        continue

                    if line.startswith("%end_macro"):
                        self.macros.append(current_macro)
                        continue
                    
                    current_macro.add_line(line.strip())

        for input_file in input_folder_path.glob("*.txt"):
            with open(input_file, "r", encoding="utf-8") as f:
                file_data = f.read()

                for i in range(1000):
                    old_file_data = file_data
                    for macro in self.macros:
                        file_data = macro.apply(file_data)

                    if file_data == old_file_data:
                        print(f"DEBUG: {i} iterations performed")
                        break

                    if i == 9:
                        print("Macro iteration limit reached 💥😭🤢🤮")
                
            self.save_output(data=file_data, name=input_file.name)

    def clear_macro_folder(self, output_file_path : str):
        for name in os.listdir(output_file_path):
            path = os.path.join(output_file_path, name)
            if os.path.isfile(path):
                os.remove(path)

    def save_output(self, data : str, name : str):
        output_file = str(self.output_file_path) + "/" + name
        with open(output_file, "w", encoding="utf-8") as f:
            f.write(data.upper())


class Macro():

    def __init__(self, macro_name : str, variables : list):
        self.macro_lines = []
        self.name = macro_name
        self.variables = variables
        pass

    def add_line(self, line):
        self.macro_lines.append(line)

    def apply(self, file_data : str):

        pos = re.search(rf"\s{re.escape(self.name)}\s", file_data)

        # start_index = file_data.find(self.name)
        if not pos:
            return file_data
        
        start_index = pos.start()+1
        stop_index = file_data.find("\n", start_index)

        text = file_data[start_index:stop_index]
        variable_values = text.strip().split(" ")[1:]

        variable_pairs = list(zip(self.variables, variable_values))

        output_lines = []

        for line in self.macro_lines:
            new_line = line
            for pair in variable_pairs:
                new_line = new_line.replace("%"+pair[0], pair[1])
            output_lines.append(new_line + "\n")

        replacement = "".join(output_lines)

        return file_data[:start_index] + replacement + file_data[stop_index:]

if __name__ == "__main__":
    BASE_DIR = Path(__file__).parent
    input_folder_path = BASE_DIR / "input files"
    output_folder_path = BASE_DIR / "macro_build"

    macros = Macros(input_folder_path, output_folder_path)

    # print(macros.macros[0].apply("LOAD_CONSTANT #42 X\n"))


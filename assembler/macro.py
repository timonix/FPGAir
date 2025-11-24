
from pathlib import Path


class Macros():

    macros = []

    def __init__(self, folder_path):
        for macro_file in folder_path.glob("*.macro"):
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

    # TODO apply all macros method
    # Parse all macros
    # Read from input folders

class Macro():

    def __init__(self, macro_name : str, variables : list):
        self.macro_lines = []
        self.name = macro_name
        self.variables = variables
        pass

    def add_line(self, line):
        self.macro_lines.append(line)

    def apply(self, file_data : str):

        start_index = file_data.find(self.name)
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

    macros = Macros(input_folder_path)

    print(macros.macros[0].apply("LOAD_CONSTANT #42 X\n"))


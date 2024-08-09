#!/bin/python3

import argparse

###### Arguments ######
parser = argparse.ArgumentParser(description="")
parser.add_argument("src_path", help="",
                    type=str, nargs='?', const="", default="")
parser.add_argument("obj_path", help="",
                    type=str, nargs='?', const="", default="")

args = parser.parse_args()

HEX_FILE = args.src_path
HEX_FILE_CONVERTED = args.obj_path

def convert_to_one_column():
    with open(HEX_FILE, "r", encoding="utf-8") as f:
        hex_file = list(f.read().split('\n'))

    section_cnt = 0

    hex_file_onecolumn = ""
    for line in hex_file:
        if section_cnt == 4:  # Copy only instructions, not data
            break
        if len(line) == 0:
            hex_file_onecolumn += f"{line}\n"
        elif line[0] == "@":
            section_cnt += 1
        else:
            line = line.replace(" ", "")
            for i in range(0, len(line), 8):
                hex_file_onecolumn += f"{line[i+6:i+8]}{line[i+4:i+6]}{line[i+2:i+4]}{line[i:i+2]}\n"
                #hex_file_onecolumn += f"{line[i:i+8]}\n"


    with open(HEX_FILE_CONVERTED, "w", encoding="utf-8") as f:
        f.write(hex_file_onecolumn)


if __name__ == "__main__":
    convert_to_one_column()



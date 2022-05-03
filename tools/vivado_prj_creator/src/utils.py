#!/usr/bin/python

################################################################
#                     _             _
#                    | |_  ___ _ __(_)__ _
#                    | ' \/ -_) '_ \ / _` |
#                    |_||_\___| .__/_\__,_|
#                             |_|
#
################################################################
#
# Company: hepia
# Engineer: Laurent Gantel <laurent.gantel@hes-so.ch>
#
# Project Name: Vivado Project Generator
# Version: 0.4
#
# File: vivado_prj.py
# Description: Vivado project descriptor - allow to create
#              tree directory
#
# Last update: 2021-01-22
#
#################################################################

import datetime
import re
import os
import shutil
import pathlib
import glob

def display_title(title_str):
    """
    @brief Display program title
    @param title_str The string to be displayed as the program title
    """
    print("\n----------------------------------------------------------------------------------")
    print("--                            _             _      ")
    print("--                           | |_  ___ _ __(_)__ _ ")
    print("--                           | ' \/ -_) '_ \ / _` |")
    print("--                           |_||_\___| .__/_\__,_|")
    print("--                                    |_|          ")
    print("--")
    print("----------------------------------------------------------------------------------")
    print("\n" + ('-' * (len(title_str) + 6)))
    print("-- " + title_str + " --")
    print(('-' * (len(title_str) + 6)) + "\n")


def get_time_str():
    """
    @brief Get time in the following format: Yearmonthday_HourMinuteSecond
    """
    return datetime.datetime.now().strftime("%Y%m%d_%H%M%S")

def file_replace_pattern(file_path, pattern, replace_str):
    """
    @brief Replace a pattern in a file
    @param file_path The path to the file to be processed
    @param pattern The pattern to be replaced
    @param replace_str The replacement string
    """
    # Create the regex pattern
    re_pattern = '(' + pattern + ')'
    p = re.compile(re_pattern)
    # Create a temp file to apply the pattern
    temp_file = file_path + '#'
    fin = open(file_path, 'r')
    fout = open(temp_file, 'w')
    for line in fin.readlines():
        # Substitute the pattern
        fout.write(p.sub(replace_str, line))
    # Replace the input file by the processed temp file
    os.remove(file_path)
    shutil.move(temp_file, file_path)

def hex32str(value):
    """
    @brief Convert a value into a 32-bits hex string
    @param value The integer value to be converted
    @return The 32-bits hex string
    """
    return '{:08X}'.format(value)

def copy_src_files(src_dir, dst_dir, file_ext):
    """
    @brief Copy source files with a given file extension from source directory to destination
    @param src_dir The source directory
    @param dst_dir The destination directory
    @param file_ext The file extension
    """
    # Create the destination directory
    pathlib.Path(dst_dir).mkdir(parents=True, exist_ok=True)
    # Copy the source files
    for file in glob.glob(os.path.join(src_dir, '*' + file_ext)):
        print("[DEBUG] - Copy file: ", file)
        shutil.copy(file, dst_dir)

def create_dir(dir_path, parents=False, exist_ok=False):
    path = pathlib.Path(dir_path)
    try:
        path.mkdir(parents=parents, exist_ok=exist_ok)
    except FileNotFoundError:
        print("[WARNING] - create_dir(): Path" + dir_path + " does not exist...")
    except FileExistsError:
        print("[WARNING] - create_dir(): " + dir_path + " directory already exists...")

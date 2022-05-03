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
# Engineer: Laurent Gantel <laurent.gantel@hesge.ch>
#
# Project Name: Vivado Project Generator
# Version: 0.5.4
#
# File: vivado_prj_creator.py
# Description: Vivado Project Creator main entry point
#
# Last update: 2021.10.29
#
#################################################################

import sys
import getopt
import json
from utils import display_title
from VpcJsonParser import VpcJsonParser
from VivadoProjectInfo import VivadoProjectInfo
from VitisProjectInfo import VitisProjectInfo
from ProjectFactory import ProjectFactory

# Current version
VERSION = '0.5.4'

# Help about script usage
def usage():
    print("Usage:")
    print("$ python vivado_prj_creator <options>")
    print("Options:")
    print("\t-h || --help\tDisplay this help")
    print("\t-c || --config-file <json_file>\tUse a JSON file for the project configuration")


if __name__ == '__main__':
    # Variable used to store JSON data
    json_data = None

    # Display the program title
    display_title(" Vivado Project Creator v{} " .format(VERSION))

    # Get project information via JSON if any
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hc:", ["help", "config-file="])
    except getopt.GetoptError:
        usage()
        sys.exit(-1)
    if not opts:
        usage()
        sys.exit(-1)

    # Check flag parameters coming from the command line
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        else:
            if opt in ("-c", "--config_file"):
                print("> Load project information from", arg, '\n')
                with open(arg) as f:
                    json_data  = json.load(f)

    json_parser = VpcJsonParser()
    json_parser.parseFile(json_data)
    json_parser.printInfo()
    viv_prj_info, vitis_prj_info = json_parser.getParsedInfo()

    # Create a Vivado project
    prj_fact = ProjectFactory()
    try:
        viv_prj = prj_fact.create_project(viv_prj_info, vitis_prj_info)
        viv_prj.print_dirs()
    except ValueError as ve:
        print(ve)
    else:
        # Create directory tree
        viv_prj.create_dir()
        # Generate other files (template sources and scripts)
        viv_prj.gen_files()

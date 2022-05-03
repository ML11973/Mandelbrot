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
# Version: 0.5.1
#
# File: VpcConfig.py
# Description: Configuration class for the Vivado Project Creator
#
# Last update: 2021-07-14
#
#################################################################

class VpcConfig():
    """
    Vivado Project Creator configuration class
    """
    def __init__(self):
        # Path to the directory containing the template files
        # Default is current directory (from where VPC is launched)
        self.templates_path = "."
    
    def set_templates_path(self, templates_path):
        self.templates_path = templates_path

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
# Version: 0.5.3
#
# File: SocDesign.py
# Description: Soc design class
#
# Last update: 2021.09.24
#
#################################################################

from factory.soc.Soc import Soc
from factory.Design import Design

class SocDesign(Soc, Design):
    def __init__(self, viv_prj_info, vitis_prj_info):
        Soc.__init__(self)
        Design.__init__(self, viv_prj_info, vitis_prj_info)

    def print_dirs(self):
        print("SocDesign:")
        print("\tProject directory: " + self.prj_gen_dir)
        print("\tComponent directory: " + self.comp_src_dir)
        print("\tPeripherals directory: " + self.comp_periph_dir)
        print("\tPackage directory: " + self.pkg_src_dir)
        print("\tSoC directory: " + self.soc_src_dir)

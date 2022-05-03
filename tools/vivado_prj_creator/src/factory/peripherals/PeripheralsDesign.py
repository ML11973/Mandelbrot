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
# File: PeripheralsDesign.py
# Description: Peripherals design class
#
# Last update: 2021.09.24
#
#################################################################

from factory.peripherals.Peripherals import Peripherals
from factory.Design import Design

class PeripheralsDesign(Peripherals, Design):
    def __init__(self, viv_prj_info, vitis_prj_info):
        Peripherals.__init__(self)
        Design.__init__(self, viv_prj_info, vitis_prj_info)

    def print_dirs(self):
        print("PeripheralsDesign:")
        print("\tProject directory: " + self.prj_gen_dir)
        print("\tComponent directory: " + self.comp_src_dir)
        print("\tPeripherals directory: " + self.comp_periph_dir)
        print("\tPackage directory: " + self.pkg_src_dir)
        print("\tSoC directory: " + self.soc_src_dir)

    def create_dir(self):
        Design.create_dir(self)

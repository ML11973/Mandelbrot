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
# File: PackagesComp.py
# Description: Packages component class
#
# Last update: 2021.09.24
#
#################################################################

import os
from factory.packages.Packages import Packages
from factory.Component import Component

class PackagesComp(Packages, Component):
    def __init__(self, viv_prj_info, vitis_prj_info):
        Packages.__init__(self)
        Component.__init__(self, viv_prj_info, vitis_prj_info)

    def print_dirs(self):
        print("PackagesComp:")
        print("\tProject directory: " + self.prj_gen_dir)
        print("\tComponent directory: " + self.comp_src_dir)
        print("\tPeripherals directory: " + self.comp_periph_dir)
        print("\tPackage directory: " + self.pkg_src_dir)
        print("\tSoC directory: " + self.soc_src_dir)

    def create_dir(self):
        """
        @brief Create directory tree
        """
        Component.create_dir(self)

    def gen_files(self):
        """
        @brief Generate HDL sources
        |-- src
            |-- hdl
            |   |-- <pkg_comp>.vhd
            |-- sim
                |-- tb_<pkg_comp>.vhd
        """
        Component.gen_files(self)

        src_dir = 'src' # Template source directory
        out_src_dir = os.path.join(self.comp_src_dir, self.viv_prj_info.prj_name, 'src')

        self.copy_template_file(src_dir + '_package', os.path.join('hdl', ''), self.viv_prj_info.hdl_ext, out_src_dir, keep_subdir=False, skip_existing=True)
        self.copy_template_file(src_dir + '_package', os.path.join('sim', 'tb_'), self.viv_prj_info.hdl_ext, out_src_dir, keep_subdir=False, skip_existing=True)
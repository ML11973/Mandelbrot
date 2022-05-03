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
# File: PeripheralsComp.py
# Description: Peripherals component class
#
# Last update: 2021.09.24
#
#################################################################

import os
import utils

from factory.peripherals.Peripherals import Peripherals
from factory.Component import Component

class PeripheralsComp(Peripherals, Component):
    def __init__(self, viv_prj_info, vitis_prj_info):
        Peripherals.__init__(self)
        Component.__init__(self, viv_prj_info, vitis_prj_info)

    def print_dirs(self):
        print("PeripheralsComp:")
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

        # Create also a drivers directory
        drivers_dir = os.path.join(self.comp_src_dir, self.viv_prj_info.prj_name, 'drivers', self.viv_prj_info.prj_name + '_v1_0')
        utils.create_dir(drivers_dir, parents=True, exist_ok=True)
        utils.create_dir(os.path.join(drivers_dir, 'data'), parents=True, exist_ok=True)
        utils.create_dir(os.path.join(drivers_dir, 'src'), parents=True, exist_ok=True)

    def gen_files(self):
        """
        @brief Generate HDL sources and software drivers
        """
        Component.gen_files(self)

        # Generate peripheral sources if required
        template_src_dir = 'src'
        out_src_dir = os.path.join(self.comp_src_dir, self.viv_prj_info.prj_name, 'src')
        self.copy_template_file(template_src_dir + '_peripheral', os.path.join('hdl', ''), self.viv_prj_info.hdl_ext, out_src_dir, keep_subdir=False, skip_existing=True)
        self.copy_template_file(template_src_dir + '_peripheral', os.path.join('hdl', ''), '_S00_AXI' + self.viv_prj_info.hdl_ext, out_src_dir, keep_subdir=False, skip_existing=True)
        self.copy_template_file(template_src_dir + '_peripheral', os.path.join('sim', 'tb_'), self.viv_prj_info.hdl_ext, out_src_dir, keep_subdir=False, skip_existing=True)
        print("> HDL sources successfully generated")

        # Generate software drivers if required
        drivers_dir = os.path.join('drivers', 'template_v1_0') # Template drivers directory
        out_drivers_dir = os.path.join(self.comp_src_dir, self.viv_prj_info.prj_name, 'drivers', self.viv_prj_info.prj_name + '_v1_0')
        self.copy_template_file(drivers_dir, os.path.join('data', ''), '.mdd', out_drivers_dir, keep_subdir=False, skip_existing=True)
        self.copy_template_file(drivers_dir, os.path.join('data', ''), '.tcl', out_drivers_dir, keep_subdir=False, skip_existing=True)
        self.copy_template_file(drivers_dir, os.path.join('src', ''), '.h', out_drivers_dir, keep_subdir=False, skip_existing=True)
        self.copy_template_file(drivers_dir, os.path.join('src', ''), '.c', out_drivers_dir, keep_subdir=False, skip_existing=True)
        self.copy_template_file(drivers_dir, os.path.join('src', 'Makefile'), '', out_drivers_dir, change_name=False, keep_subdir=False, skip_existing=True)
        print("> Peripheral drivers successfully generated")

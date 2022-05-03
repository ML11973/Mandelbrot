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
# File: Component.py
# Description: Component basis class
#
# Last update: 2021/09/30
#
#################################################################

import os
import utils

from factory.TemplateProject import TemplateProject

class Component(TemplateProject):
    def __init__(self, viv_prj_info, vitis_prj_info):
        TemplateProject.__init__(self, viv_prj_info, vitis_prj_info)

        # Set exported components directories
        self.comp_periph_dir = '../../peripherals/hw'
        self.pkg_src_dir = '../../packages/hw'
        self.soc_src_dir = '../../soc/hw'

    def create_dir(self):
        """
        @brief Create directories for a component project
        """
        if not os.path.exists(self.dir_name):
            TemplateProject.create_dir(self)
            
            # set the source directory
            source_dir = os.path.join(self.dir_name, 'src')
            os.makedirs(source_dir)

            comp_source_dir = os.path.join(self.comp_src_dir, self.viv_prj_info.prj_name, 'src')
            utils.create_dir(os.path.join(comp_source_dir, 'ipi_tcl'), parents=True, exist_ok=True)
            utils.create_dir(os.path.join(comp_source_dir, 'hdl'), parents=True, exist_ok=True)
            utils.create_dir(os.path.join(comp_source_dir, 'sim'), parents=True, exist_ok=True)
        else:
            print("[WARNING] - create_dir(): Project directory already exists...")

    def gen_files(self):
        """
        @brief Generate project files from templates for a component project
        """
        TemplateProject.gen_files(self)

        # Generate IPI_TCL file
        comp_source_dir = os.path.join(self.comp_src_dir, self.viv_prj_info.prj_name, 'src')
        ipi_tcl_file_path = os.path.join(comp_source_dir, 'ipi_tcl', self.viv_prj_info.prj_name + '_ipi.tcl')
        self.gen_ipi_file(ipi_tcl_file_path)

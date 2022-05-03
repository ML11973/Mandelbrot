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
# Version: 0.5.2
#
# File: Design.py
# Description: Design basis class
#
# Last update: 2021/07/25
#
#################################################################

import os

from factory.TemplateProject import TemplateProject

class Design(TemplateProject):
    def __init__(self, viv_prj_info, vitis_prj_info):
        TemplateProject.__init__(self, viv_prj_info, vitis_prj_info)

        # Set exported components directories
        self.comp_periph_dir = '../../peripherals/hw'
        self.pkg_src_dir = '../../packages/hw'
        self.soc_src_dir = '../../soc/hw'

        # Set project directory name
        self.dir_name = self.prj_gen_dir + '/' + self.viv_prj_info.prj_name + '/' + self.viv_prj_info.vivado_version

    def create_dir(self):
        """
        @brief Create directories for a design project
        @param source_dir The project source directory
        """
        if not os.path.exists(self.dir_name):
            TemplateProject.create_dir(self)

            # Create the source directory
            source_dir = os.path.join(self.dir_name, 'src')
            os.makedirs(source_dir)

            os.makedirs(os.path.join(source_dir, 'hdl'))
            os.makedirs(os.path.join(source_dir, 'sim'))
            os.makedirs(os.path.join(source_dir, 'constrs'))
            os.makedirs(os.path.join(source_dir, 'custom_ip'))
            os.makedirs(os.path.join(source_dir, 'ipi_tcl'))
            # Create software workspace directories
            os.makedirs(os.path.join(source_dir, 'sw'))
            os.makedirs(os.path.join(source_dir, os.path.join('sw', 'hw_export')))
            os.makedirs(os.path.join(source_dir, os.path.join('sw', '.scripts')))
            os.makedirs(os.path.join(source_dir, os.path.join('sw', 'sw_apps', self.viv_prj_info.prj_name + '_app', 'src', 'inc')))

    def gen_files(self):
        """
        @brief Generate design and software files
        """
        TemplateProject.gen_files(self)

        template_src_dir = 'src' # Template source directory
        self.gen_design_files(os.path.join('lin64', '.scripts'), template_src_dir)
        self.gen_sw_files(os.path.join('src', 'sw'))

    def gen_design_files(self, script_dir, template_src_dir):
        """
        @brief Generate project files from templates for a design project
        @param script_dir The script directory
        @param template_src_dir The template source directory
        """

        # Generate additional Vivado scripts
        self.copy_template_file(script_dir, 'gen_bitstream_', '.sh', self.dir_name)
        self.copy_template_file(script_dir, 'gen_bitstream_', '.tcl', self.dir_name)
        self.copy_template_file(script_dir, 'load_bitstream_', '.sh', self.dir_name)
        self.copy_template_file(script_dir, 'load_bitstream_', '.tcl', self.dir_name)
        self.copy_template_file(script_dir, 'export_hw_', '.sh', self.dir_name)
        self.copy_template_file(script_dir, 'export_hw_', '.tcl', self.dir_name)
        # DEPRECATED for the moment
        #self.copy_template_file(script_dir, 'load_sw_app_', '.sh', self.dir_name)
        #self.copy_template_file(script_dir, 'load_sw_app_', '.tcl', self.dir_name)
        print("> Design scripts successfully generated")

        # Generate HDL sources if required
        self.copy_template_file(template_src_dir, os.path.join('hdl', ''), self.viv_prj_info.hdl_ext, self.dir_name, skip_existing=True)
        self.copy_template_file(template_src_dir, os.path.join('sim', 'tb_'), self.viv_prj_info.hdl_ext, self.dir_name, skip_existing=True)
        print("> HDL sources successfully generated")

        # Generate IPI_TCL file
        source_dir = os.path.join(self.dir_name, 'src')
        ipi_tcl_file_path = os.path.join(source_dir, 'ipi_tcl', self.viv_prj_info.prj_name + '_ipi.tcl')
        self.gen_ipi_file(ipi_tcl_file_path)

        # Generate constraints files
        self.gen_constraints_files()

        # Add .gitignore file into custom_ip directory
        self.copy_template_file(template_src_dir, os.path.join('custom_ip', ''), '.gitignore', self.dir_name, change_name=False)

    def gen_constraints_files(self):
        """
        @brief Generate constraints files
        """
        source_dir = os.path.join(self.dir_name, 'src')
        constr_file_path = os.path.join(source_dir, 'constrs', self.viv_prj_info.prj_name + '.xdc')

        # If it does not exist yet, create an empty one and fill it with information from JSON configuration
        if not os.path.exists(constr_file_path):
            if self.viv_prj_info.prj_type == "DESIGN_PRJ_TYPE":
                # if user given constraints list is empty, create a new one
                if self.viv_prj_info.constr_dict == None :
                    open(constr_file_path, 'w').close()
                
                print("> Constraints source files successfully generated")
            elif self.viv_prj_info.prj_type == "COMP_PRJ_TYPE":
                pass
        else:
            print("[WARNING] - Skipping already existing file", constr_file_path)

    def gen_sw_files(self, template_src_dir):
        """
        @brief Generate software files for the Vitis workspace
        @param template_src_dir The template software source directory
        """
        # Copy the scripts
        self.copy_template_file(template_src_dir, 'setup', '.sh', self.dir_name, change_name=False)
        self.copy_template_file(template_src_dir, '', '.gitignore', self.dir_name, change_name=False)
        self.copy_template_file(template_src_dir, os.path.join('hw_export', ''), '.gitignore', self.dir_name, change_name=False)
        self.copy_template_file(template_src_dir, os.path.join('.scripts', 'gen_sw_apps_'), '.sh', self.dir_name)
        self.copy_template_file(template_src_dir, os.path.join('.scripts', 'gen_sw_apps_'), '.tcl', self.dir_name)
        self.copy_template_file(template_src_dir, os.path.join('.scripts', 'open_sdk_'), '.sh', self.dir_name)
        self.copy_template_file(template_src_dir, os.path.join('.scripts', 'clean_sdk_'), '.sh', self.dir_name)

        # Copy the utilities file
        # TODO: Have a common folder and files for both the Vivado and the Vitis directories
        self.copy_template_file(template_src_dir, os.path.join('.scripts', 'utils'), '.tcl', self.dir_name, False)
        self.copy_template_file(template_src_dir, os.path.join('.scripts', '.prompt_colors'), '.tcl', self.dir_name, False)

        # Copy the template application sources if required
        template_app_dir = os.path.join(template_src_dir, 'sw_apps', 'template_app')
        out_src_dir = os.path.join(self.dir_name, template_src_dir, 'sw_apps', self.viv_prj_info.prj_name + '_app')
        self.copy_template_file(template_app_dir, os.path.join('src', ''), '_app.c', out_src_dir, keep_subdir=False, skip_existing=True)
        self.copy_template_file(template_app_dir, os.path.join('src', 'inc', ''), '_app.h', out_src_dir, keep_subdir=False, skip_existing=True)
        print("> Software sources successfully generated")

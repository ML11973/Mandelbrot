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
# File: TemplateProject.py
# Description: Template Project basis class
#
# Last update: 2021.09.24
#
#################################################################

import os
import shutil
import time
import utils

class TemplateProject:
    def __init__(self, viv_prj_info, vitis_prj_info):
        # Set Vivado project information
        self.viv_prj_info = viv_prj_info
        # Set Vitis project information
        self.vitis_prj_info = vitis_prj_info
        # Set project directory name
        self.dir_name = self.prj_gen_dir + '/' + self.viv_prj_info.prj_name + '/' + self.viv_prj_info.vivado_version

    def create_dir(self):
        # set the scripts directory
        os.makedirs(os.path.join(self.dir_name, os.path.join('lin64', '.scripts')))

    def gen_files(self):
        # Directory that will contain the scripts inside the project directory tree
        DEFAULT_SCRIPT_DIR = os.path.join('lin64', '.scripts')

        # Generate scripts to create and clean a Vivado project
        self.copy_template_file('lin64', 'setup', '.sh', self.dir_name, change_name=False)
        self.copy_template_file('lin64', '', '.gitignore', self.dir_name, change_name=False)
        self.copy_template_file(DEFAULT_SCRIPT_DIR, 'clean_prj_', '.sh', self.dir_name)
        self.copy_template_file(DEFAULT_SCRIPT_DIR, 'open_prj_', '.sh', self.dir_name)
        self.copy_template_file(DEFAULT_SCRIPT_DIR, 'create_prj_' , '.sh', self.dir_name)
        self.copy_template_file(DEFAULT_SCRIPT_DIR, 'create_prj_' , '.tcl', self.dir_name)
        print("> Project scripts successfully generated")

        # Copy the utilities file
        self.copy_template_file(DEFAULT_SCRIPT_DIR, 'utils', '.tcl', self.dir_name, change_name=False)
        self.copy_template_file(DEFAULT_SCRIPT_DIR, '.prompt_colors', '.tcl', self.dir_name, change_name=False)
        print("> Utility scripts successfully copied")

    def gen_ipi_file(self, ipi_tcl_file_path):
        """
        @brief Generate IPI TCL file
        @param ipi_tcl_file_path The path to the IPI TCL file to be generated
        """
        # If it does not exist yet, create an empty one and fill it with information from JSON configuration
        if not os.path.exists(ipi_tcl_file_path):
            open(ipi_tcl_file_path, 'w').close()
            # Generate SoC patterns
            tcl_soc_pattern = None
            tcl_soc_list = None

            if self.viv_prj_info.soc_dict != None :
                if len(self.viv_prj_info.soc_dict) > 0:
                    tcl_soc_list = []

                    for i in self.viv_prj_info.soc_dict.keys():
                        if self.viv_prj_info.soc_dict[i] == "enable" or self.viv_prj_info.soc_dict[i] == "disable":
                            tcl_soc_pattern = "source \"../../../../../../soc/vivado/" + \
                                i + "/" + self.viv_prj_info.vivado_version + "/" + \
                                "src/ipi_tcl/" + i + "_ipi.tcl\""
                            tcl_soc_list.append(tcl_soc_pattern)

            # Creation of links to SOC tcl files
            if tcl_soc_list != None:
                for i in range(len(tcl_soc_list)):
                    f = open(ipi_tcl_file_path, "a+")
                    f.write(tcl_soc_pattern)
                    f.close()

            print("> IPI TCL source files successfully generated")
        else:
            print("[WARNING] - Skipping already existing file", ipi_tcl_file_path)

    def copy_template_file(self, template_dir, file_start, file_ext, out_dir, change_name=True, keep_subdir=True, skip_existing=False):
        """
        @brief Copy a template file
        @param template_dir Template file directory
        @param file_start The beginning of the template file name that will be kept for the output file name
        @param file_ext The template file extension
        @param out_dir The output directory
        @param change_name Indicates if the name of the copied file must be change according to project name
        @param keep_subdir Indicates if the sub-directoy name must be kept as is
        @param skip_existing Indicates if already existing files will be skipped
        """

        templates_path = self.viv_prj_info.vpc_config.templates_path

        if (change_name):
            in_file_name = os.path.join(templates_path, 'templates', template_dir, file_start + 'template' + file_ext)
            if (not keep_subdir):
                template_dir = ''
            # Remove 'template' from the output file name and add the project name in it
            out_file_name = os.path.join(out_dir, template_dir, file_start + self.viv_prj_info.prj_name + file_ext)
        else:
            in_file_name = os.path.join(templates_path, 'templates', template_dir, file_start + file_ext)
            if (not keep_subdir):
                template_dir = ''
            out_file_name = os.path.join(out_dir, template_dir, file_start + file_ext)

        if __debug__:
            print("[DEBUG] Copy ", in_file_name, " to ", out_file_name)

        # Abort if file exist and skip_existing is set
        if os.path.exists(out_file_name) and skip_existing:
            print("[WARNING] - Skipping already existing file ", out_file_name)
            return

        # Copy the file
        shutil.copy(in_file_name, out_file_name)

        # Replace main project information
        self.replace_prj_patterns(out_file_name)

        # Replace constraints pattern
        self.replace_constr_pattern(out_file_name)

        # Replace package pattern
        self.replace_pkg_pattern(out_file_name)

        # Replace SoC wrapper pattern
        self.replace_soc_pattern(out_file_name)

        # Replace IPs pattern
        self.replace_ips_pattern(out_file_name)

        # Replace vitis project information
        self.replace_sw_patterns(out_file_name)

        # Replace simulation package pattern
        self.replace_sim_pkg_pattern(out_file_name)

        # if the template is a script, make it executable
        if file_ext == ".sh":
            # Note: do not remove the "0"
            os.chmod(out_file_name, 0o755)

    def replace_prj_patterns(self, filename):
        """
        @brief Replace project patterns using project information
        @param filename The name of the file in which pattern must be replaced
        """
        utils.file_replace_pattern(filename, '<author>', self.viv_prj_info.author)
        utils.file_replace_pattern(filename, '<prj_name>', self.viv_prj_info.prj_name)
        utils.file_replace_pattern(filename, '<prj_name_up>', self.viv_prj_info.prj_name.upper())
        utils.file_replace_pattern(filename, '<upper_prj_name>', self.viv_prj_info.prj_name.upper())
        utils.file_replace_pattern(filename, '<prj_type>', self.viv_prj_info.prj_type)
        utils.file_replace_pattern(filename, '<part_name>', self.viv_prj_info.part_name)
        utils.file_replace_pattern(filename, '<board_name>', self.viv_prj_info.board_name)
        utils.file_replace_pattern(filename, '<tool_version>', self.viv_prj_info.vivado_version)
        utils.file_replace_pattern(filename, '<target_language>', self.viv_prj_info.target_language)
        utils.file_replace_pattern(filename, '<update_time>', time.strftime("%Y-%m-%d %H:%M:%S"))
        utils.file_replace_pattern(filename, '<ip_dir_path>', "../../../" + self.comp_src_dir)
        utils.file_replace_pattern(filename, '<periph_dir_path>', "../../../" + self.comp_periph_dir)
        utils.file_replace_pattern(filename, '<vhdl_version>', self.viv_prj_info.vhdl_version)

    def replace_constr_pattern(self, filename):
        """
        @brief Replace the constraint pattern using project information
        @param filename The name of the file in which pattern must be replaced
        """

        # Generate constraints command
        tcl_constr_cmd = ""
        if self.viv_prj_info.constr_dict == None :
            tcl_constr_cmd = "add_files -fileset constrs_1 -norecurse  $src_dir/constrs/${prj_name}.xdc\n" + \
                "\tset_property is_enabled true [get_files $src_dir/constrs/${prj_name}.xdc]\n"
        elif self.viv_prj_info.constr_dict != None :
            if len(self.viv_prj_info.constr_dict) > 0 :
                for i in self.viv_prj_info.constr_dict.keys() :
                    str_en = "false"
                    if self.viv_prj_info.constr_dict[i] == "enable" :
                        str_en = "true"
                    tcl_constr_cmd = tcl_constr_cmd + \
                        "add_files -fileset constrs_1 -norecurse $src_dir/constrs/" + i + ".xdc\n" + \
                        "\tset_property is_enabled " + str_en + " [get_files $src_dir/constrs/" + i + ".xdc]\n\t"

        # Replace the pattern
        utils.file_replace_pattern(filename, '<find_constr_file>', tcl_constr_cmd)

    def replace_pkg_pattern(self, filename):
        """
        @brief Replace the package pattern using project information
        @param filename The name of the file in which pattern must be replaced
        """

        tcl_pkg_cmd = ""

        if self.viv_prj_info.packages_dict != None :
            if len(self.viv_prj_info.packages_dict) > 0 :
                tcl_pkg_find_file_cmd = ""
                tcl_pkg_src_dir = "${PRJ_DIR}/../../../../../packages/hw"

                for pkg_name in self.viv_prj_info.packages_dict.keys() :
                    # Default attributes
                    str_en = "false"
                    library_name = "xil_defaultlib"
                    vhdl_version = self.viv_prj_info.vhdl_version
                    # Get package attributes
                    for attr_name in self.viv_prj_info.packages_dict[pkg_name].keys() :
                        if attr_name == "enable":
                            str_en = self.viv_prj_info.packages_dict[pkg_name][attr_name]
                        elif attr_name == "library_name":
                            library_name = self.viv_prj_info.packages_dict[pkg_name][attr_name]
                        elif attr_name == "vhdl_version":
                            vhdl_version = self.viv_prj_info.packages_dict[pkg_name][attr_name]

                    # Create TCL command line
                    tcl_pkg_find_file_cmd = tcl_pkg_find_file_cmd + \
                        "\tset vhdl_pkg_file_list [findFiles " + \
                        tcl_pkg_src_dir + "/" + pkg_name + \
                        "/src/hdl *.vhd]\n" + \
                        "\tadd_files -norecurse $vhdl_pkg_file_list\n" + \
                        "\tforeach j $vhdl_pkg_file_list {\n" + \
                        "\t\tset_property is_enabled " + str_en + " [get_files $j]\n" + \
                        "\t\tset_property library " + library_name + " [get_files $j]\n"
                    if vhdl_version == "VHDL" or vhdl_version == "VHDL 2008":
                        tcl_pkg_find_file_cmd = tcl_pkg_find_file_cmd + \
                            "\t\tset_property file_type {" + vhdl_version + "} [get_files $j]\n" + \
                            "\t\tprint_status \"" + vhdl_version + " mode configured for the file $j\" \"OK\"\n"

                    tcl_pkg_find_file_cmd = tcl_pkg_find_file_cmd + "\t}\n"

                tcl_pkg_cmd = tcl_pkg_cmd + tcl_pkg_find_file_cmd
                tcl_pkg_cmd += "print_status \"Add packages sources\" \"OK\"\n" + \
                    "print_status \"" + self.viv_prj_info.vhdl_version + " mode configured for packages sources\" \"OK\""

        # Replace packages pattern
        utils.file_replace_pattern(filename, '<find_pkg_src_file>', tcl_pkg_cmd)

    def replace_sim_pkg_pattern(self, filename):
        """
        @brief Replace the simulation package pattern using project information
        @param filename The name of the file in which pattern must be replaced
        """

        tcl_pkg_cmd = ""

        if self.viv_prj_info.sim_packages_dict != None :
            if len(self.viv_prj_info.sim_packages_dict) > 0 :
                tcl_pkg_find_file_cmd = ""
                tcl_pkg_src_dir = "${PRJ_DIR}/../../../../../packages/hw/"

                for pkg_name in self.viv_prj_info.sim_packages_dict.keys():
                    # Default attributes
                    str_en = "false"
                    library_name = "xil_defaultlib"
                    vhdl_version = self.viv_prj_info.vhdl_version
                    import_src = "enable"

                    # Get package attributes
                    for attr_name in self.viv_prj_info.sim_packages_dict[pkg_name].keys() :
                        if attr_name == "enable":
                            str_en = self.viv_prj_info.sim_packages_dict[pkg_name][attr_name]
                        elif attr_name == "library_name":
                            library_name = self.viv_prj_info.sim_packages_dict[pkg_name][attr_name]
                        elif attr_name == "vhdl_version":
                            vhdl_version = self.viv_prj_info.sim_packages_dict[pkg_name][attr_name]
                        elif attr_name == "import_src":
                            import_src = self.viv_prj_info.sim_packages_dict[pkg_name][attr_name]

                    # Import package source file into sim directory if required (support only Component for the moment)
                    if import_src == "enable":
                        src_dir = os.path.join(self.pkg_src_dir, pkg_name, 'src')
                        dst_dir = os.path.join(self.comp_src_dir, self.viv_prj_info.prj_name, 'src', 'sim', pkg_name, 'src')
                        self.import_src_files(src_dir, dst_dir)
                        tcl_pkg_src_dir = "${PRJ_DIR}/../../../" + self.comp_src_dir + "/" + self.viv_prj_info.prj_name + "/src/sim/" + pkg_name + "/src/hdl"
                    else:
                        tcl_pkg_src_dir = tcl_pkg_src_dir + "/" + pkg_name + "/src/hdl"

                    # Create TCL command line
                    tcl_pkg_find_file_cmd = tcl_pkg_find_file_cmd + \
                        "\tset vhdl_sim_pkg_file_list [findFiles " + \
                        tcl_pkg_src_dir + " *.vhd]\n" + \
                        "\tadd_files -fileset sim_1 -norecurse $vhdl_sim_pkg_file_list\n" + \
                        "\tforeach j $vhdl_sim_pkg_file_list {\n" + \
                        "\t\tset_property is_enabled " + str_en + " [get_files $j]\n" + \
                        "\t\tset_property library " + library_name + " [get_files $j]\n"
                    if vhdl_version == "VHDL" or vhdl_version == "VHDL 2008":
                        tcl_pkg_find_file_cmd = tcl_pkg_find_file_cmd + \
                            "\t\tset_property file_type {" + vhdl_version + "} [get_files $j]\n" + \
                            "\t\tprint_status \"" + vhdl_version + " mode configured for the file $j\" \"OK\"\n"

                    tcl_pkg_find_file_cmd = tcl_pkg_find_file_cmd + "\t}\n"

                tcl_pkg_cmd = tcl_pkg_cmd + tcl_pkg_find_file_cmd
                tcl_pkg_cmd += "print_status \"Add simulation packages sources\" \"OK\"\n" + \
                    "print_status \"" + vhdl_version + " mode configured for simulation packages sources\" \"OK\""

        # Replace packages pattern
        utils.file_replace_pattern(filename, '<find_sim_pkg_src_file>', tcl_pkg_cmd)

    def replace_soc_pattern(self, filename):
        """
        @brief Replace the SoC pattern using project information
        @param filename The name of the file in which pattern must be replaced
        """

        # Add SoC wrapper pattern
        tcl_soc_wrapper_cmd = ""

        if self.viv_prj_info.soc_dict != None :
            if len(self.viv_prj_info.soc_dict) > 0 :
                tcl_soc_wrapper_find_file_cmd = ""
                tcl_soc_wrapper_src_dir = "${PRJ_DIR}/../../../../../soc/hw"

                for i in self.viv_prj_info.soc_dict.keys() :
                    str_en = "false"
                    if self.viv_prj_info.soc_dict[i] == "enable" :
                        str_en = "true"
                    tcl_soc_wrapper_find_file_cmd = tcl_soc_wrapper_find_file_cmd + \
                        "\tset vhdl_soc_file_list [findFiles " + \
                        tcl_soc_wrapper_src_dir + "/" + i + \
                        "/src/hdl *.vhd]\n" + \
                        "\tadd_files -norecurse $vhdl_soc_file_list\n" + \
                        "\tforeach j $vhdl_soc_file_list {\n" + \
                        "\t\tset_property file_type {" + self.viv_prj_info.vhdl_version + "} [get_files $j]\n" + \
                        "\t\tprint_status \"" + self.viv_prj_info.vhdl_version + " mode configured for the file $j\" \"OK\"\n" + \
                        "\t\tset_property is_enabled " + str_en + " [get_files $j]\n" + \
                        "\t}\n"

                tcl_soc_wrapper_cmd = tcl_soc_wrapper_cmd + tcl_soc_wrapper_find_file_cmd
                tcl_soc_wrapper_cmd += "print_status \"Add SoC wrapper sources\" \"OK\"\n" + \
                    "print_status \"" + self.viv_prj_info.vhdl_version + " mode configured for SoC wrapper sources\" \"OK\""

        # Replace SoC wrapper pattern
        utils.file_replace_pattern(filename, '<find_soc_src_file>', tcl_soc_wrapper_cmd)

    def replace_ips_pattern(self, filename):
        """
        @brief Replace the IPs pattern using project information
        @param filename The name of the file in which pattern must be replaced
        """

        tcl_ips_design_cmd = ""
        tcl_ips_comp_cmd   = ""

        if self.viv_prj_info.ips_dict != None :
            if len(self.viv_prj_info.ips_dict) > 0 :
                tcl_ips_find_file_cmd     = ""
                tcl_xci_find_file_cmd     = ""

                if self.viv_prj_info.prj_type in ["DESIGN_PRJ_TYPE","COMP_PRJ_TYPE"] :
                    for i in self.viv_prj_info.ips_dict.keys() :
                        if self.viv_prj_info.ips_dict[i]["hdl"] == "enable" :
                            tcl_ips_find_file_cmd = tcl_ips_find_file_cmd + \
                                "set vhdl_ips_file_list [findFiles " + \
                                "${ip_dir}/" + i + "/src/hdl *.vhd]\n" + \
                                "\tadd_files -norecurse $vhdl_ips_file_list\n" + \
                                "\tforeach j $vhdl_ips_file_list {\n" + \
                                "\t\tset_property file_type {" + self.viv_prj_info.vhdl_version + "} [get_files $j]\n" + \
                                "\t\tprint_status \"" + self.viv_prj_info.vhdl_version + " mode configured for the file $j\" \"OK\"\n" + \
                                "\t\tset_property is_enabled true [get_files $j]\n" + \
                                "\t}\n"

                        for j in self.viv_prj_info.ips_dict[i]["xci"].keys() :
                            tcl_xci_find_file_cmd = tcl_xci_find_file_cmd + \
                                "\tread_ip ${ip_dir}/" + i + "/src/ip_core/" + j + "/" + j + ".xci\n"

                        if self.viv_prj_info.prj_type == "DESIGN_PRJ_TYPE" :
                            tcl_ips_design_cmd = tcl_ips_find_file_cmd + tcl_xci_find_file_cmd
                        elif self.viv_prj_info.prj_type == "COMP_PRJ_TYPE" :
                            tcl_ips_comp_cmd = tcl_ips_find_file_cmd + tcl_xci_find_file_cmd

        # Replace IPS pattern
        utils.file_replace_pattern(filename, '<find_xci_design_src_file>', tcl_ips_design_cmd)
        utils.file_replace_pattern(filename, '<find_xci_comp_src_file>', tcl_ips_comp_cmd)

    def replace_sw_patterns(self, filename):
        """
        @brief Replace the software attributes pattern using Vitis project information
        @param filename The name of the file in which pattern must be replaced
        """
        utils.file_replace_pattern(filename, '<proc_name>', self.vitis_prj_info.proc_name)
        utils.file_replace_pattern(filename, '<os_name>', self.vitis_prj_info.os_name)
        utils.file_replace_pattern(filename, '<template_name>', self.vitis_prj_info.template_name)

    def import_src_files(self, ext_src_dir, prj_dir):
        """
        @brief Import external source files into project directory
        @param ext_src_dir The external sources directory
        @param prj_dir The project directory where to import the sources
        """
        # Set HDL directories
        hdl_src_dir = os.path.join(ext_src_dir, 'hdl')
        hdl_dst_dir = os.path.join(prj_dir, 'hdl')
        # Copy HDL files
        utils.copy_src_files(hdl_src_dir, hdl_dst_dir, '.vhd')

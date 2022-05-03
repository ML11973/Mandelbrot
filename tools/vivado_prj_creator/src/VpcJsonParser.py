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
# File: VpcJsonParser.py
# Description: Parser class for the Vivado Project Creator
#              JSON configuration files
#
# Last update: 2021-07-06
#
#################################################################

import json
from utils import display_title
from VivadoProjectInfo import VivadoProjectInfo
from VitisProjectInfo import VitisProjectInfo

class VpcJsonParser():
    """
    @brief Parse JSON data read from a VPC configuration file
    """
    def __init__(self):
        self.viv_prj_info = VivadoProjectInfo()
        self.vitis_prj_info = VitisProjectInfo()

    def parseFile(self, json_data):
        """
        @brief Parse data from a VPC JSON file
        @param json_data The VPC JSON file
        """

        # Get VPC configuration
        if "config" in json_data:
            if "templates_path" in json_data["config"]:
                self.viv_prj_info.vpc_config.set_templates_path(json_data["config"]["templates_path"])

        # Get Author"s name and email
        self.viv_prj_info.author = json_data["author"]["name"] + ' ' + json_data["author"]["email"]

        # Get project name and type
        self.viv_prj_info.prj_name = json_data["project"]["name"]
        self.viv_prj_info.prj_type = json_data["project"]["type"]

        # Get project category
        self.viv_prj_info.prj_cat = json_data["project"]["category"]
        
        # Get vivado version
        self.viv_prj_info.vivado_version = json_data["project"]["vivado_version"]
        
        # Get target language
        self.viv_prj_info.set_target_language(json_data["project"]["target_language"])
        
        # Get part name and board name
        self.viv_prj_info.part_name = json_data["hardware"]["part_name"]
        self.viv_prj_info.board_name = json_data["hardware"]["board_name"]

        self.viv_prj_info.vhdl_version = "VHDL"
        # Get VHDL version
        if "vhdl_version" in json_data["project"]:
            self.viv_prj_info.vhdl_version = json_data["project"]["vhdl_version"]

        self.viv_prj_info.constr_dict = None
        # Get constraints list
        if "constraints" in json_data:
            self.viv_prj_info.constr_dict = json_data["constraints"]

        self.viv_prj_info.packages_dict = None
        # Get packages list
        if "components" in json_data:
            if "packages" in json_data["components"] :
                self.viv_prj_info.packages_dict = json_data["components"]["packages"]

        self.viv_prj_info.soc_dict = None
        # Get SoC list
        if "components" in json_data:
            if "soc" in json_data["components"] :
                self.viv_prj_info.soc_dict = json_data["components"]["soc"]

        self.viv_prj_info.ips_dict = None
        # Get IPs list
        if "components" in json_data:
            if "ips" in json_data["components"] :
                self.viv_prj_info.ips_dict = json_data["components"]["ips"]

        self.viv_prj_info.sim_packages_dict = None
        # Get simulation packages list
        if "sim_components" in json_data:
            if "packages" in json_data["sim_components"] :
                self.viv_prj_info.sim_packages_dict = json_data["sim_components"]["packages"]

        # Get default software project attributes if any
        if "software" in json_data:
            if "default_project" in json_data["software"] :
                default_prj = json_data["software"]["default_project"]
                self.vitis_prj_info.proc_name = default_prj["proc_name"]
                self.vitis_prj_info.os_name = default_prj["os_name"]
                self.vitis_prj_info.template_name = default_prj["template_name"]

    def printConstrsList(self):
        if self.viv_prj_info.constr_dict != None:
            print("\t" + "-" * 16)
            print("\tConstraints:")
            for constrs_file in self.viv_prj_info.constr_dict.keys():
                print("\t\t", self.viv_prj_info.constr_dict[constrs_file].capitalize(), constrs_file + ".xdc")

    def printPackagesList(self):
        if self.viv_prj_info.packages_dict != None:
            print("\t" + "-" * 16)
            print("\tPackages:")
            for pkg_comp in self.viv_prj_info.packages_dict.keys():
                strout = "\t\t" + pkg_comp
                if self.viv_prj_info.packages_dict[pkg_comp]["enable"] == "true":
                    strout += " (Enable)"
                else:
                    strout += " (Disable)"

                try:
                    lib_name = self.viv_prj_info.packages_dict[pkg_comp]["library_name"]
                except:
                    lib_name = "xil_default"
                finally:
                    strout += "- lib: " + lib_name

                try:
                    vhdl_version = self.viv_prj_info.packages_dict[pkg_comp]["vhdl_version"]
                except:
                    vhdl_version = "default"
                finally:
                    print(strout, "- type:", vhdl_version)

    def printSoCList(self):
        if self.viv_prj_info.soc_dict != None:
            print("\t" + "-" * 16)
            print("\tSoC:")
            for soc_comp in self.viv_prj_info.soc_dict.keys():
                print("\t\t", self.viv_prj_info.soc_dict[soc_comp].capitalize(), soc_comp)

    def printIpsList(self):
        if self.viv_prj_info.ips_dict != None:
            print("\t" + "-" * 16)
            print("\tIPs:")
            for ips_comp in self.viv_prj_info.ips_dict.keys():
                strout = "\t\t" + ips_comp
                if self.viv_prj_info.ips_dict[ips_comp]["hdl"] == "enable":
                    strout += " [HDL]"
                else:
                    strout += " [No HDL]"

                try:
                    xci_list = self.viv_prj_info.ips_dict[ips_comp]["xci"]
                    xci_info = ""
                except:
                    xci_list = None
                    xci_info = "[No XCI]"
                finally:
                    if xci_list != None:
                        for ip in xci_list.keys():
                            xci_info += ip + " "
                    print(strout, "- xci:", xci_info)

    def printSimCompList(self):
        if self.viv_prj_info.sim_packages_dict != None:
            print("\t" + "-" * 16)
            print("\tSimulation packages:")
            for pkg_comp in self.viv_prj_info.sim_packages_dict.keys():
                strout = "\t\t" + pkg_comp
                if self.viv_prj_info.sim_packages_dict[pkg_comp]["enable"] == "true":
                    strout += " (Enable)"
                else:
                    strout += " (Disable)"

                try:
                    lib_name = self.viv_prj_info.sim_packages_dict[pkg_comp]["library_name"]
                except:
                    lib_name = "xil_default"
                finally:
                    strout += "- lib: " + lib_name

                try:
                    vhdl_version = self.viv_prj_info.sim_packages_dict[pkg_comp]["vhdl_version"]
                except:
                    vhdl_version = "default"
                finally:
                    print(strout, "- type:", vhdl_version)

    def printSwInfo(self):
        if self.vitis_prj_info != None:
            print("\t" + "-" * 16)
            print("\tSoftware default project:")
            print("\t\tProcessor name:", self.vitis_prj_info.proc_name)
            print("\t\tOS name:", self.vitis_prj_info.os_name)
            print("\t\tTemplate name:", self.vitis_prj_info.template_name)

    def printInfo(self):
        """
        @brief Print parsed project information
        """
        print("> VPC configuration:")
        print("\tTemplates directory path:", self.viv_prj_info.vpc_config.templates_path, "\n")
        
        print("> Project information:")
        print("\t" + "-" * 16)
        print("\tAuthor:", self.viv_prj_info.author)
        print("\tProject:", self.viv_prj_info.prj_name, "(", self.viv_prj_info.prj_type, ")")
        print("\tCategory:", self.viv_prj_info.prj_cat)
        print("\tVivado version:", self.viv_prj_info.vivado_version)
        print("\tTarget language:", self.viv_prj_info.target_language)
        if self.viv_prj_info.target_language == "VHDL":
            print("\tVHDL version:", self.viv_prj_info.vhdl_version)
        print("\t--")
        print("\tPart name:", self.viv_prj_info.part_name)
        print("\tBoard name:", self.viv_prj_info.board_name)

        # Constraints files list
        self.printConstrsList()
        
        # Packages list
        self.printPackagesList()

        # SoC list
        self.printSoCList()

        # IPs list
        self.printIpsList()

        # Simulation packages list
        self.printSimCompList()

        # Software information
        self.printSwInfo()

    def getParsedInfo(self):
        """
        @brief Get JSON file parsed information
        @return A VivadoPrjInfo structure and a VitisPrjInfo structure
        """
        return self.viv_prj_info, self.vitis_prj_info

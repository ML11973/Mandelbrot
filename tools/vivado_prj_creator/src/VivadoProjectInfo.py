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
# Project Name: Vivado Project Creator
# Version: 0.5
#
# File: VivadoProjectInfo.py
# Description: Store Vivado project information
#
# Last update: 2021-07-14
#
#################################################################

from VpcConfig import VpcConfig

"""
Storage structure for Vivado project information
"""
class VivadoProjectInfo:
    __slots__ = ["author", "prj_name", "prj_type", "prj_cat",
                 "vivado_version", "target_language", "vhdl_version",
                 "part_name", "board_name", "constr_dict",
                 "packages_dict", "soc_dict", "ips_dict", "hdl_ext",
                 "sim_packages_dict", "vpc_config"]
    def __init__(self):
        self.author = "author <author@mail.com>"
        self.prj_name = "prj_name"
        self.prj_type = "DESIGN_PRJ_TYPE"
        self.prj_cat = "IPS"
        self.vivado_version = "vivado_version"
        self.target_language = "VHDL"
        self.vhdl_version = "vhdl_version"
        self.part_name = "xc7z020clg484-1"
        self.board_name = "em.avnet.com:zed:part0:1.3"
        self.constr_dict = None
        self.packages_dict = None
        self.soc_dict = None
        self.ips_dict = None
        self.hdl_ext = ".vhd"
        self.sim_packages_dict = None
        # VPC configuration
        self.vpc_config = VpcConfig()

    def set_target_language(self, target_language):
        self.target_language = target_language
        # Get top-level extension for HDL template generation
        hdl_ext_dict = {"Verilog": ".v", "SystemVerilog": ".sv", "VHDL": ".vhd"}
        self.hdl_ext = hdl_ext_dict[target_language]

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
# Version: 0.5
#
# File: ProjectFactory.py
# Description: Project factory used to generate project instances
#              regarding given project type and category
#
# Last update: 2021/06/22
#
#################################################################

import importlib

from VivadoProjectInfo import VivadoProjectInfo
from VitisProjectInfo import VitisProjectInfo

from factory.ips.IpsDesign import IpsDesign
from factory.ips.IpsComp import IpsComp
from factory.peripherals.PeripheralsDesign import PeripheralsDesign
from factory.peripherals.PeripheralsComp import PeripheralsComp
from factory.soc.SocDesign import SocDesign
from factory.soc.SocComp import SocComp
from factory.packages.PackagesComp import PackagesComp
from factory.designs.DesignsDesign import DesignsDesign

class ProjectFactory():
    def create_project(self, viv_prj_info, vitis_prj_info):
        # Get project information
        prj_type = viv_prj_info.prj_type
        prj_cat = viv_prj_info.prj_cat
        
        # Check supported project type and category
        if (prj_cat == "PACKAGES") and (viv_prj_info.target_language == "Verilog"):
            raise ValueError("[ERROR] - Verilog is not supported for creating HDL packages...")

        if (prj_type == "DESIGN_PRJ_TYPE"):
            if (prj_cat == "PACKAGES"):
                raise ValueError("[ERROR] - A Package project cannot be a design...")
            else:
                prefix_type = "Design"
        elif (prj_type == "COMP_PRJ_TYPE"):
            if (prj_cat == "DESIGNS"):
                raise ValueError("[ERROR] - A Design project could not be a component...")
            else:
                prefix_type = "Comp"
        else:
            raise ValueError("[ERROR] - Unsupported project type '" + prj_type + "'")

        # Create a new instance of the required project
        module_name = prj_cat.capitalize()+prefix_type
        return globals()[module_name](viv_prj_info, vitis_prj_info)

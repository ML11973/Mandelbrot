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
# File: VitisProjectInfo.py
# Description: Store Vitis project information
#
# Last update: 2021-01-22
#
#################################################################

"""
Storage structure for Vitis project information
"""
class VitisProjectInfo:
    __slots__ = ["proc_name", "os_name", "template_name"]
    def __init__(self):
        # Processor name:
        #  - Zynq-7000:
        #    - Cortex-A9: ps7_cortexa9_0, ps7_cortexa9_1
        #  - Zynq MPSoC:
        #    - Cortex-A53: psu_cortexa53_0, psu_cortexa53_1, psu_cortexa53_2, psu_cortexa53_3
        #    - Cortex-R5:  psu_cortexr5_0, psu_cortexr5_1
        #    - PMU:        psu_pmu_0
        self.proc_name = "undefined"
        # OS name:
        #  - Xilinx standalone OS: standalone
        #  - FreeRTOS:             freertos10_xilinx
        self.os_name = "undefined"
        # Template name:
        #  - Empty application: Empty Application
        self.template_name = "undefined"

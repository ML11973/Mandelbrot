#!/bin/sh

##################################################################################
#                                 _             _
#                                | |_  ___ _ __(_)__ _
#                                | ' \/ -_) '_ \ / _` |
#                                |_||_\___| .__/_\__,_|
#                                         |_|
#
##################################################################################
#
# Company: hepia
# Author: <author>
#
# Project Name: <prj_name>
# Target Device: <board_name> <part_name>
# Tool version: <tool_version>
# Description: Export the hardware design to SDK
#
# Last update: <update_time>
#
##################################################################################

echo "> Export the hardware design to SDK"

vivado -nojournal -nolog -mode tcl -source ./export_hw_<prj_name>.tcl -notrace

echo "> Done"


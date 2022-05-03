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
# Description: Open Vivado project GUI
#
# Last update: <update_time>
#
##################################################################################

echo "> Open Vivado GUI..."
vivado -nojournal -nolog -notrace ../<prj_name>/<prj_name>.xpr

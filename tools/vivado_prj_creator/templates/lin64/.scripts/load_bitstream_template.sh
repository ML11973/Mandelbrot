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
# Description: Load bitstream file
#
# Last update: <update_time>
#
##################################################################################

echo "> Load bitstream file..."
vivado -nojournal -nolog -mode tcl -source ./load_bitstream_<prj_name>.tcl -notrace
echo "> Done"


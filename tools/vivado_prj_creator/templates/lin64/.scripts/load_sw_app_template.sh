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
# Description: Load software application
#
# Last update: <update_time>
#
##################################################################################

echo "> Load software application..."
xsdk -batch -source ./load_sw_app_<prj_name>.tcl -notrace
echo "> Done"


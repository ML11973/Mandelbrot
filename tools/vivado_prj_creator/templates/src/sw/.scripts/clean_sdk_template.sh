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
# Description: Cleanup Vitis SDK workspace directory
#
# Last update: <update_time>
#
##################################################################################

echo "> Cleanup SDK workspace directory..."

PRJ_DIR=..

# Clean current directory
rm -rf ./xrc.log/ 2> /dev/null
rm -rf ./.Xil/ 2> /dev/null

# Remove generated workspace directory
rm -rf ${PRJ_DIR}/sdk_workspace/ 2> /dev/null
rm -rf ${PRJ_DIR}/vitis_workspace/ 2> /dev/null

echo "> Done"

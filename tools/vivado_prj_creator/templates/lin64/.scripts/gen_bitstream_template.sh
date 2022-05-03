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
# Description: Generate bitstream file
#
# Last update: <update_time>
#
##################################################################################

PRJ_DIR=..

echo "> Generate bitstream file..."
vivado -nojournal -nolog -mode tcl -source ./gen_bitstream_<prj_name>.tcl -notrace

echo "> Copy bitstream file in current directory..."
mkdir -p ${PRJ_DIR}/bitstream/
cp ${PRJ_DIR}/<prj_name>/<prj_name>.runs/impl_1/<prj_name>.bit ${PRJ_DIR}/bitstream/<prj_name>.bit

echo "> Done"


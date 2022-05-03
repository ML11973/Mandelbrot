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
# Description: Generate Vitis workspace for software applications
#
# Last update: <update_time>
#
##################################################################################

XSDK_LIMIT_VERSION="2017.4"

# @brief Compare version strings
# @param $1 The current version to be compared
# @param $2 The version to be compared with
# @return 0 if the current version is greater or equal to the compared version
#         1 otherwise
cmp_version () {
 if [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]; then 
        return 0
 else
        return 1
 fi
}

if cmp_version "<tool_version>" $XSDK_LIMIT_VERSION; then
  echo "> Generate Vitis workspace software applications"
  xsct gen_sw_apps_<prj_name>.tcl
else
  echo "> Generate SDK workspace software applications"
  xsdk -batch -source ./gen_sw_apps_<prj_name>.tcl -notrace
fi

echo "> Done"

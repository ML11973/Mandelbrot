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
# Author: Joachim Schmidt <joachim.schmidt@hesge.ch
#
# Project Name: lpsc_mandelbrot_firmware
# Target Device: digilentinc.com:nexys_video:part0:1.1 xc7a200tsbg484-1
# Tool version: 2021.2
# Description: Generate Vitis workspace for software applications
#
# Last update: 2022-04-12 12:06:07
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

if cmp_version "2021.2" $XSDK_LIMIT_VERSION; then
  echo "> Generate Vitis workspace software applications"
  xsct gen_sw_apps_lpsc_mandelbrot_firmware.tcl
else
  echo "> Generate SDK workspace software applications"
  xsdk -batch -source ./gen_sw_apps_lpsc_mandelbrot_firmware.tcl -notrace
fi

echo "> Done"

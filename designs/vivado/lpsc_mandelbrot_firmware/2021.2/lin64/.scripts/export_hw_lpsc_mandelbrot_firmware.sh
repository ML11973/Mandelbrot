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
# Description: Export the hardware design to SDK
#
# Last update: 2022-04-12 12:06:07
#
##################################################################################

echo "> Export the hardware design to SDK"

vivado -nojournal -nolog -mode tcl -source ./export_hw_lpsc_mandelbrot_firmware.tcl -notrace

echo "> Done"


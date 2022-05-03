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
# Description: Generate bitstream file
#
# Last update: 2022-04-12 12:06:07
#
##################################################################################

PRJ_DIR=..

echo "> Generate bitstream file..."
vivado -nojournal -nolog -mode tcl -source ./gen_bitstream_lpsc_mandelbrot_firmware.tcl -notrace

echo "> Copy bitstream file in current directory..."
mkdir -p ${PRJ_DIR}/bitstream/
cp ${PRJ_DIR}/lpsc_mandelbrot_firmware/lpsc_mandelbrot_firmware.runs/impl_1/lpsc_mandelbrot_firmware.bit ${PRJ_DIR}/bitstream/lpsc_mandelbrot_firmware.bit

echo "> Done"


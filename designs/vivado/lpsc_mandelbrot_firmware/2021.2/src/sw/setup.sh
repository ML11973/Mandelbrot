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
# Description: TCL script creating aliases for Vitis workspace management scripts
#
# Last update: 2022-04-12 12:06:07
#
##################################################################################

# Create aliases
alias gen_sw_apps='cd .scripts && ./gen_sw_apps_lpsc_mandelbrot_firmware.sh && cd ..'
# TODO: Not supported yet
#alias load_sw_app='cd .scripts && ./load_sw_app_lpsc_mandelbrot_firmware.sh && cd ..'
alias open_sdk='cd .scripts && ./open_sdk_lpsc_mandelbrot_firmware.sh && cd ..'
alias clean_sdk='cd .scripts && ./clean_sdk_lpsc_mandelbrot_firmware.sh && cd ..'

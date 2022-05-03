#!/bin/sh

################################################################
#                     _             _      
#                    | |_  ___ _ __(_)__ _ 
#                    | ' \/ -_) '_ \ / _` |
#                    |_||_\___| .__/_\__,_|
#                             |_|          
#
################################################################
#
# Company: hepia
# Engineer: Laurent Gantel <laurent.gantel@hesge.ch>
#
# Project Name: Vivado Project Generator
# Version: 0.5.3
#
# File: run.sh
# Description: Vivado Project Creator run script
#
# Last update: 2021-09-24
#
#################################################################

# Execute the main application script in no-debug mode
# (-O: optimized => __debug__ = False)
PYTHON_OPT="-O"

# Check for configuration file argument
if [ $# -ge 1 ]
then
	SCRIPT_OPT="-c $1"
fi

python3 ${PYTHON_OPT} src/vivado_prj_creator.py ${SCRIPT_OPT}

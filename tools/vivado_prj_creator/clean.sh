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
# Description: Vivado Project Creator cleanup script
#
# Last update: 2021.09.24
#
#################################################################

# Remove Python cache files
find . -name "__pycache__" -type d -exec rm -rf {} +


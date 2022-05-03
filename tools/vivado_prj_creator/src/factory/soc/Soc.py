#!/usr/bin/python

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
# Version: 0.5
#
# File: Soc.py
# Description: Soc basis class
#
# Last update: 2021/05/09
#
#################################################################

class Soc:
    def __init__(self):
        self.prj_gen_dir = '../../soc/vivado'
        self.comp_src_dir = '../../soc/hw'

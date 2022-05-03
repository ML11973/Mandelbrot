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
# File: Packages.py
# Description: Packages basis class
#
# Last update: 2021/05/09
#
#################################################################

class Packages:
    def __init__(self):
        self.prj_gen_dir = '../../packages/vivado'
        self.comp_src_dir = '../../packages/hw'

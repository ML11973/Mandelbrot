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
# File: Ips.py
# Description: Ips basis class
#
# Last update: 2021/05/07
#
#################################################################

class Ips():
    def __init__(self):
        self.prj_gen_dir = '../../ips/vivado'
        self.comp_src_dir = '../../ips/hw'

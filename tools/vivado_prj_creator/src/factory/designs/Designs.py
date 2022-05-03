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
# File: Designs.py
# Description: Designs basis class
#
# Last update: 2021/05/09
#
#################################################################

class Designs:
    def __init__(self):
      self.prj_gen_dir = '../../designs/vivado'
      # By default, the component directory for a design is set to the IPs directory
      self.comp_src_dir = '../../ips/hw'

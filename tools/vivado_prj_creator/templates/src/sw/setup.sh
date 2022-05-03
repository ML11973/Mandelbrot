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
# Author: <author>
#
# Project Name: <prj_name>
# Target Device: <board_name> <part_name>
# Tool version: <tool_version>
# Description: TCL script creating aliases for Vitis workspace management scripts
#
# Last update: <update_time>
#
##################################################################################

# Create aliases
alias gen_sw_apps='cd .scripts && ./gen_sw_apps_<prj_name>.sh && cd ..'
# TODO: Not supported yet
#alias load_sw_app='cd .scripts && ./load_sw_app_<prj_name>.sh && cd ..'
alias open_sdk='cd .scripts && ./open_sdk_<prj_name>.sh && cd ..'
alias clean_sdk='cd .scripts && ./clean_sdk_<prj_name>.sh && cd ..'

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
# Description: TCL script creating aliases for Vivado project management scripts
#
# Last update: <update_time>
#
##################################################################################

# Create aliases
alias create_project='cd .scripts && ./create_prj_<prj_name>.sh && cd ..'
alias clean_project='cd .scripts && ./clean_prj_<prj_name>.sh && cd ..'
alias export_hw='cd .scripts && ./export_hw_<prj_name>.sh && cd ..'
alias gen_bitstream='cd .scripts && ./gen_bitstream_<prj_name>.sh && cd ..'
alias load_bitstream='cd .scripts && ./load_bitstream_<prj_name>.sh && cd ..'
alias open_gui='cd .scripts && ./open_prj_<prj_name>.sh && cd ..'

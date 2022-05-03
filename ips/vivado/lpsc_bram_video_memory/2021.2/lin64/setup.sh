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
# Project Name: lpsc_bram_video_memory
# Target Device: digilentinc.com:nexys_video:part0:1.1 xc7a200tsbg484-1
# Tool version: 2021.2
# Description: TCL script creating aliases for Vivado project management scripts
#
# Last update: 2022-02-28 10:28:02
#
##################################################################################

# Create aliases
alias create_project='cd .scripts && ./create_prj_lpsc_bram_video_memory.sh && cd ..'
alias clean_project='cd .scripts && ./clean_prj_lpsc_bram_video_memory.sh && cd ..'
alias export_hw='cd .scripts && ./export_hw_lpsc_bram_video_memory.sh && cd ..'
alias gen_bitstream='cd .scripts && ./gen_bitstream_lpsc_bram_video_memory.sh && cd ..'
alias load_bitstream='cd .scripts && ./load_bitstream_lpsc_bram_video_memory.sh && cd ..'
alias open_gui='cd .scripts && ./open_prj_lpsc_bram_video_memory.sh && cd ..'

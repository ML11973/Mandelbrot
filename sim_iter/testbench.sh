#!/bin/sh
# Mandelbrot iterator testbench using ghdl and gtkwave
# Commands from https://www.physi.uni-heidelberg.de/~angelov/VHDL/VHDL_SS09_Teil05.pdf

# Analyze DUV
ghdl -a ../src/iterator.vhd

# Analyze TB
ghdl -a -fsynopsys iterator_tb.vhd
#ghdl -a zc_adder_tb.vhd

# Generate exe
ghdl -e iterator_tb

# Run simulation
ghdl -r iterator_tb --vcd=zc_adder_tb.vcd --stop-time=3us

# View waveform
gtkwave iterator_tb.vcd

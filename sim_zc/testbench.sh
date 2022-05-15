#!/bin/sh
# Mandelbrot single stage testbench using ghdl and gtkwave
# Commands from https://www.physi.uni-heidelberg.de/~angelov/VHDL/VHDL_SS09_Teil05.pdf
#DESIGN="zc_adder"

# Analyze DUV
ghdl -a ../src/zc_adder.vhd

# Analyze TB
ghdl -a -fsynopsys zc_adder_tb.vhd
#ghdl -a zc_adder_tb.vhd

# Generate exe
ghdl -e zc_adder_tb

# Run simulation
ghdl -r zc_adder_tb --vcd=zc_adder_tb.vcd --stop-time=3us

# View waveform
gtkwave zc_adder_tb.vcd

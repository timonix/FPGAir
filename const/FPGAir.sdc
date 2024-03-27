//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.09 Education
//Created Time: 2023-03-06 22:21:52
//create_clock -name sys_clk -period 10 -waveform {0 5} [get_ports {sys_clk}]
//create_clock -name clka -period 10 -waveform {0 5} [get_ports {clka}]
create_clock -name clk -period 10 -waveform {0 5} [get_ports {clk}]

set_device GW1NR-LV9QN88PC6/I5 -name GW1NR-9C
add_file const/FPGAir.sdc
add_file modules/mpu6050/rtl/brute_6050.vhd
add_file modules/data_unloader/data_unloader.vhd
add_file modules/sequencer/sequencer.vhd
add_file packages/common_pkg.vhd
add_file modules/sequencer/sequencer.cst
set_option -use_mspi_as_gpio 1
set_option -use_sspi_as_gpio 1
set_option -rw_check_on_ram 1
set_option -synthesis_tool gowinsynthesis
set_option -verilog_std sysv2017
set_option -vhdl_std vhd2008
set_option -gen_sdf 0
set_option -gen_posp 0
set_option -top_module sequencer
run all

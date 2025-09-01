set_device GW1NR-LV9QN88PC6/I5 -name GW1NR-9C
add_file const/FPGAir.sdc
add_file packages/common_pkg.vhd
add_file modules/beagle_cpu/beagle.vhd
add_file modules/beagle_cpu/beagle_bus.vhd
add_file modules/beagle_cpu/beagle_pkg.vhd
add_file modules/eager_cpu/eager.vhd
add_file modules/eager_cpu/eager_bus_router.vhd
add_file modules/eager_cpu/eager_pkg.vhd
add_file modules/uart_rx/uart_rx.vhd
add_file modules/beagle_cpu/hw_test/balloon_top.vhd
add_file modules/beagle_cpu/hw_test/balloon_top_tb.vhd
add_file modules/beagle_cpu/sim/beagle_sim.vhd
add_file modules/data_unloader/rtl/data_unloader.vhd
add_file modules/motor/rtl/pulser.vhd
add_file modules/mpu6050/rtl/brute_6050.vhd
add_file modules/radio/rtl/arming.vhd
add_file modules/radio/rtl/radio_channel.vhd
add_file modules/sequencer/rtl/sequencer.vhd
add_file modules/beagle_cpu/hw_test/balloon_top.cst
set_option -use_mspi_as_gpio 1
set_option -use_sspi_as_gpio 1
set_option -rw_check_on_ram 1
set_option -synthesis_tool gowinsynthesis
set_option -verilog_std sysv2017
set_option -vhdl_std vhd2008
set_option -gen_sdf 0
set_option -gen_posp 0
set_option -top_module balloon_top
run all

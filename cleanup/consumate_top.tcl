set_device GW1NR-LV9QN88PC6/I5 -name GW1NR-9C
add_file packages/common_pkg.vhd
add_file modules/beagle_cpu/beagle.vhd
add_file modules/beagle_cpu/beagle_bus.vhd
add_file modules/beagle_cpu/beagle_pkg.vhd
add_file modules/eager_cpu/eager.vhd
add_file modules/eager_cpu/eager_bus_router.vhd
add_file modules/eager_cpu/eager_pkg.vhd
add_file modules/uart_rx/neo_uart_rx.vhd
add_file modules/uart_rx/uart_rx.vhd
add_file modules/beagle_cpu/hw_test/balloon_top.vhd
add_file modules/beagle_cpu/hw_test/consumate_top.vhd
add_file modules/data_unloader/rtl/baud_timer.vhd
add_file modules/data_unloader/rtl/buffered_data_unloader.vhd
add_file modules/data_unloader/rtl/data_unloader.vhd
add_file modules/motor/rtl/pulser.vhd
add_file modules/mpu6050/rtl/brute_6050.vhd
add_file modules/radio/rtl/arming.vhd
add_file modules/radio/rtl/radio_channel.vhd
add_file modules/reset/rtl/reset.vhd
add_file modules/sequencer/rtl/sequencer.vhd
add_file modules/uart_rx/hw_tb/tb_uart_rx_top.vhd
add_file consumate_top.cst
set_option -vhdl_std vhd2008
set_option -verilog_std sysv2017
set_option -rw_check_on_ram true
set_option -gen_sdf false
set_option -gen_posp false
set_option -gen_text_timing_rpt false
set_option -use_mspi_as_gpio false
set_option -use_sspi_as_gpio false
set_option -top_module consumate_top
run all

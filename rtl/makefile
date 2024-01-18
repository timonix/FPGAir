TOPLEVEL_LANG = vhdl
VHDL_SOURCES = $(PWD)/common_pkg.vhd \
               $(PWD)/mixer.vhd
TOPLEVEL = mixer
MODULE = mixer_py_test.py  # Name of the Python test file
SIM=ghdl
GHDL_FLAGS = --std=08


include $(shell cocotb-config --makefiles)/Makefile.sim


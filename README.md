# FPGAir

docker run -it --rm -v ${PWD}:/formal hdlc/formal bash -c "  cd /formal/formal &&  sby --yosys 'yosys -m ghdl' -f psl_mixer.sby"

docker run -it --rm -v ${PWD}:/formal hdlc/formal bash -c "  cd /formal/formal ;  sby --yosys 'yosys -m ghdl' -f psl_mixer.sby ; rm psl_mixer.vcd ;cp psl_mixer_bmc/engine_0/trace.vcd psl_mixer.vcd ; rm -r psl_mixer_bmc"

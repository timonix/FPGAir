FROM python:3.8

# Install GHDL for VHDL simulation
RUN apt-get update && apt-get install -y \
    ghdl \
    && rm -rf /var/lib/apt/lists/*

# Install Cocotb
RUN pip install cocotb
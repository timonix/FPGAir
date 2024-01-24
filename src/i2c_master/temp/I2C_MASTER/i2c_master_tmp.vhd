--Copyright (C)2014-2022 Gowin Semiconductor Corporation.
--All rights reserved.
--File Title: Template file for instantiation
--GOWIN Version: GowinSynthesis V1.9.8.09 Education
--Part Number: GW1NR-LV9QN88PC6/I5
--Device: GW1NR-9C
--Created Time: Sun Jan 21 01:30:20 2024

--Change the instance name and port connections to the signal names
----------Copy here to design--------

component I2C_MASTER_Top
	port (
		I_CLK: in std_logic;
		I_RESETN: in std_logic;
		I_TX_EN: in std_logic;
		I_WADDR: in std_logic_vector(2 downto 0);
		I_WDATA: in std_logic_vector(7 downto 0);
		I_RX_EN: in std_logic;
		I_RADDR: in std_logic_vector(2 downto 0);
		O_RDATA: out std_logic_vector(7 downto 0);
		O_IIC_INT: out std_logic;
		SCL: inout std_logic;
		SDA: inout std_logic
	);
end component;

your_instance_name: I2C_MASTER_Top
	port map (
		I_CLK => I_CLK_i,
		I_RESETN => I_RESETN_i,
		I_TX_EN => I_TX_EN_i,
		I_WADDR => I_WADDR_i,
		I_WDATA => I_WDATA_i,
		I_RX_EN => I_RX_EN_i,
		I_RADDR => I_RADDR_i,
		O_RDATA => O_RDATA_o,
		O_IIC_INT => O_IIC_INT_o,
		SCL => SCL_io,
		SDA => SDA_io
	);

----------Copy end-------------------

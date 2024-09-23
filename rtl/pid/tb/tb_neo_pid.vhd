library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;

entity tb_neo_pid is
end tb_neo_pid;

architecture tb of tb_neo_pid is
    
    constant integer_bits : integer := 12;
    constant fractional_bits : integer := 12;

    component neo_pid
    port (clk        : in std_logic;
        rst        : in std_logic;
        enable     : in boolean;
        update     : in boolean;
        data_valid : out boolean;
        A_setpoint : in sfixed (integer_bits-1 downto -fractional_bits);
        A_measured : in sfixed (integer_bits-1 downto -fractional_bits);
        A_output   : out sfixed (integer_bits-1 downto -fractional_bits);
        B_setpoint : in sfixed (integer_bits-1 downto -fractional_bits);
        B_measured : in sfixed (integer_bits-1 downto -fractional_bits);
        B_output   : out sfixed (integer_bits-1 downto -fractional_bits));
end component;

signal clk        : std_logic;
signal rst        : std_logic;
signal enable     : boolean;
signal update     : boolean;
signal data_valid : boolean;
signal A_setpoint : sfixed (integer_bits-1 downto -fractional_bits);
signal A_measured : sfixed (integer_bits-1 downto -fractional_bits);
signal A_output   : sfixed (integer_bits-1 downto -fractional_bits);
signal B_setpoint : sfixed (integer_bits-1 downto -fractional_bits);
signal B_measured : sfixed (integer_bits-1 downto -fractional_bits);
signal B_output   : sfixed (integer_bits-1 downto -fractional_bits);

constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

begin

    dut : neo_pid
    port map (clk        => clk,
        rst        => rst,
        enable     => enable,
        update     => update,
        data_valid => data_valid,
        A_setpoint => A_setpoint,
        A_measured => A_measured,
        A_output   => A_output,
        B_setpoint => B_setpoint,
        B_measured => B_measured,
        B_output   => B_output);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        enable <= false;
        update <= false;
        A_setpoint <= (others => '0');
        A_measured <= (others => '0');
        B_setpoint <= (others => '0');
        B_measured <= (others => '0');


        rst <= '1';
        wait for 5 * TbPeriod;
        rst <= '0';
        wait for 5 * TbPeriod;
        enable <= true;
        wait for 5 * TbPeriod;
        A_setpoint <= to_sfixed(0.0,A_setpoint);
        A_measured <= to_sfixed(100.0,A_setpoint);
        update <= true;

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;


        TbSimEnded <= '1';
        wait;
    end process;

end tb;
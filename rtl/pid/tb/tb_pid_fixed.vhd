library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity tb_pid_fixed is
end tb_pid_fixed;

architecture tb of tb_pid_fixed is

    

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal enable   : boolean;
    signal update   : boolean;
    signal setpoint : sfixed(11 downto -11) := to_sfixed(0.0, 11,-11);
    signal output_value : sfixed(11 downto -11);
    signal measured_value : sfixed(11 downto -11);
    
    
    constant TbPeriod : time := 37 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    pid_inst : entity work.pid_fixed(rtl)
    generic map (
        integer_bits => 12,
        fractional_bits => 11,
        Kp => 0.005,
        Ki => 0.001,
        Kd => 0.002
    )
    port map (
        clk      => clk,
        rst      => rst,
        enable   => enable,
        update   => update,
        setpoint => setpoint,
        measured => measured_value,
        output   => output_value
    );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    
    measured_value <= fixed_mul(output_value,to_sfixed(2.0, 11,-11));
    --output_real <= to_real(output_value);
    
    -- Connect main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- Initialization
        enable <= False;
        setpoint <= to_sfixed(50.0, 11,-11);
        update <= false;

        -- Reset generation
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Add stimuli here
        wait for 10 ns;
        enable <= True;
        update <= true;
        wait for TbPeriod;
        update <= false;
        wait for TbPeriod*10;
        for i in 0 to 3000 loop
            update <= true;
            wait for TbPeriod;
            update <= false;
            wait for TbPeriod*5;
        end loop;
            
        wait for 10 ns;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
        end process;

    end tb;




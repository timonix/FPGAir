library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity tb_pid_meta is
end tb_pid_meta;

architecture tb of tb_pid_meta is

    

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal enable   : boolean;
    signal update   : boolean;
    signal data_valid: boolean;
    signal setpoint : sfixed(10 downto -11) := to_sfixed(0.0, 10,-11);
    signal output_value : sfixed(10 downto -11);
    signal measured_value : sfixed(10 downto -11):= to_sfixed(0.0, 10,-11);
    
    signal last_measured : sfixed(10 downto -11) := to_sfixed(0.0, 10,-11);
    
    constant TbPeriod : time := 37 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    pid_inst : entity work.pid(rtl)
    generic map (
        integer_bits => 11,
        fractional_bits => 11,
        Kp => 0.005,
        Ki => 0.001,
        Kd => 0.002
    )
    port map (
        clk  => clk,
        rst => rst,
        enable => true,
        update => update,
        
        data_valid => data_valid,
        
        A_setpoint => (others => '0'),
        A_measured => (others => '0'),
        A_output =>open,--output_value,
        
        B_setpoint =>setpoint,
        B_measured =>measured_value,
        B_output   =>output_value
    );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    
    
    
    
    --output_real <= to_real(output_value);
    
    -- Connect main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- Initialization
        enable <= False;
        setpoint <= to_sfixed(50.0, 10,-11);
        update <= false;
        measured_value <= to_sfixed(1.0, 10,-11);
        last_measured <= to_sfixed(0.0, 10,-11);
        

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
        for i in 0 to 2000 loop
            --last_measured <= measured_value;
            --measured_value <= fixed_add(last_measured, output_value);
            wait for TbPeriod;
            update <= true;
            wait for TbPeriod;
            update <= false;
            wait for TbPeriod * 100;
            last_measured <= measured_value;
            TbSimEnded <= '1';
            wait for 0.01 ms;
            measured_value <= fixed_add(last_measured, output_value);
            TbSimEnded <= '0';
        end loop;
            
        wait for 10 ns;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
        end process;

    end tb;




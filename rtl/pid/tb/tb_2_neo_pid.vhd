library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;
use IEEE.math_real.all;
use std.textio.all;
use work.csv_file_reader_pkg.all;



entity tb_2_neo_pid is
end entity tb_2_neo_pid;

architecture rtl of tb_2_neo_pid is
    
    constant integer_bits : integer := 12;
    constant fractional_bits : integer := 12;
    
    signal clk,rst : std_logic := '0';
    signal update : boolean := false;
    
    signal A_setpoint    : sfixed (integer_bits-1 downto -fractional_bits);
    signal A_measured    : sfixed (integer_bits-1 downto -fractional_bits);
    signal A_output      : sfixed (integer_bits-1 downto -fractional_bits);
    signal target_output : sfixed (integer_bits-1 downto -fractional_bits);

begin

    neo_pid_inst: entity work.neo_pid
    generic map(
        integer_bits => integer_bits,
        fractional_bits => fractional_bits,
        A_enabled => True,
        Kp => 2.0,
        Ki => 0.1,
        Kd => 1.0
    )
    port map(
        clk => clk,
        rst => rst,
        enable => true,
        update => update,
        A_setpoint => A_setpoint,
        A_measured => A_measured,
        A_output => A_output
    );
    
    test_process: process
    variable csv_file_1: csv_file_reader_type;
    variable time_step : integer;
    
    procedure clock(constant n: in integer := 1) is
    begin
        for i in 1 to n loop
            clk <= '1';
            wait for 10 ns;
            clk <= '0';
            wait for 10 ns;
        end loop;
    end procedure;
    
    begin
        csv_file_1.initialize("C:\Users\tjade\OneWareStudio\Projects\FPGAir\rtl\pid\tb\test_data_tb2.txt");

        rst <= '1';
        clock;
        rst <= '0';
        clock;
        for i in 0 to 3 loop
            csv_file_1.readline;
            time_step := csv_file_1.read_integer;
            A_setpoint    <= to_sfixed(csv_file_1.read_real,A_setpoint);
            A_measured    <= to_sfixed(csv_file_1.read_real,A_measured);
            target_output <= to_sfixed(csv_file_1.read_real,target_output);
            update <= true;
            clock;
            update <= false;
            clock(10);
        end loop;
        

        
        wait;


    end process;
end architecture;
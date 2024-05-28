library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.fixed_pkg.all;

entity tb_rolling_average_filter_sfixed is
end entity tb_rolling_average_filter_sfixed;

architecture sim of tb_rolling_average_filter_sfixed is
    constant taps : integer := 8;
    
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal update: boolean := false;
    signal i_data: sfixed(16-1 downto -5);
    signal o_data: sfixed(16-1 downto -8);
    
    constant clk_period : time := 10 ns;
    
begin
    -- Instantiate the rolling_average_filter
    uut: entity work.rolling_average_filter_sfixed
    generic map (
        taps => taps,
        data_in_integer_bits => 16,
        data_in_fractional_bits => -5
    )
    port map (
        clk   => clk,
        reset => reset,
        update => update,
        i_data => i_data,
        o_data => o_data
    );
    
    -- Clock process
    clk_process: process
    begin
        while now < 1000 ns loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Reset
        reset <= '1';
        wait for clk_period*2;
        reset <= '0';
        wait for clk_period*2;
        wait for clk_period;

        -- Provide input data
        for i in 1 to 15 loop
            i_data <= to_sfixed(i, i_data);
            update <= true;
            wait for clk_period;
            update <= false;
            wait for clk_period;
        end loop;
        
        for i in 1 to 15 loop
            update <= true;
            wait for clk_period;
            update <= false;
            wait for clk_period;
        end loop;
        
        wait for clk_period*100;
        
        -- Add more test cases as needed
        
        wait;
    end process;
    
end architecture sim;
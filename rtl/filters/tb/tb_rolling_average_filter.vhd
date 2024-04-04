library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_rolling_average_filter is
end entity tb_rolling_average_filter;

architecture sim of tb_rolling_average_filter is
    constant taps : integer := 8;
    constant data_width : integer := 16;
    
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal update: boolean := false;
    signal i_data: signed(data_width-1 downto 0);
    signal o_data: signed(data_width-1 downto 0);
    
    constant clk_period : time := 10 ns;
    
begin
    -- Instantiate the rolling_average_filter
    uut: entity work.rolling_average_filter
        generic map (
            taps => taps,
            data_width => data_width
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
        wait for clk_period;
        
        -- Provide input data
        for i in 0 to 15 loop
            i_data <= to_signed(i, data_width);
            update <= true;
            wait for clk_period;
            update <= false;
            wait for clk_period;
        end loop;
        
        -- Add more test cases as needed
        
        wait;
    end process;
    
end architecture sim;
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity tb_map is
end tb_map;

architecture tb of tb_map is

    signal source : sfixed(4 downto 0) := (others => '0');
    signal target : sfixed(6 downto -6) := (others => '0');
    
    signal clk      : std_logic;
    signal rst      : std_logic;
    
    constant TbPeriod : time := 37 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin


    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    

    --output_real <= to_real(output_value);
    
    -- Connect main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- Initialization
        
        source <= "10001";
        
        wait for 10 ns;
        target <= map_onto(source,target);
        wait for 10 ns;


        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
        end process;

    end tb;




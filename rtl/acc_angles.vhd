
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity acc_angles is
    generic (
        frequency_mhz : real := 27.0;
        iterations : NATURAL := 20
    );
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        i_enable : in BOOLEAN;
        i_update : in BOOLEAN;
        o_accelerometer_estimate : out attitude;
        o_done : out BOOLEAN
    );
end entity acc_angles;

architecture rtl of acc_angles is
    --[signals]
    
begin
    
    process(clk)
    variable update_active : BOOLEAN;
    variable iteration_counter : NATURAL range 0 to iterations := 0;
    begin
        
        if rising_edge(clk) then
            
            if i_update then
                update_active <= true;
            end if;
            
            if update_active = true then
                
                
                
            end if;
            
            if iteration_counter >= iterations then
                update_active <= false;
                o_done <= true;
            end if;
            
            if not i_enable or rst = '1' then
                update_active <= false;
                
            end if;
            
        end if;
    end process;
end architecture rtl;







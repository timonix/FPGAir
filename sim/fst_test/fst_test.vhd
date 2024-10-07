library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;
use IEEE.math_real.all;

entity fst_test is
end entity fst_test;

architecture rtl of fst_test is
    signal A : std_logic;
begin

    stimuli : process
    begin
        
        A <= '0';
        wait for 100 ns;
        A <= '1';
        wait for 100 ns;

        wait;
    end process;

end architecture;
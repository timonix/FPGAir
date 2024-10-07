library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;

entity psl_test is
    port (
        clk   : in std_logic;
        reset : in std_logic;
        input : in unsigned(8 downto 0);
        output : out unsigned(8 downto 0)
        
    );
end entity psl_test;

architecture rtl of psl_test is

begin

    process (clk)
    begin
        if rising_edge(clk) then
            
            output <= input +1;
            if reset = '1' then
                output <= (others => '0');
            end if;
        end if;
    end process;
    
    -- psl default clock is rising_edge(clk);
    
    -- psl test_0 : assert always (output > input);


end architecture;
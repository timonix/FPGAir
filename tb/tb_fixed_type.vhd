library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;

use work.common_pkg.all;
--use work.fixed_point_pkg.all;

entity tb_fixed_type is
end tb_fixed_type;

architecture tb of tb_fixed_type is
    
    signal sig :unresolved_sfixed(3 downto -2);

    signal clk       : std_logic;
    signal mul_a     : sfixed(4-1 downto -3) := "0010100"; -- 2.5
    signal mul_b     : sfixed(2-1 downto -4) := "011000"; --1.5
    signal real_test : sfixed(5-1 downto -6) := to_sfixed(1.5,4,-6);
    signal mul_res   : sfixed(4+2-1 downto -7);
    
    signal a         : sfixed(4 downto -3);
    signal b         : sfixed(7 downto -3);
    signal c         : sfixed(4 downto -5);
    signal d         : sfixed(8 downto -5);
    
    signal f         : sfixed(3 downto -3);
    signal g         : sfixed(4 downto -2);
    signal h         : sfixed(3 downto -2);
    

    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;
    
    

    stimuli : process
    begin
        
        a <= "00001000";
        a <= fixed_add(a,a);
        wait for 10*TbPeriod;
        b <= resize(a,b'high,b'low);
        wait for 10*TbPeriod;
        assert a = b(a'range) report "extend left failed";
        
        c <= resize(a,c'high,c'low);
        wait for 10*TbPeriod;
        assert a = c(a'range) report "extend right failed";
        
        d <= resize(a,d'high,d'low);
        wait for 10*TbPeriod;
        assert a = d(a'range) report "extend both failed";
        
        f <= resize(a,f'high,f'low);
        wait for 10*TbPeriod;
        assert a(f'range) = f report "shrink left failed";
        
        g <= resize(a,g'high,g'low);
        wait for 10*TbPeriod;
        assert a(g'range) = g report "shrink right failed";
        
        h <= resize(a,h'high,h'low);
        wait for 10*TbPeriod;
        assert a(h'range) = h report "shrink both failed";
        
        mul_res <= mul_a*mul_b;
        
        wait for 100*TbPeriod;
        

        TbSimEnded <= '1';
        wait;
    end process;

end tb;
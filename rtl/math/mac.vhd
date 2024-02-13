
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity mac_sfixed is
    generic (
    A_integer_bits : integer := 11;
    A_fractional_bits : integer := 11;
    B_integer_bits : integer := 11;
    B_fractional_bits : integer := 11;
    C_integer_bits : integer := 11;
    C_fractional_bits : integer := 11;
    O_integer_bits : integer := 11;
    O_fractional_bits : integer := 11
    );
    
    port(
        clk : in STD_LOGIC;
        A   : in sfixed(A_integer_bits-1 downto -A_fractional_bits);
        B   : in sfixed(B_integer_bits-1 downto -B_fractional_bits);
        C   : in sfixed(C_integer_bits-1 downto -C_fractional_bits);
        O   : out sfixed(O_integer_bits-1 downto -O_fractional_bits)
    );
end entity mac_sfixed;

architecture rtl of mac_sfixed is
    signal tmp : sfixed(O_integer_bits-1 downto -O_fractional_bits);
    
    signal tmp_a : sfixed(A_integer_bits-1 downto -A_fractional_bits);
    signal tmp_b : sfixed(B_integer_bits-1 downto -B_fractional_bits);
    
    constant zero : sfixed(O_integer_bits-1 downto -O_fractional_bits) := (others => '0');
begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            tmp_a <= A;
            tmp_b <= B;
            tmp <= cum_mul(tmp_a, tmp_b, zero);
            O <= fixed_add(tmp,C);
            
        end if;
    end process;

end architecture rtl;


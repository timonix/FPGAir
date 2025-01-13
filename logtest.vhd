library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.fixed_pkg.all;

entity logtest is
end entity logtest;

architecture rtl of logtest is
    signal b : ufixed(4 downto -4) := to_ufixed(3.25125,4,-4);
    signal r : real;
    signal rr :ufixed(4 downto -4);
begin
    r <= 2**(-ceil(log2(Real(to_integer(b)))));
    rr <= to_ufixed(r,rr);

    

end architecture;
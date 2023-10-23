
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity cordic_acc is
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        x_acc : in sfixed(0 downto -16);
        y_acc : in sfixed(0 downto -16);
        z_acc : in sfixed(0 downto -16);
        x_new : out sfixed(0 downto -16);
        y_new : out sfixed(0 downto -16);
        z_new : out sfixed(0 downto -16)
    );
end entity cordic_acc;

architecture rtl of cordic_acc is
    
begin

    process(clk)
    variable d : INTEGER;
    begin
        
        x_new <= x_acc
        
    end process;

end architecture rtl;



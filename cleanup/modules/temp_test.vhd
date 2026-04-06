library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity temp_test is
    port (

        led   : out std_logic;
        ledn  : out std_logic;
        button : in std_logic

    );
end entity temp_test;

architecture rtl of temp_test is

begin

    led <= button;
    ledn <= not button;

end architecture;
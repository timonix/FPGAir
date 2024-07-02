-----------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rg_top is
    port (
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        sda   : inout std_logic;
        scl   : inout std_logic
        
    );
end entity rg_top;

architecture Behavioral of rg_top is
    

begin


    DUT: entity work.mpu_rg(SOLUCION)

    port map (
        CLOCK_50     => clk,
        reset_n     => not rst,
        en => '1',
        I2C_SDAT => sda,
        I2C_SCLK  => scl,
        gx  => open,
        gy  => open,
        gz  => open,
        ax  => open,
        ay  => open,
        az    => open
    );

end Behavioral;
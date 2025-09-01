library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eager_bus_router is
    generic (
        data_width : integer := 32
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;
        
        eager_bus_addr     : in  unsigned(6 downto 0);
        eager_bus_data_in  : out signed(data_width-1 downto 0);
        eager_bus_data_out : in  signed(data_width-1 downto 0);
        eager_bus_write    : in  boolean
        
    );
end entity eager_bus_router;

architecture rtl of eager_bus_router is

begin

    

end architecture;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_test_top is
    port (
        -- Define the external ports for the uart_system
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        tx : out STD_LOGIC;
        rx : in STD_LOGIC
        -- other ports as required
    );
end entity uart_test_top;

architecture Behavioral of uart_test_top is
    
    signal data : STD_LOGIC_VECTOR(7 downto 0);
    signal data_valid : boolean;

begin
    

    DUT: entity work.uart_rx_small(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0
    )
    port map (clk        => clk,
        rst        => rst,
        enable     => true,
        rx         => rx,
        data       => data,
        data_valid => data_valid);
    
    DUT2: entity work.uart_tx(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0
    )
    port map (clk        => clk,
        rst        => rst,
        enable     => true,
        tx         => tx,
        data       => data,
        ready => open,
        data_valid => data_valid);

end Behavioral;
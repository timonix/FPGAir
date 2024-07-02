-----------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rx_multi_feedback_top is
    port (
        -- Define the external ports for the uart_system
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        tx : out STD_LOGIC;
        rx : in STD_LOGIC
        -- other ports as required
    );
end entity rx_multi_feedback_top;



architecture Behavioral of rx_multi_feedback_top is
    
    signal data : STD_LOGIC_VECTOR(15 downto 0);
    signal ready : boolean;

    signal s_tx : std_logic;
    
    signal byte_valid : boolean;

begin

    rx_inst: entity work.uart_multi_rx(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0,
        num_bytes => 2
    )
    port map (clk  => clk,
        rst        => rst,
        enable     => true,
        rx         => rx,
        data       => data,
        data_valid => byte_valid);

    DUT: entity work.data_unloader(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0,
        boot_message  => "FPGAir data unload test:",
        delimiter     => 'D',
        num_bytes     => 2
    )
    port map (
        clk     => clk,
        rst     => rst,
        o_ready => ready,
        i_valid => byte_valid,
        i_data  => data,
        o_tx    => tx
    );

end Behavioral;
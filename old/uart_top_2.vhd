-----------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_top_2 is
    port (
        -- Define the external ports for the uart_system
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        tx : out STD_LOGIC;
        tx_2 : out STD_LOGIC
        -- other ports as required
    );
end entity uart_top_2;

architecture Behavioral of uart_top_2 is

    signal tx_int : STD_LOGIC;
    

    component uart_tx_small is
        generic (
            frequency_mhz : real;
            baud_rate_mhz : real
        );
        port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            enable : in boolean;
            tx : out STD_LOGIC;
            data : in STD_LOGIC_VECTOR(7 downto 0);
            data_valid : in boolean;
            ready : out boolean
        );
    end component;

    -- Signal Declarations
    signal adapter_to_tx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal data_valid_signal, ready_signal : boolean;

begin


    -- UART TX Instance
    tx_instance : uart_tx_small
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0
    )
    port map (
        clk => clk,
        rst => rst,
        enable => true, -- connect as needed,
        tx => tx_int, -- external tx output,
        data => x"A5",
        data_valid => false,
        ready => open
    );

    tx <= tx_int;
    tx_2 <= tx_int;
    -- Additional logic as required to manage data flow

end Behavioral;
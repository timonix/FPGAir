-----------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_system is
    port (
        -- Define the external ports for the uart_system
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        tx : out STD_LOGIC;
        tx_2 : out STD_LOGIC
        -- other ports as required
    );
end entity uart_system;

architecture Behavioral of uart_system is

    signal tx_int : STD_LOGIC;
    
    -- Component Declarations
    component uart_adapter is
        generic (
            frequency_mhz : real;
            baud_rate_mhz : real;
            num_bytes_in : natural
        );
        port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            enable : in boolean;
            data_in : in STD_LOGIC_VECTOR(num_bytes_in * 8 - 1 downto 0);
            data_valid_in : in boolean;
            ready : out boolean;
            data_out : out STD_LOGIC_VECTOR(7 downto 0);
            data_valid_out : out boolean;
            uart_ready : in boolean
        );
    end component;

    component uart_tx is
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
    
    signal data : unsigned(15 downto 0);
    signal ready : boolean;

begin
    
    process (clk)
    begin
        if rising_edge(clk) then
            if ready then
                data <= data +1;
            end if;
        end if;

    end process;

    -- UART Adapter Instance
    adapter_instance : uart_adapter
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0,
        num_bytes_in => 2
    )
    port map (
        clk => clk,
        rst => rst,
        enable => true, -- connect as needed,
        data_in => x"AB2F", -- connect as needed,
        data_valid_in => true, -- connect as needed,
        ready => ready,
        data_out => adapter_to_tx_data,
        data_valid_out => data_valid_signal,
        uart_ready => ready_signal -- connect as needed
    );

    -- UART TX Instance
    tx_instance : uart_tx
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0
    )
    port map (
        clk => clk,
        rst => rst,
        enable => true, -- connect as needed,
        tx => tx_int, -- external tx output,
        data => adapter_to_tx_data,
        data_valid => data_valid_signal,
        ready => ready_signal
    );

    tx <= tx_int;
    tx_2 <= tx_int;
    -- Additional logic as required to manage data flow

end Behavioral;
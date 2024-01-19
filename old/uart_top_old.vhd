library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_top_old is
    port(
        sys_clk         : in  std_logic;
        sys_rst_n       : in  std_logic;
        tx              : out STD_LOGIC;
        rx              : in STD_LOGIC
    );
end entity uart_top_old;

architecture rtl of uart_top_old is
    
    signal uart_data : STD_LOGIC_VECTOR(7 downto 0);
    signal uart_data_valid : BOOLEAN;
    
    COMPONENT uart_tx IS
        port (
            clk           : in STD_LOGIC;
            rst           : in STD_LOGIC;
            enable        : in boolean;
            tx            : out STD_LOGIC;
            data          : in STD_LOGIC_VECTOR(7 downto 0);
            data_valid    : in boolean;
            ready         : out boolean
        );
    end component uart_tx;
    
    COMPONENT uart_rx IS
        port (
            clk           : in STD_LOGIC;
            rst           : in STD_LOGIC;
            enable        : in boolean;
            rx            : in STD_LOGIC;
            data          : out STD_LOGIC_VECTOR(7 downto 0);
            data_valid    : out boolean
        );
    end component uart_rx;
    
begin
    
    tx_module : uart_tx
    port map (
        clk           => sys_clk,
        rst           => sys_rst_n,
        enable        => TRUE,
        tx            => tx,
        data          => uart_data,
        data_valid    => uart_data_valid,
        ready         => open
    );
    
    rx_module : uart_rx
    port map (
        clk           => sys_clk,
        rst           => sys_rst_n,
        enable        => TRUE,
        rx            => rx,
        data          => uart_data,
        data_valid    => uart_data_valid
    );
    
    

end architecture rtl;
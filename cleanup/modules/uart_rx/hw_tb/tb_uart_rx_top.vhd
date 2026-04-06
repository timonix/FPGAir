library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity tb_uart_rx_top is
    generic (
        frequency_mhz : real := 27.0;
        baud_rate_mhz : real := 115200.0/1000000.0
    );
    port (
        clk   : in std_logic;
        resetn : in std_logic;
        ext_rx : in std_logic;
        ext_led : out std_logic
    );
end entity tb_uart_rx_top;

architecture rtl of tb_uart_rx_top is
    signal reset : std_logic;
    signal rx_data : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_data_valid : boolean;
    signal led : std_logic;
    signal q_ext_rx : std_logic;
    signal qq_ext_rx : std_logic;
begin
    ext_led <= led;
    process (clk)
    begin
        if rising_edge(clk) then
            q_ext_rx <= ext_rx;
            qq_ext_rx <= q_ext_rx;
            if reset = '1' then
                led <= '0';
            end if;
            if rx_data_valid then
                led <= '1';
            end if;
        end if;
    end process;
    
    reset <= not resetn;
    
    neo_UART_RX_inst: entity work.neo_UART_RX
    generic map(
        g_CLKS_PER_BIT => integer(floor(frequency_mhz/baud_rate_mhz))
    )
    port map(
        i_clk => clk,
        i_rx => ext_rx,
        o_rx_valid => rx_data_valid,
        o_rx_data => rx_data
    );
    
end architecture;
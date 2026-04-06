library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity tb_uart_rx is
end entity tb_uart_rx;

architecture rtl of tb_uart_rx is
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal rx  : std_logic := '1';
    signal data : STD_LOGIC_VECTOR(7 downto 0);
    signal data_valid : boolean;
    
    constant CLK_PERIOD : time := 37.037037 ns;
begin
    
    process
    begin
        wait for CLK_PERIOD/2;
        clk <= not clk;
    end process;
    
    process
    begin
        wait for 100 ns;
        rst <= '0';
        wait;
    end process;
    
    process
    begin

        wait for 20 us;
        wait for CLK_PERIOD*10;
        rx <= '0';
        wait for 8.68055556 us;
        rx <= '1';
        wait for 8.68055556 us;
        rx <= '0';
        wait for 8.68055556 us;
        rx <= '1';
        wait for 100 us;
        assert false report "END" severity FAILURE;
        wait;
    end process;

    uart_rx_inst: entity work.uart_rx
    generic map(
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0
    )
    port map(
        clk => clk,
        rst => rst,
        enable => true,
        rx => rx,
        data => data,
        data_valid => data_valid
    );

end architecture;
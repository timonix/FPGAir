library ieee;
use ieee.std_logic_1164.all;

entity tb_uart_tx_stream is
end tb_uart_tx_stream;

architecture sim of tb_uart_tx_stream is

    -- Instantiate the DUT (Device Under Test)
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal o_ready     : boolean := false;
    signal i_valid     : boolean := false;
    signal i_data      : std_logic_vector(7 downto 0) := (others => '0');
    signal o_tx        : std_logic;

    constant clk_period : time := 37 ns;  -- assuming 27 MHz for simplicity, adjust accordingly
    
    signal TbSimEnded : boolean := false;
    
begin

    -- DUT
    DUT: entity work.uart_tx_stream(rtl)
    port map (
        clk      => clk,
        rst      => rst,
        o_ready  => o_ready,
        i_valid  => i_valid,
        i_data   => i_data,
        o_tx     => o_tx
    );

    clk <= not clk after clk_period / 2 when not TbSimEnded else '0';

    -- Test Stimulus
    stim_proc: process
    begin
        -- Apply reset
        rst <= '1';
        wait for 10 * clk_period;
        rst <= '0';

        -- Wait for boot message to be transmitted
        wait until o_ready = true;
        
        -- Send some data
        i_data <= "01010101";  -- Example byte
        i_valid <= true;
        wait for 1 * clk_period;
        i_valid <= false;
        wait until o_ready = true;

        --i_data <= "00110011";  -- Another example byte
        --i_valid <= true;
        --wait until o_ready = true;
        --i_valid <= false;
        
        -- More tests can be added as necessary

        TbSimEnded <= true;
        wait;  -- Hold simulation
    end process;

end sim;
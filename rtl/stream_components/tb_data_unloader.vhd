library ieee;
use ieee.std_logic_1164.all;

entity tb_data_unloader is
end tb_data_unloader;

architecture sim of tb_data_unloader is

    -- Instantiate the DUT (Device Under Test)
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    
        -- Output signals
    signal o_ready : boolean;
    signal o_tx    : std_logic;
    
    -- Input signals
    signal i_valid : boolean := false;
    signal i_data  : std_logic_vector(15 downto 0) := (others => '0');  -- Adjust size as needed


    constant clk_period : time := 37 ns;  -- assuming 27 MHz for simplicity, adjust accordingly
    
    signal TbSimEnded : boolean := false;
    
begin

    -- DUT
    DUT: entity work.data_unloader(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0,
        boot_message  => "unload.",
        delimiter     => 'D',
        num_bytes     => 2
    )
    port map (
        clk     => clk,
        rst     => rst,
        o_ready => o_ready,
        i_valid => i_valid,
        i_data  => i_data,
        o_tx    => o_tx
    );

    clk <= not clk after clk_period / 2 when not TbSimEnded else '0';

    -- Test Stimulus
    stim_proc: process
    begin
        -- Apply reset
        rst <= '1';
        wait for 100 * clk_period;
        rst <= '0';

        -- Wait for boot message to be transmitted
        wait until o_ready = true;
        
        -- Send some data
        i_data <= x"42AA";  -- Example byte
        i_valid <= true;
        wait for 1 * clk_period;
        i_valid <= false;
        wait until o_ready = true;
        wait for 10000 * clk_period;

        --i_data <= "00110011";  -- Another example byte
        --i_valid <= true;
        --wait until o_ready = true;
        --i_valid <= false;
        
        -- More tests can be added as necessary

        TbSimEnded <= true;
        wait;  -- Hold simulation
    end process;

end sim;
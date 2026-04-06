library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_buffered_data_unloader is
end entity;

architecture sim of tb_buffered_data_unloader is

    constant CLK_PERIOD : time := 37 ns; -- ~27 MHz

    constant NUM_BYTES  : positive := 2;
    constant BUFFER_SIZE : positive := 8;

    signal clk  : std_logic := '0';
    signal rst  : std_logic := '1';

    signal o_ready : boolean;
    signal i_valid : boolean := false;
    signal i_data  : std_logic_vector(NUM_BYTES*8-1 downto 0) := (others => '0');

    signal o_tx : std_logic;

begin

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    dut : entity work.buffered_data_unloader
    generic map(
        frequency_mhz => 27.0,
        baud_rate => 115200,
        boot_message => "unload.",
        num_bytes => NUM_BYTES,
        buffer_size => BUFFER_SIZE
    )
    port map(
        clk => clk,
        rst => rst,
        o_ready => o_ready,
        i_valid => i_valid,
        i_data => i_data,
        o_tx => o_tx
    );

    ----------------------------------------------------------------
    -- Clock
    ----------------------------------------------------------------
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    ----------------------------------------------------------------
    -- Stimulus
    ----------------------------------------------------------------
    stim_proc : process
    begin

        -- reset
        rst <= '1';
        wait for 200 ns;
        rst <= '0';

        wait for 500 ns;

        -- send several words
        for i in 0 to 5 loop

            wait until rising_edge(clk) and o_ready;

            i_data <= std_logic_vector(to_unsigned(i, NUM_BYTES*8));
            i_valid <= true;

            wait until rising_edge(clk);
            i_valid <= false;

        end loop;

        -- wait for UART to finish transmitting
        wait for 20 ms;

        assert false report "Simulation finished" severity failure;

    end process;

end architecture;
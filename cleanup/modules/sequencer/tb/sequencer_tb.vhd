library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

-- Import the custom packages if needed
use work.common_pkg.all;

entity sequencer_tb is
end entity;

architecture tb of sequencer_tb is
    -- Clock parameters
    constant CLK_PERIOD : time := 37.037 ns;  -- 27 MHz

    -- Signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal enable      : boolean := false;
    signal outputs     : BOOLEAN_VECTOR(1 to 3);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.sequencer
    generic map (
        frequency_mhz   => 27.0,
        timings_us      => (0,750,500),
        cycle_length_us => 1000
    )
    port map (
        clk     => clk,
        rst     => rst,
        enable  => enable,
        outputs => outputs
    );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- Initial reset
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';

        -- Wait before enabling
        wait for 5 * CLK_PERIOD;
        enable <= true;

        -- Run for enough time to observe multiple output cycles
        wait for 20 ms;

        -- Disable and end
        enable <= false;
        wait for 1 ms;
        assert false report "End of simulation" severity failure;
    end process;

end architecture;

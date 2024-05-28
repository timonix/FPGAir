library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_pulser is
end entity tb_pulser;

architecture tb of tb_pulser is
    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

    signal clk : std_logic;
    signal rst : std_logic;
    signal input_valid : boolean;
    signal pulse_len_us : unsigned(10 downto 0);
    signal pulser_ready : boolean;
    signal output : std_logic;

begin
    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    -- Instantiate the pulser module
    uut: entity work.pulser
    generic map (
        frequency_mhz => 27.0
    )
    port map (
        clk => clk,
        rst => rst,
        input_valid => input_valid,
        pulse_len_us => pulse_len_us,
        pulser_ready => pulser_ready,
        output => output
    );

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize inputs
        rst <= '1';
        input_valid <= false;
        pulse_len_us <= (others => '0');
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Test case 1: Generate a pulse of 5 ms
        input_valid <= true;
        pulse_len_us <= to_unsigned(5, 11);
        wait for TbPeriod;
        --wait until pulser_ready;
        input_valid <= false;
        wait for 10 us;
        wait for 10 us;

        -- Test case 2: Generate a pulse of 10 ms
        --input_valid <= true;
        --pulse_len_ms <= to_unsigned(10, 11);
        --wait until pulser_ready;
        --input_valid <= false;
        --wait for 15 ms;

        -- End the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end architecture tb;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.fixed_pkg.all;

entity tb_top_aurora is
end tb_top_aurora;

architecture behavior of tb_top_aurora is
    -- Component Declaration for the Unit Under Test (UUT)
    component top_aurora
    generic (
        frequency_mhz : real := 27.0
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        sda : inout std_logic;
        scl : inout std_logic;
        radio_channels : in std_logic_vector(5 downto 0);
        pulse_out : out std_logic;
        led_out : out std_logic;
        start_btn : in std_logic
    );
end component;

    -- Clock period definitions
constant TbPeriod : time := 37 ns;
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

    -- Inputs
signal rst : std_logic := '0';
signal radio_channels : std_logic_vector(5 downto 0) := (others => '0');
signal start_btn : std_logic := '0';

    -- BiDirs
signal sda : std_logic;
signal scl : std_logic;

    -- Outputs
signal pulse_out : std_logic;
signal led_out : std_logic;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: top_aurora
    generic map (
        frequency_mhz => 27.0
    )
    port map (
        clk => TbClock,
        rst => rst,
        sda => sda,
        scl => scl,
        radio_channels => radio_channels,
        pulse_out => pulse_out,
        led_out => led_out,
        start_btn => start_btn
    );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 100 ns
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Start button press
        start_btn <= '1';
        wait for 100 ns;
        start_btn <= '0';

        -- Simulate some radio channel inputs
        radio_channels <= "101010";
        wait for 1000 ns;
        radio_channels <= "010101";
        wait for 1000 ns;

        -- Add more test scenarios here

        -- End the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end behavior;
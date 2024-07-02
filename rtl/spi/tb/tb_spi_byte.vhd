library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.MATH_REAL.all;
use IEEE.fixed_pkg.all;

entity tb_spi_byte is
end entity tb_spi_byte;

architecture tb of tb_spi_byte is
    constant frequency_mhz : real := 27.0;
    constant spi_frequency_mhz : real := 20.0;
    constant devices : integer := 2;
    constant mode : natural := 0;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal miso : std_logic := '0';
    signal mosi : std_logic;
    signal sck : std_logic;
    signal cs : std_logic_vector(devices-1 downto 0);
    signal s_stream_ready : boolean;
    signal s_stream_valid : boolean := false;
    signal s_stream_data : std_logic_vector(7 downto 0) := (others => '0');
    signal s_stream_target : std_logic_vector(devices-1 downto 0) := (others => '0');
    signal m_stream_ready : boolean := true;
    signal m_stream_valid : boolean;
    signal m_stream_data : std_logic_vector(7 downto 0);

    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin
    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    -- Instantiate the DUT (Device Under Test)
    dut: entity work.spi_byte
    generic map (
        frequency_mhz => frequency_mhz,
        spi_frequency_mhz => spi_frequency_mhz,
        devices => devices,
        mode => mode
    )
    port map (
        clk => clk,
        rst => rst,
        miso => miso,
        mosi => mosi,
        sck => sck,
        cs => cs,
        s_stream_ready => s_stream_ready,
        s_stream_valid => s_stream_valid,
        s_stream_data => s_stream_data,
        s_stream_target => s_stream_target,
        m_stream_ready => m_stream_ready,
        m_stream_valid => m_stream_valid,
        m_stream_data => m_stream_data
    );

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the DUT
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Send data over SPI
        s_stream_valid <= true;
        s_stream_data <= x"A5";
        s_stream_target <= "01";
        wait until s_stream_ready;
        s_stream_valid <= false;
        wait for 1 us;

        -- Send another data over SPI
        s_stream_valid <= true;
        s_stream_data <= x"5A";
        s_stream_target <= "10";
        wait until s_stream_ready;
        s_stream_valid <= false;
        wait for 1 us;

        -- End the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end architecture tb;
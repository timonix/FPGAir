library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.MATH_REAL.all;
use IEEE.fixed_pkg.all;

entity top_red is
    port (
        clk : in std_logic;
        rst : in std_logic;
        miso : in std_logic;
        mosi : out std_logic;
        sck : out std_logic;
        cs : out std_logic_vector(0 downto 0)
    );
end entity top_red;

architecture rtl of top_red is
    constant frequency_mhz : real := 27.0;
    constant spi_frequency_mhz : real := 0.4;
    constant devices : integer := 1;
    constant mode : natural := 3;

    signal s_stream_ready : boolean;
    signal s_stream_valid : boolean := false;
    signal s_stream_data : std_logic_vector(7 downto 0) := (others => '0');
    signal s_stream_target : std_logic_vector(devices-1 downto 0) := (others => '0');
    signal m_stream_ready : boolean := true;
    signal m_stream_valid : boolean;
    signal m_stream_data : std_logic_vector(7 downto 0);

    type state_type is (IDLE, SEND_BYTE_1, SEND_BYTE_2, DONE);
    signal state : state_type := IDLE;

begin
    -- Instantiate the spi_byte entity
    spi_byte_inst: entity work.spi_byte
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

    -- State machine to send bytes
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
                s_stream_valid <= false;
            else
                case state is
                    when IDLE =>
                        s_stream_valid <= true;
                        s_stream_data <= x"80";
                        s_stream_target <= "1";
                        state <= SEND_BYTE_1;

                    when SEND_BYTE_1 =>
                        if s_stream_ready then
                            s_stream_valid <= false;
                            state <= SEND_BYTE_2;
                        end if;

                    when SEND_BYTE_2 =>
                        s_stream_valid <= true;
                        s_stream_data <= x"00";
                        s_stream_target <= "1";
                        state <= DONE;

                    when DONE =>
                        if s_stream_ready then
                            s_stream_valid <= false;
                            state <= DONE;
                        end if;
                end case;
            end if;
        end if;
    end process;

end architecture rtl;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.MATH_REAL.all;
use IEEE.fixed_pkg.all;

entity spi_byte is
    generic(
        frequency_mhz : real := 27.0;
        spi_frequency_mhz : real := 0.4;
        devices : integer := 2;
        mode : natural := 0 -- supports 0 and 3
    );
    port(
        clk         : in STD_LOGIC;
        rst         : in STD_LOGIC;
        
        miso        : in STD_LOGIC;
        mosi        : out STD_LOGIC;
        sck         : out STD_LOGIC;
        cs          : out STD_LOGIC_VECTOR(devices-1 downto 0);
        
        s_stream_ready  : out BOOLEAN;
        s_stream_valid  : in BOOLEAN;
        s_stream_data   : in STD_LOGIC_VECTOR(7 downto 0);
        s_stream_target : in STD_LOGIC_VECTOR(devices-1 downto 0);
        
        m_stream_ready : in BOOLEAN;
        m_stream_valid : out BOOLEAN;
        m_stream_data  : out STD_LOGIC_VECTOR(7 downto 0)
        
    );
end entity spi_byte;

architecture rtl of spi_byte is
    
    constant timer_max : natural := natural(frequency_mhz / (2.0*spi_frequency_mhz));
    signal   delay_timer : natural range 0 to timer_max;
    signal   delay_done : boolean;
    
    signal latched_data : STD_LOGIC_VECTOR(7 downto 0);
    
    signal s_stage : integer range 0 to 31;
    
begin
    
    delay_done <= delay_timer = 0;
    process(clk)
    begin
        if rising_edge(clk) then
            if delay_timer /= 0 then
                delay_timer <= delay_timer - 1;
            end if;
            
            if s_stream_ready and s_stream_valid then
                s_stream_ready <= false;
                latched_data <= s_stream_data;
                cs <= not s_stream_target;
                s_stage <= s_stage + 1;
                delay_timer <= timer_max;
            end if;
            
            if delay_timer = 0 then
                if s_stage = 1  or s_stage = 3 or
                s_stage = 5  or s_stage = 7 or
                s_stage = 9  or s_stage = 11 or
                s_stage = 13 or s_stage = 15 then
                   --
                    mosi <= latched_data(7);
                    sck <= '0';
                    latched_data(7 downto 1) <= latched_data(6 downto 0);
                    s_stage <= s_stage + 1;
                    delay_timer <= timer_max;
                end if;
                
                if s_stage = 2  or s_stage = 4 or
                s_stage = 6  or s_stage = 8 or
                s_stage = 10 or s_stage = 12 or
                s_stage = 14 or s_stage = 16 then
                   --
                    sck <= '1';
                    latched_data(0) <= miso;
                    delay_timer <= timer_max;
                    s_stage <= s_stage + 1;
                end if;
                
                if s_stage = 17 then
                    delay_timer <= timer_max;
                    if mode = 0 or mode = 1 then
                        sck <= '0';
                    else
                        sck <= '1';
                    end if;
                    s_stream_ready <= true;
                    s_stage <= 0;
                end if;
            end if;
            
            if rst = '1' then
                s_stream_ready <= true;
                delay_timer <= 0;
                s_stage <= 0;
                cs <= (others => '1');
                
                if mode = 0 or mode = 1 then sck <= '0';
                else sck <= '1';
                end if;
            end if;
            
        end if;
    end process;
    
end architecture rtl;
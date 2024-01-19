library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.common_pkg.all;

entity radio_channel is
    generic (
        frequency_mhz : real := 27.0
    );
    port (
        clk : in std_logic;
        rst : in STD_LOGIC;
        enable : in BOOLEAN;
        channel_pwm : in STD_LOGIC;
        channel_data : out UNSIGNED(10 downto 0)
    );
end entity radio_channel;

architecture rtl of radio_channel is
    
    constant micro_second : real := 1.0;
    constant clock_divisor : positive := positive(frequency_mhz / micro_second);
    signal clock_divider_counter : integer range 0 to clock_divisor := 0;
    signal radio_clock : STD_LOGIC := '0';
    
    -- Signal 1
    
    signal ch1_counter : unsigned (10 downto 0);
    signal ch1_last_val : STD_LOGIC;
    
begin
    radio_clock_proc : process (clk)
    begin
        if rising_edge(clk) then
            clock_divider_counter <= clock_divider_counter + 1;
            radio_clock <= '0';
            if clock_divider_counter = clock_divisor - 1 then
                clock_divider_counter <= 0;
                radio_clock <= '1';
            end if;
        end if;
    end process;
    
    
    process (clk)
    begin
        if rising_edge(clk) then

            if radio_clock = '1' and channel_pwm = '1' then
                if not (ch1_counter = 2000) then
                    ch1_counter <= ch1_counter + 1;
                end if;
            end if;
            
            if ch1_last_val = '1' and channel_pwm = '0' then
                channel_data <= ch1_counter;
                if ch1_counter < 1000 then
                    channel_data <= to_unsigned(1000, channel_data'length);
                end if;
                ch1_counter <= (others => '0');
            end if;
            
            if not enable then
                channel_data <= (others => '0');
            end if;
            
            ch1_last_val <= channel_pwm;

            if rst = '1' then
                ch1_counter <= (others => '0');
                channel_data <= (others => '0');
            end if;
            
        end if;
    end process;

end architecture rtl;
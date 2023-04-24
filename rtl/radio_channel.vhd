library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity radio_channel is
    generic (
        frequency_mhz : real := 27.0
    );
    port (
        clk : in std_logic;
        rst : in STD_LOGIC;
        ch1 : in STD_LOGIC;
        enable_output : in BOOLEAN;
        channel_data : out UNSIGNED(9 downto 0)
    );
end entity radio_channel;

architecture rtl of radio_channel is
    
    constant micro_second : real := 1.0;
    constant clock_divisor : positive := positive(frequency_mhz / micro_second);
    signal clock_divider_counter : integer range 0 to clock_divisor + 1 := 0;
    signal radio_clock : STD_LOGIC := '0';
    
    -- Signal 1
    
    signal ch1_counter : unsigned (9 downto 0);
    signal ch1_last_val : STD_LOGIC;
    
begin
    radio_clock_proc : process (clk)
    begin
        if rising_edge(clk) then
            clock_divider_counter <= clock_divider_counter + 1;
            radio_clock <= '0';
            if clock_divider_counter = clock_divisor then
                clock_divider_counter <= 0;
                radio_clock <= '1';
            end if;
        end if;
    end process;
    
    
    process (clk)
    begin
        if rising_edge(clk) then

            ch1_counter <= (others => '0');
            if radio_clock = '1' and ch1 = '1' then
                ch1_counter <= ch1_counter + 1;
            end if;
            
            if ch1_last_val = '1' and ch1 = '0' then
                channel_data <= ch1_counter;
            end if;
            
            if not enable_output then
                channel_data <= (others => '0');
            end if;
            
            ch1_last_val <= ch1;

            if rst = '1' then
                channel_data <= (others => '0');
            end if;
            
        end if;
    end process;

end architecture rtl;
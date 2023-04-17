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
        enable_output : in STD_LOGIC;
        channel_data : out STD_LOGIC_VECTOR(9 downto 0);
        
        update_map : in STD_LOGIC;
        calibration_done : out STD_LOGIC
    );
end entity radio_channel;

architecture rtl of radio is
    
    signal micro_second : real := 1.0;
    signal clock_divisor : positive := positive(frequency_mhz / micro_second);
    signal clock_divider_counter : natural range 0 to clock_divisor + 1 := 0;
    signal radio_clock : STD_LOGIC := '0';
    
    
    -- Signal 1
    
    signal ch1_min : integer := 1000;
    signal ch1_max : integer := 2000;
    
    signal ch1_scaling_factor : integer;
    signal ch1_offset : integer;
    
    signal ch1_counter : unsigned := ();
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
    
    update_proc: process(clk)
    begin
        if rising_edge(clk) then
            if update_map then
                
            end if;
            
            if rst = '1' then
                
            end if;
        end if;
    end process;
    
    
    process (clk)
    begin
        if rising_edge(clk) then

            ch1_counter <= 0;
            if radio_clock = '1' and ch1 = '1' then
                ch1_counter <= ch1_counter + 1;
            end if;
            
            if ch1_last_val = '1' and ch1 = '0' then
                signal_1 <= (ch1_counter - ch1_offset) * ch1_scaling_factor;
                
                if ch1_counter < ch1_min then
                    ch1_min <= ch1_counter;
                end if;
                
                if ch1_counter > ch1_max then
                    ch1_max <= ch1_counter;
                end if;
            end if;
            
            if not enable_output then
                signal_1 <= (others => '0');
            end if;
            
            ch1_last_val <= ch1;

            if rst = '1' then
                ch1_min <= 1500;
                ch1_max <= 1500;
                signal_1 <= (others => '0');
            end if;
            
        end if;
    end process;

end architecture rtl;
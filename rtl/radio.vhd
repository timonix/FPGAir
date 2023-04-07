library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity radio is
    generic(
        frequency_mhz : real := 27.0
    );
    port(
        clk  : in std_logic;
        rst : in STD_LOGIC;
        ch1 : in STD_LOGIC;
        signal_1 : out STD_LOGIC_VECTOR(9 downto 0);
        calibration : in STD_LOGIC;
        calibration_done : out STD_LOGIC
    );
end entity radio;

architecture rtl of radio is
    
    signal micro_second : real := 1.0;
    signal clock_divisor : positive := positive(frequency_mhz / micro_second);
    signal clock_divider_counter : natural range 0 to clock_divisor + 1 := 0;
    signal radio_clock : STD_LOGIC := '0';
    
    
    -- Signal 1
    
    signal ch1_min : integer := 1000;
    signal ch1_max : integer := 2000;
    
    signal ch1_scaling_factor : integer;
    
    signal ch1_counter : integer := 0;
    signal ch1_last_val : STD_LOGIC;
    
begin

    radio_clock_proc: process(clk)
    begin
        if rising_edge(clk) then
            clock_divider_counter <= clock_divider_counter+1;
            radio_clock <= '0';
            if clock_divider_counter = clock_divisor then
                clock_divider_counter <= 0;
                radio_clock <= '1';
            end if;
        end if;
    end process;
    
    process(clk, radio_clock, rst)
    begin
        
        
        if rising_edge(clk) then
            
            if calibration = '1' then
                signal_1 <= std_logic_vector(to_unsigned(500, signal_1'length));
                
                if ch1_counter < ch1_min then
                    ch1_min <= ch1_counter;
                end if;
                if ch1_counter > ch1_max then
                    ch1_max <= ch1_counter;
                end if;
                
                
                -- dividend * 2^5
                
                for i in 0 to 4 loop
                    if dividend > divisor then
                        dividend <= dividend - divisor;
                        scaling_counter <= scaling_counter + 1;
                    end if;
                end loop;
                
                -- scaling_factor / 2^n
                
            else
                
            end if;
            
            if radio_clock = '1' AND ch1 = '1' then
                ch1_counter <= ch1_counter + 1;
            end if;           
            
            if ch1_last_val = '1' AND ch1 = '0' then
                
                signal_1 <= std_logic_vector(to_unsigned((ch1_counter - ch1_min) * , signal_1'length));
                ch1_counter <= 0;
            end if;
            
            ch1_last_val <= ch1;

            
            
            if rst = '1' then
                signal_1 <= (others => '0');
            end if;
            
        end if;
    end process;

end architecture rtl;




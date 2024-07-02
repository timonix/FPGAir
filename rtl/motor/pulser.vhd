library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pulser is
    generic (
        frequency_mhz : real := 27.0
    );
    port(
        clk : in STD_LOGIC;
        
        input_valid : in boolean;
        pulse_len_us : in UNSIGNED(10 downto 0);
        pulser_ready : out boolean;
        
        output : out STD_LOGIC
        
    );
end entity pulser;



architecture rtl of pulser is
    constant clk_cycles_per_us : integer := integer(frequency_mhz);
    signal us_counter : integer range 0 to clk_cycles_per_us;
    signal us_pulse : std_logic := '0';
    
    signal pulse_counter : UNSIGNED(10 downto 0) := (others => '0');

    
begin

    ms_clock : process(clk)
    begin
        if rising_edge(clk) then

            us_pulse <= '0';
            if us_counter = clk_cycles_per_us then
                us_counter <= 0;
                us_pulse <= '1';
            else
                us_counter <= us_counter + 1;
            end if;
        end if;
    end process;
    
    output <= '1' when pulse_counter /= 0 else '0';
    
    process(clk)
    begin
        if rising_edge(clk) then
            if pulse_counter /= 0 and us_pulse = '1' then
                pulse_counter <= pulse_counter - 1;
            end if;
            
            if pulse_counter = 0 then
                pulser_ready <= true;
            end if;
            
            if input_valid and pulser_ready then
                pulse_counter <= pulse_len_us;
                pulser_ready <= false;
            end if;
        end if;
    end process;

end architecture rtl;














library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;

entity pid is
    generic (
        frequency_mhz : real := 27.0;
        Kp : sfixed(12 downto -12) := to_sfixed(1.0, 12,-12);
        Ki : INTEGER := 1;
        Kd : INTEGER := 1;
        sample_time : INTEGER := 512        -- micro seconds
    );
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in BOOLEAN;
        setpoint : in INTEGER;
        input : in INTEGER;
        output : out INTEGER
    );
end entity pid;

architecture rtl of pid is
    
    signal sample_counter : INTEGER := 0;
    signal sample_time_divisor : INTEGER := INTEGER(frequency_mhz * sample_time) - 1;
    signal sample : STD_LOGIC := '0';
    
begin

    pwm_clock_proc : process (clk)
    begin
        if rising_edge(clk) then
            
            sample_counter <= sample_counter + 1;
            
            if sample_counter = sample_time then
                sample <= '1';
                sample_counter <= 0;
            end if;
            
        end if;
    end process;
    
    process (clk)
    begin
        if rising_edge(clk) then
            
            -- write stuff here. For example what happens when
            
        end if;
    end process;

end architecture rtl;


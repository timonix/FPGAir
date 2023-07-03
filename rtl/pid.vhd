
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity pid is
    generic (
        frequency_mhz : real := 27.0;
        Kp : sfixed(12 downto -12) := to_sfixed(1.0, 12,-12);
        Ki : sfixed(12 downto -12) := to_sfixed(1.0, 12,-12);
        Kd : sfixed(12 downto -12) := to_sfixed(1.0, 12,-12);
        sample_time : sfixed(12 downto -12) := to_sfixed(0.0005, 12,-12)        -- micro seconds
    );
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in BOOLEAN;
        sample : in STD_LOGIC;
        setpoint : in sfixed(12 downto -12);
        input : in sfixed(12 downto -12);
        output : out sfixed(12 downto -12)
    );
end entity pid;

architecture rtl of pid is
    
    signal sample_counter : sfixed(12 downto -12) := to_sfixed(0.0, 12,-12);
    --signal sample_time_divisor : sfixed(12 downto -12) := resize(frequency_mhz * sample_time, 12, -12);
    
    
    signal error : sfixed(12 downto -12) := to_sfixed(0.0, 12,-12);
    signal cum_error : sfixed(12 downto -12) := to_sfixed(0.0, 12,-12);
    signal rate_error : sfixed(12 downto -12) := to_sfixed(0.0, 12,-12);
    signal last_error : sfixed(12 downto -12) := to_sfixed(0.0, 12,-12);
    
begin

    
    
    process (clk)
    begin
        if rising_edge(clk) then
            
            -- write stuff here. For example what happens when
            
            if sample = '1' then
                
                error <= fixed_sub(setpoint, input);
                cum_error <= fixed_mul_add(error, sample_time, cum_error);
                rate_error <= resize(error-last_error / sample_time,rate_error);
                
                
                
                last_error <= error;
                
            end if;
            
            output <= resize(Kp * error + Ki * cum_error + Kd * rate_error,output);
            
            if not enable or rst = '1' then
                error <= (others => '0');
                cum_error <= (others => '0');
                rate_error <= (others => '0');
                output <= (others => '0');
                last_error <= (others => '0');
                sample_counter <= (others => '0');
            end if;
            
        end if;
    end process;

end architecture rtl;


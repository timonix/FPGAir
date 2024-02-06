
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity pid is
    generic (
        frequency_mhz : real := 27.0;
        Kp : sfixed(11 downto -11) := to_sfixed(1.1353, 11,-11);
        Ki : sfixed(11 downto -11) := to_sfixed(0.01231, 11,-11);
        Kd : sfixed(11 downto -11) := to_sfixed(0.43512, 11,-11);
        sample_time : sfixed(11 downto -11) := to_sfixed(1.0, 11,-11)        -- milli seconds
    );
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in BOOLEAN;
        sample : in boolean;
        data_valid : out boolean;
        setpoint : in sfixed(11 downto -11);
        input : in sfixed(11 downto -11);
        output : out sfixed(11 downto -11)
    );
end entity pid;

architecture rtl of pid is
    

    --signal sample_time_divisor : sfixed(12 downto -12) := resize(frequency_mhz * sample_time, 12, -12);
    
    
    signal error : sfixed(11 downto -11) := to_sfixed(0.0, 11,-11);
    signal cum_error : sfixed(11 downto -11) := to_sfixed(0.0, 11,-11);
    signal rate_error : sfixed(11 downto -11) := to_sfixed(0.0, 11,-11);
    signal last_error : sfixed(11 downto -11) := to_sfixed(0.0, 11,-11);
    
    signal output_valid_q : boolean;
    
begin

    
    
    process (clk)
    variable tmp0 : sfixed(11 downto -11) := to_sfixed(0.0, 11,-11);
    variable tmp1 : sfixed(11 downto -11) := to_sfixed(0.0, 11,-11);
    variable tmp2 : sfixed(11 downto -11) := to_sfixed(0.0, 11,-11);
    begin
        if rising_edge(clk) then
            
            -- write stuff here. For example what happens when
            output_valid_q <= false;
            if sample then
                output_valid_q <= true;
                error <= fixed_sub(setpoint, input);
                cum_error <= cum_mul(error, sample_time, cum_error);
                rate_error <= resize((error-last_error) / sample_time,rate_error);

                last_error <= error;
                
            end if;
            data_valid <= output_valid_q;
            
            output <= resize(tmp0+tmp1+tmp2,output);
            tmp0 := resize(Kp * error ,output);
            tmp1 := resize(Ki * cum_error, output);
            tmp2 := resize( Kd * rate_error,output);
            
            if output > 1000 then
                output <= to_sfixed(1000, output'left, output'right);
            elsif output < -1000 then
                output <= to_sfixed(-1000, output'left, output'right);
            end if;
            
            if not enable or rst = '1' then
                error <= (others => '0');
                cum_error <= (others => '0');
                rate_error <= (others => '0');
                output <= (others => '0');
                last_error <= (others => '0');

            end if;
            
        end if;
    end process;

end architecture rtl;


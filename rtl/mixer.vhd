
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity mixer is
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in BOOLEAN;
        throttle_i : in sfixed(11 downto -11);
        roll_pid_i : in sfixed(11 downto -11);
        pitch_pid_i : in sfixed(11 downto -11);
        yaw_pid_i : in sfixed(11 downto -11);
        motor1_signal_o : out sfixed(11 downto -11);
        motor2_signal_o : out sfixed(11 downto -11);
        motor3_signal_o : out sfixed(11 downto -11)
        motor4_signal_o : out sfixed(11 downto -11)
    );
end entity mixer;

architecture rtl of mixer is
    
    --signals
    signal tmp1 : sfixed(11 downto -11);
    signal tmp2 : sfixed(11 downto -11);
    signal tmp3 : sfixed(11 downto -11);
    signal tmp4 : sfixed(11 downto -11);
    
begin

    process (clk)
    begin
        if rising_edge(clk) then
            
            -- Mix the throttle and PID values
            tmp1 <= throttle_i - roll_pid_i - pitch_pid_i + yaw_pid_i;
            tmp2 <= throttle_i + roll_pid_i - pitch_pid_i - yaw_pid_i;
            tmp3 <= throttle_i - roll_pid_i + pitch_pid_i - yaw_pid_i;
            tmp4 <= throttle_i + roll_pid_i + pitch_pid_i + yaw_pid_i;
            
            -- Limit the signals max value
            if tmp1 > 1000 then
                tmp1 <= to_sfixed(1000, tmp1'length);
            end if;
            if tmp2 > 1000 then
                tmp2 <= to_sfixed(1000, tmp2'length);
            end if;
            if tmp3 > 1000 then
                tmp3 <= to_sfixed(1000, tmp3'length);
            end if;
            if tmp4 > 1000 then
                tmp4 <= to_sfixed(1000, tmp4'length);
            end if;
            
            -- Cut all negative bits
            motor1_signal_o(11 downto 0) <= tmp1(11 downto 0);
            motor2_signal_o(11 downto 0) <= tmp2(11 downto 0);
            motor3_signal_o(11 downto 0) <= tmp3(11 downto 0);
            motor4_signal_o(11 downto 0) <= tmp4(11 downto 0);
            
            -- Reset if not enabled or rst
            if not enable or rst = '1' then
                motor1_signal_o <= (others => '0');
                motor2_signal_o <= (others => '0');
                motor3_signal_o <= (others => '0');
                motor4_signal_o <= (others => '0');
            end if;
            
        end if;
    end process;

end architecture rtl;


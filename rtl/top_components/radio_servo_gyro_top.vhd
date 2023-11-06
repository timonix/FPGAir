library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity radio_servo_gyro_top is
    port (
        sys_clk      : in  std_logic;
        sys_rst_n     : in  std_logic;
        led  : out std_logic_vector(5 downto 0);
        channel_1 : in std_logic;
        Motor_1 : out STD_LOGIC
    );
end radio_servo_gyro_top;

architecture rtl of radio_servo_gyro_top is

    signal multiplier : unsigned(9 downto 0);
    signal radio_channel_A_signal : sfixed(11 downto -11);
    signal radio_channel_A_enable : BOOLEAN;
    signal motor_enable : BOOLEAN;
    signal pid_signal : UNSIGNED(10 downto 0);
    signal pid_sample : STD_LOGIC;
    
begin
    
    -- Gyro and radio into a PID, PID output into pwn (servo)
    
    -- TODO
    -- PID out -1000 to 1000
    -- Mixer output to be decided. Probably sfixed
    -- Component after mixer and before pwm to convert signal
    -- Sync signals from gyro and radio components: -1000 to 1000
    
    
    radio_channel_A : entity work.radio_channel(rtl)
    port map (
        clk => sys_clk,
        rst => sys_rst_n,
        ch1 => channel_1,
        channel_data => radio_channel_A_signal,
        enable => radio_channel_A_enable
    );
    
    motor : entity work.pwm(rtl)
    port map (
        clk => sys_clk,
        rst => sys_rst_n,
        enable => motor_enable,
        speed => pid_signal,
        output => Motor_1,
        sync => pid_sample
    );
    
    pid : entity work.pid(rtl)
    port map (
        clk => sys_clk,
        rst => sys_rst_n,
        enable => true,
        sample => pid_sample,
        setpoint => radio_channel_A_signal,
        input => open,
        output => pid_signal
    );
    
    p_1_HZ : process (sys_clk) is

    begin
        if rising_edge(sys_clk) then
            multiplier <= multiplier+1;
        end if;
        
    end process p_1_HZ;
    
    

    
end rtl;
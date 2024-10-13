library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;

entity mixer is
    generic (
        max_value : integer := 1000;
        min_value : integer := 100
    );
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in BOOLEAN;
        throttle_i : in sfixed(11 downto -12);
        roll_pid_i : in sfixed(11 downto -12);
        pitch_pid_i : in sfixed(11 downto -12);
        yaw_pid_i : in sfixed(11 downto -12);
        motor1_signal_o : out UNSIGNED(10 downto 0);
        motor2_signal_o : out UNSIGNED(10 downto 0);
        motor3_signal_o : out UNSIGNED(10 downto 0);
        motor4_signal_o : out UNSIGNED(10 downto 0)
    );
end entity mixer;

architecture rtl of mixer is
    
    --signals
    signal tmp1 : sfixed(14 downto -12);
    signal tmp2 : sfixed(14 downto -12);
    signal tmp3 : sfixed(14 downto -12);
    signal tmp4 : sfixed(14 downto -12);
    
    signal formal_reset_deasserted : boolean := false;
    
    function clamp(value: sfixed; min_val: integer; max_val: integer) return sfixed is
begin
    if to_integer(value) < min_val then
        return to_sfixed(min_val, value'left, value'right);
    elsif to_integer(value) > max_val then
        return to_sfixed(max_val, value'left, value'right);
    else
        return value;
    end if;
end function;

begin

    process (clk)
    begin
        if rising_edge(clk) then
            
            tmp1 <= clamp(throttle_i + roll_pid_i + pitch_pid_i - yaw_pid_i, min_value, max_value);
            tmp2 <= clamp(throttle_i - roll_pid_i + pitch_pid_i + yaw_pid_i, min_value, max_value);
            tmp3 <= clamp(throttle_i + roll_pid_i - pitch_pid_i + yaw_pid_i, min_value, max_value);
            tmp4 <= clamp(throttle_i - roll_pid_i - pitch_pid_i - yaw_pid_i, min_value, max_value);
            
            motor1_signal_o <= UNSIGNED(tmp1(10 downto 0));
            motor2_signal_o <= UNSIGNED(tmp2(10 downto 0));
            motor3_signal_o <= UNSIGNED(tmp3(10 downto 0));
            motor4_signal_o <= UNSIGNED(tmp4(10 downto 0));
            
            -- Reset if not enabled or rst
            if not enable or rst = '1' then
                motor1_signal_o <= (others => '0');
                motor2_signal_o <= (others => '0');
                motor3_signal_o <= (others => '0');
                motor4_signal_o <= (others => '0');
                formal_reset_deasserted <= true;
            end if;
            
        end if;
    end process;
    
    
    -- //FORMAL VERIFICATION
    
    
    
    -- psl default clock is rising_edge(clk);
    
    -- psl defreset_motor_signals : assert always (rst = '1') ->
    -- (next(motor1_signal_o = 0 and
    --       motor2_signal_o = 0 and
    --       motor3_signal_o = 0 and
    --       motor4_signal_o = 0));

    -- psl assert_max_value : assert always (formal_reset_deasserted -> motor1_signal_o <= max_value);

end architecture rtl;
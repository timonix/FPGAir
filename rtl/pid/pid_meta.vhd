--self.prev_error = 0
--self.integral = 0
            
--error = self.setpoint - measured_value
--self.integral += error
--derivative = error - self.prev_error

--output = Kp * error + Ki * integral + Kd * derivative


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;
use IEEE.math_real.all;

use work.common_pkg.ALL;

entity pid_meta is
    generic (
        integer_bits : integer := 11;
        fractional_bits : integer := 11;
        
        -- cyclone V 27x18 bits
        -- gowin 36 x 18
        dsp_large_word : integer := 36;
        dsp_small_word : integer := 18;
        
        A_enabled : boolean := true;
        B_enabled : boolean := true;
        
        Kp : real := 1.1353;
        Ki : real := 0.01231;
        Kd : real := 0.43512
    );
    port(
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in BOOLEAN;
        update : in boolean;
        data_valid : out boolean;
        
        A_setpoint : in sfixed(integer_bits-1 downto -fractional_bits);
        A_measured : in sfixed(integer_bits-1 downto -fractional_bits);
        A_output : out sfixed(integer_bits-1 downto -fractional_bits);

        B_setpoint : in sfixed(integer_bits-1 downto -fractional_bits);
        B_measured : in sfixed(integer_bits-1 downto -fractional_bits);
        B_output : out sfixed(integer_bits-1 downto -fractional_bits)
    );
end entity pid_meta;

architecture rtl of pid_meta is
    
    
    constant Kp_C : sfixed(dsp_small_word-fractional_bits-1 downto -fractional_bits) := to_sfixed(Kp, dsp_small_word-fractional_bits-1,-fractional_bits);
    constant Ki_C : sfixed(dsp_small_word-fractional_bits-1 downto -fractional_bits) := to_sfixed(Ki, dsp_small_word-fractional_bits-1,-fractional_bits);
    constant Kd_C : sfixed(dsp_small_word-fractional_bits-1 downto -fractional_bits) := to_sfixed(Kd, dsp_small_word-fractional_bits-1,-fractional_bits);
    
    constant integrator_max  : real := (2.0 ** (integer_bits-1)) / Ki;
    constant integrator_bits : integer := integer(ceil(log2(integrator_max + 1.0)));
    
    type pid_channel is record
        integral   : sfixed(integrator_bits downto -fractional_bits);
        error      : sfixed(integer_bits-1 downto -fractional_bits);
        derivative : sfixed(integer_bits-1 downto -fractional_bits);
        last_error : sfixed(integer_bits-1 downto -fractional_bits);
    end record;
    
    procedure reset_channel(signal signal_to_init: inout pid_channel) is
    begin
        signal_to_init.integral   <= (others => '0');
        signal_to_init.error      <= (others => '0');
        signal_to_init.derivative <= (others => '0');
        signal_to_init.last_error <= (others => '0');
    end procedure;
    
    signal channel_A : pid_channel;
    signal channel_B : pid_channel;

    signal mul_A : sfixed(dsp_large_word-fractional_bits-1 downto -fractional_bits) := (others => '0');
    signal mul_B : sfixed(dsp_small_word-fractional_bits-1 downto -fractional_bits) := (others => '0');
    signal mul_C       : sfixed(integer_bits-1 downto -fractional_bits) := (others => '0');
    signal accumulator : sfixed(integer_bits-1 downto -fractional_bits) := (others => '0');
    
    constant integral_max : sfixed(integer_bits downto -fractional_bits) := to_sfixed(2**(integer_bits-1), integer_bits,-fractional_bits);
    constant integral_min : sfixed(integer_bits downto -fractional_bits) := to_sfixed(-2**(integer_bits-1), integer_bits,-fractional_bits);
    
    
    signal stage : natural range 0 to 255;
    
begin
    
    mac_inst : entity work.mac_sfixed(rtl)
    generic map(
        A_integer_bits => dsp_large_word-fractional_bits,
        A_fractional_bits => fractional_bits,
        B_integer_bits => dsp_small_word-fractional_bits,
        B_fractional_bits => fractional_bits,
        C_integer_bits => integer_bits,
        C_fractional_bits => fractional_bits,
        O_integer_bits => integer_bits,
        O_fractional_bits => fractional_bits
    )
    port map (
        clk      => clk,
        A        => mul_A,
        B        => mul_B,
        C        => mul_C,
        O        => accumulator
    );
    
    process (clk)
    begin
        if rising_edge(clk) then
            data_valid <= false;
            
            case stage is
                when 0 => if update then
                        channel_A.error <= fixed_sub(A_setpoint,A_measured);
                        channel_A.last_error <= channel_A.error;
                        
                        channel_B.error <= fixed_sub(B_setpoint,B_measured);
                        channel_B.last_error <= channel_B.error;
                        
                        stage <= stage + 1;
                    end if;
                when 1 =>
                    channel_A.integral   <= fixed_add(channel_A.integral,channel_A.error);
                    channel_A.derivative <= fixed_sub(channel_A.error,channel_A.last_error);
                    
                    channel_B.integral   <= fixed_add(channel_B.integral,channel_B.error);
                    channel_B.derivative <= fixed_sub(channel_B.error,channel_B.last_error);
                    
                    
                    stage <= stage + 1;
                -- channel_A
                when 2 =>
                    mul_A <= map_onto(channel_A.integral,mul_A);
                    mul_B <= Ki_C;
                    mul_C <= (others => '0');
                    stage <= stage + 1;
                when 3 to 5 =>
                    stage <= stage + 1;
                when 6 =>
                    mul_A <= map_onto(channel_A.error,mul_A);
                    mul_B <= Kp_C;
                    mul_C <= accumulator;
                    stage <= stage + 1;
                when 7 to 9 =>
                    stage <= stage + 1;
                when 10 =>
                    mul_A <= map_onto(channel_A.derivative,mul_A);
                    mul_B <= Kd_C;
                    mul_C <= accumulator;
                    stage <= stage + 1;
                when 11 to 13 =>
                    stage <= stage + 1;
                    
                when 14 =>
                    A_output <= accumulator;
                    mul_A <= (others => '0');
                    mul_B <= (others => '0');
                    mul_C <= (others => '0');
                    stage <= stage + 1;
                -- channel_B
                when 15 =>
                    mul_A <= map_onto(channel_B.integral,mul_A);
                    mul_B <= Ki_C;
                    mul_C <= (others => '0');
                    stage <= stage + 1;
                when 16 to 18 =>
                    stage <= stage + 1;
                when 19 =>
                    mul_A <= map_onto(channel_B.error,mul_A);
                    mul_B <= Kp_C;
                    mul_C <= accumulator;
                    stage <= stage + 1;
                when 20 to 22 =>
                    stage <= stage + 1;
                when 23 =>
                    mul_A <= map_onto(channel_B.derivative,mul_A);
                    mul_B <= Kd_C;
                    mul_C <= accumulator;
                    stage <= stage + 1;
                when 24 to 26 =>
                    stage <= stage + 1;
                    
                when 27 =>
                    B_output <= accumulator;
                    mul_A <= (others => '0');
                    mul_B <= (others => '0');
                    mul_C <= (others => '0');
                    data_valid <= true;
                    stage <= 0;
                when others =>
                    stage <= 0;
                    
            end case;
            
            if not A_enabled then reset_channel(channel_A); end if;
            if not B_enabled then reset_channel(channel_B); end if;

            if not enable or rst = '1' then
                
                mul_A <= (others => '0');
                mul_B <= (others => '0');
                mul_C <= (others => '0');
                stage <= 0;
                reset_channel(channel_A);
                reset_channel(channel_B);

            end if;
            
        end if;
    end process;

end architecture rtl;


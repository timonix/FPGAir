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

entity pid_fixed is
    generic (
        integer_bits : integer := 11;
        fractional_bits : integer := 11;
        
        
        
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
        setpoint : in sfixed(integer_bits-1 downto -fractional_bits);
        measured : in sfixed(integer_bits-1 downto -fractional_bits);
        output : out sfixed(integer_bits-1 downto -fractional_bits)
    );
end entity pid_fixed;

architecture rtl of pid_fixed is
    
    constant Kp_C : sfixed(18-fractional_bits-1 downto -fractional_bits) := to_sfixed(Kp, 18-fractional_bits-1,-fractional_bits);
    constant Ki_C : sfixed(18-fractional_bits-1 downto -fractional_bits) := to_sfixed(Ki, 18-fractional_bits-1,-fractional_bits);
    constant Kd_C : sfixed(18-fractional_bits-1 downto -fractional_bits) := to_sfixed(Kd, 18-fractional_bits-1,-fractional_bits);
    
    constant integrator_max  : real := (2.0 ** (integer_bits-1)) / Ki;
    constant integrator_bits : integer := integer(ceil(log2(integrator_max + 1.0)));

    
    signal integral : sfixed(integrator_bits downto -fractional_bits) := (others => '0');

    signal error : sfixed(integer_bits-1 downto -fractional_bits) := (others => '0');
    
    signal derivative : sfixed(integer_bits-1 downto -fractional_bits) := (others => '0');
    
    
    signal mul_A : sfixed(36-fractional_bits-1 downto -fractional_bits) := (others => '0');
    signal mul_B : sfixed(18-fractional_bits-1 downto -fractional_bits) := (others => '0');
    signal mul_C       : sfixed(integer_bits-1 downto -fractional_bits) := (others => '0');
    signal accumulator : sfixed(integer_bits-1 downto -fractional_bits) := (others => '0');
    
    signal last_error : sfixed(integer_bits-1 downto -fractional_bits) := (others => '0');
    
    constant integral_max : sfixed(integer_bits downto -fractional_bits) := to_sfixed(2**(integer_bits-1), integer_bits,-fractional_bits);
    constant integral_min : sfixed(integer_bits downto -fractional_bits) := to_sfixed(-2**(integer_bits-1), integer_bits,-fractional_bits);
    
    signal output_valid : boolean;
    
    type stage_t is (wait_for_update_E,update_data_E, integral_E, derivative_E, proportional_E,data_ready_E);
    signal stage : stage_t := wait_for_update_E;
    
begin
    
    mac_inst : entity work.mac_sfixed(rtl)
    generic map(
    A_integer_bits => 36-fractional_bits,
    A_fractional_bits => 11,
    B_integer_bits => 18-fractional_bits,
    B_fractional_bits => 11,
    C_integer_bits => 11,
    C_fractional_bits => 11,
    O_integer_bits => 11,
    O_fractional_bits => 11
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
            
            if stage = wait_for_update_E and update then
                last_error <= error;
                error <= fixed_sub(setpoint,measured);
                stage <= update_data_E;
            end if;
            
            if stage = update_data_E then
                integral <= fixed_add(integral,error);
                derivative <= fixed_sub(setpoint,last_error);
                
                mul_A <= map_onto(error, mul_A);
                mul_B <= map_onto(Kp_C,mul_B);
                mul_C <= (others => '0');
                
                stage <= integral_E;
            end if;
            
            if stage = integral_E then
                mul_A <= map_onto(integral, mul_A);
                mul_B <= map_onto(Ki_C,mul_B);
                mul_C <= map_onto(accumulator,mul_C);
                
                stage <= derivative_E;
            end if;
            
            if stage = derivative_E then
                mul_A <= map_onto(derivative, mul_A);
                mul_B <= map_onto(Kd_C,mul_B);
                mul_C <= map_onto(accumulator,mul_C);
                
                stage <= data_ready_E;
            end if;
            
            if stage = data_ready_E then
                mul_A <= (others => '0');
                mul_B <= (others => '0');
                mul_C <= (others => '0');
                
                output <= accumulator;
                data_valid <= true;
                stage <= wait_for_update_E;
            end if;
            
            if not enable or rst = '1' then
                
                mul_A <= (others => '0');
                mul_B <= (others => '0');
                mul_C <= (others => '0');
                stage <= wait_for_update_E;
                error <= (others => '0');
                integral <= (others => '0');
                derivative <= (others => '0');
                output <= (others => '0');
                last_error <= (others => '0');

            end if;
            
        end if;
    end process;

end architecture rtl;


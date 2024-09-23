library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.fixed_pkg.all;
use IEEE.math_real.all;

use work.common_pkg.ALL;

--
--P:instanteneousError = setpoint – input;
--I:cumulativeError = += error * elapsedTime;
--D:rateOfError = (error – errorLastCalculation)/elapsedTime
--

entity neo_pid is
    generic (
        integer_bits : integer := 12;
        fractional_bits : integer := 12;
        
        timestep_us : real := 1.0;
        
        Kp : real := 1.1353;
        Ki : real := 0.01231;
        Kd : real := 0.43512
    );
    port (
        clk    : in std_logic;
        rst    : in std_logic;
        enable : in BOOLEAN;
        
        update : in boolean;
        output_valid : out boolean;
        
        A_setpoint : in sfixed(integer_bits-1 downto -fractional_bits) := (others => '0');
        A_measured : in sfixed(integer_bits-1 downto -fractional_bits) := (others => '0');
        A_output : out sfixed(integer_bits-1 downto -fractional_bits);
        
        B_setpoint : in sfixed(integer_bits-1 downto -fractional_bits) := (others => '0');
        B_measured : in sfixed(integer_bits-1 downto -fractional_bits) := (others => '0');
        B_output : out sfixed(integer_bits-1 downto -fractional_bits)
        
    );
end entity neo_pid;

architecture rtl of neo_pid is
    
    signal error_A : sfixed(integer_bits-1 downto -fractional_bits);
    signal error_B : sfixed(integer_bits-1 downto -fractional_bits);
    
    signal last_error_A : sfixed(integer_bits-1 downto -fractional_bits);
    signal last_error_B : sfixed(integer_bits-1 downto -fractional_bits);
    
    signal proportional_A : sfixed(integer_bits-1 downto -fractional_bits);
    signal proportional_B : sfixed(integer_bits-1 downto -fractional_bits);
    
    signal integral_A : sfixed(integer_bits-1 downto -fractional_bits);
    signal integral_B : sfixed(integer_bits-1 downto -fractional_bits);
    
    signal derivative_A : sfixed(integer_bits-1 downto -fractional_bits);
    signal derivative_B : sfixed(integer_bits-1 downto -fractional_bits);
    
    
    type state_T is (update_E,error_terms_E,scale_proportial_A_E,scale_proportial_B_E,scale_integral_A_E,scale_integral_B_E,scale_derivative_A_E,scale_derivative_B_E,bonus_e,set_output_E);
    signal state : state_T := update_E;

begin

    process (clk)

    variable mul_A   : sfixed(integer_bits-1 downto -fractional_bits);
    variable mul_B   : sfixed(3 downto -14);
    variable mul_out : sfixed(integer_bits-1 downto -fractional_bits);
    begin
        if rising_edge(clk) then
            mul_out := fixed_mul(mul_A,mul_B,mul_out);
            output_valid <=false;
            case state is
                when update_E =>
                    if update then
                        error_A <= fixed_sub(A_setpoint,A_measured,error_A);
                        error_B <= fixed_sub(B_setpoint,B_measured,error_B);
                        state <= error_terms_E;
                    end if;
                    
                when error_terms_E =>
                    derivative_A <= fixed_sub(error_A,last_error_A,derivative_A);
                    derivative_B <= fixed_sub(error_B,last_error_B,derivative_B);
                    state <= scale_proportial_A_E;
                    last_error_A <= error_A;
                    last_error_B <= error_B;
                    
                when scale_proportial_A_E =>
                    mul_A := error_A;
                    mul_B := to_sfixed(Kp,mul_B);
                    state <= scale_integral_A_E;
                    
                when scale_integral_A_E =>
                    proportional_A <= mul_out;
                    mul_A := error_A;
                    mul_B := to_sfixed(Ki,mul_B);
                    state <= scale_derivative_A_E;
                    
                when scale_derivative_A_E =>
                    integral_A <= fixed_add(mul_out, integral_A);
                    mul_A := derivative_A;
                    mul_B := to_sfixed(Kd,mul_B);
                    state <= scale_proportial_B_E;
                    
                when scale_proportial_B_E =>
                    derivative_A <= mul_out;
                    mul_A := proportional_B;
                    mul_B := to_sfixed(Kp,mul_B);
                    state <= scale_integral_B_E;
                    
                when scale_integral_B_E =>
                    proportional_B <= mul_out;
                    mul_A := error_B;
                    mul_B := to_sfixed(Ki,mul_B);
                    state <= scale_derivative_B_E;
                    
                when scale_derivative_B_E =>
                    integral_B <= fixed_add(mul_out, integral_B);
                    mul_A := derivative_B;
                    mul_B := to_sfixed(Kd,mul_B);
                    state <= bonus_E;
                when bonus_E =>
                    derivative_B <= mul_out;
                    state <= set_output_E;
                when set_output_E =>
                    A_output <= fixed_add(fixed_add(proportional_A,integral_A),derivative_A);
                    B_output <= fixed_add(fixed_add(proportional_B,integral_B),derivative_B);
                    output_valid <=true;
                    state <= update_E;
                    
                when others =>
                    state <= update_E;
                    
            end case;
            
            
            if rst = '1' or NOT enable then
                state <= update_E;
                last_error_A <= (others => '0');
                last_error_B <= (others => '0');
                integral_A <= (others => '0');
                integral_B <= (others => '0');
                A_output <= (others => '0');
                B_output <= (others => '0');
            end if;
        end if;
    end process;
    
    
    
    

end architecture;
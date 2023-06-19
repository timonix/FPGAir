LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY PID IS
    PORT (
        kp_sw          : IN std_logic; --determines if p term is needed
        ki_sw          : IN std_logic; --determines if i term is needed
        kd_sw          : IN std_logic; --determines if d term is needed
        SetVal         : IN std_logic_vector(11 DOWNTO 0); --user input reference
        adc_data       : IN std_logic_vector(11 DOWNTO 0); --feedbac value from sensor
        on_off_switch  : IN std_logic; --determines if controller is active
        output         : OUT std_logic_vector(11 DOWNTO 0); --output of controller
        clk            : IN STD_LOGIC
    );
END PID;
ARCHITECTURE Behavioral OF PID IS


    CONSTANT con_Kp : INTEGER := 1; --proportional constant
    CONSTANT con_kp_den : INTEGER := 2;
    CONSTANT con_Kd : INTEGER := 1; --differential constant
    CONSTANT con_kd_den : INTEGER := 100;
    CONSTANT con_Ki : INTEGER := 1; --integral constant
    CONSTANT con_ki_den : INTEGER := 10;
    SIGNAL Error, Error_difference, error_sum, old_error : INTEGER := 0; --store values for controller
    SIGNAL p, i, d : INTEGER := 0; --Contain the proportional, derivative and integral errors respectively
    SIGNAL output_loaded, output_saturation_buffer : INTEGER := 0; --allows to check if output is within range
    SIGNAL old_adc : std_logic_vector(11 DOWNTO 0);                --stores old adc value
    CONSTANT divider_for_time : INTEGER := 1;                      --stores the time in which the controller acts over example a value of 100 would be equalt to 10ms so 1/divider_for_time = sampling_period

BEGIN
    PROCESS (kp_sw, kd_sw, ki_sw, clk, ADC_DATA, Error, SetVal, i, p, d)
    BEGIN
        IF clk'EVENT AND clk = '1' THEN
            IF on_off_switch = '0' THEN --functions as an on/off switch and sets all main variables to null
                error_sum <= 0;
                error_difference <= 0;
                error <= 0;
                p <= 0;
                i <= 0;
                d <= 0;
                output_loaded <= 0;
                output <= (OTHERS => '0');
            ELSE
                FOR k IN 0 TO 9 LOOP --for loop to run through case statement
                    CASE k IS
                        WHEN 0 => Error <= (to_integer(unsigned(SetVal)) - to_integer(unsigned(ADC_data))); --calculates error between sensor and reference
                        WHEN 1 => IF adc_data /= old_adc THEN --calculate integral and derivative term
                                error_sum <= error_sum + error;
                                error_difference <= error - old_error;
                            END IF;
                        WHEN 2 => IF kp_sw = '1' THEN   --calculate p term if desired
                                p <= (con_Kp * error)/con_kp_den;
                            ELSE
                                p <= 0;
                            END IF;
                        WHEN 3 => IF ki_sw = '1' THEN --calculate i term if desired
                                i <= (con_Ki * error_sum)/(divider_for_time * con_ki_den);
                            ELSE
                                i <= 0;
                            END IF;
                        WHEN 4 => IF kd_sw = '1' THEN  --calculate d term if desired
                                d <= ((con_Kd * error_difference) * divider_for_time)/con_kd_den;
                            ELSE
                                d <= 0;
                            END IF;
                        WHEN 5 => output_saturation_buffer <= (p + i + d); --calculate output of controller
                        WHEN 6 => IF output_saturation_buffer < 0 THEN --checks if output within certain range
                                output_loaded <= 0;
                            ELSIF output_saturation_buffer > 4095 THEN
                                output_loaded <= 4095;
                            ELSE
                                output_loaded <= output_saturation_buffer;
                            END IF;
                        WHEN 7 => output <= std_logic_vector(to_unsigned(output_loaded, 12)); --converts to std_logic_vector which can be output to DAC or input to PWM code
                        WHEN 8 => old_adc <= adc_data; --storing old adc
                        WHEN 9 => old_error <= error; --storing old error for derivative term
                        WHEN OTHERS => NULL;
                    END CASE;
                END LOOP;
            END IF;
        END IF;
    END PROCESS; --end of process
END Behavioral; --end of Architecture
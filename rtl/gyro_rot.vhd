--void calculateGyroAngles() {
--  // Subtract offsets
--  gyro_raw[X] -= gyro_offset[X];
--  gyro_raw[Y] -= gyro_offset[Y];
--  gyro_raw[Z] -= gyro_offset[Z];
--
--// Angle calculation using integration
--  gyro_angle[X] += (gyro_raw[X] / (FREQ * SSF_GYRO));
--  gyro_angle[Y] += (-gyro_raw[Y] / (FREQ * SSF_GYRO)); // Change sign to match the accelerometer's one
--  gyro_angle[Z] += (gyro_raw[Z] / (FREQ * SSF_GYRO));

--// Transfer roll to pitch if IMU has yawed
--  gyro_angle[Y] += gyro_angle[X] * sin(gyro_raw[Z] * (PI / (FREQ * SSF_GYRO * 180)));
--  gyro_angle[X] -= gyro_angle[Y] * sin(gyro_raw[Z] * (PI / (FREQ * SSF_GYRO * 180)));

--}

-- INPUTS
-- Gyro raw X,Y,Z
-- Gyro offset X,Y,Z
-- Gyro scale X,Y,Z (FREQ * SSF_GYRO)

-- Registers
-- gyro angle R,P,Y

-- Outputs
-- gyro angle R,P,Y


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.fixed_pkg.all;

entity gyro_rot is
    Port (
        clk               : in  STD_LOGIC;
        rstn              : in  STD_LOGIC;
        update            : in  boolean;
        done              : out boolean;
        
        gyro_raw_X_in     : in  SFIXED(0 downto -16); -- Assuming 16-bit signed input
        gyro_raw_Y_in     : in  SFIXED(0 downto -16);
        gyro_raw_Z_in     : in  SFIXED(0 downto -16);
        angle_x           : in  SFIXED(0 downto -16);
        angle_y           : in  SFIXED(0 downto -16);
        gyro_offset_X     : in  SFIXED(0 downto -16);
        gyro_offset_Y     : in  SFIXED(0 downto -16);
        gyro_offset_Z     : in  SFIXED(0 downto -16);
        c_X_scale         : in  SFIXED(8 downto -8);
        c_Y_scale         : in  SFIXED(8 downto -8);
        c_transfer_const  : in  SFIXED(8 downto -8);
        gyro_angle_X_out  : out SFIXED(0 downto -16); -- Assuming 32-bit signed output for accumulated angle
        gyro_angle_Y_out  : out SFIXED(0 downto -16)
    );
end gyro_rot;

architecture Behavioral of gyro_rot is
    type stage_type is (OFFSET, INTEGRATE, CORRECT);
    signal stage      : stage_type;
    signal gyro_raw_X : SFIXED(0 downto -16);
    signal gyro_raw_Y : SFIXED(0 downto -16);
    signal gyro_raw_Z : SFIXED(0 downto -16);
    signal gyro_angle_X : SFIXED(0 downto -16);
    signal gyro_angle_Y : SFIXED(0 downto -16);
    signal sine_Z  : SFIXED(0 downto -16);
begin

    process(clk, rstn)
    begin
        if rstn = '0' then
            stage <= OFFSET;
            gyro_angle_X <= (others => '0');
            gyro_angle_Y <= (others => '0');
        elsif rising_edge(clk) then
            case stage is
                when OFFSET =>
                    gyro_raw_X <= resize(gyro_raw_X_in + gyro_offset_X,0,-16);
                    gyro_raw_Y <= resize(gyro_raw_Y_in + gyro_offset_Y,0,-16);
                    gyro_raw_Z <= resize(gyro_raw_Z_in + gyro_offset_Z,0,-16);
                    if update then
                        stage <= INTEGRATE;
                        done <= false;
                    end if;
                    
                when INTEGRATE =>
                    gyro_angle_X <= resize(angle_x + (gyro_raw_X * c_X_scale),0,-16);
                    gyro_angle_Y <= resize(angle_y - (gyro_raw_Y * c_Y_scale),0,-16);
                    sine_Z <= resize(gyro_raw_Z * c_transfer_const,0,-16);
                    stage <= CORRECT;

                when CORRECT =>
                    gyro_angle_Y_out <= resize(gyro_angle_Y + gyro_angle_X * sine_Z,0,-16);
                    gyro_angle_X_out <= resize(gyro_angle_X - gyro_angle_Y * sine_Z,0,-16);
                    stage <= OFFSET;
                    done <= true;
                    
                when others =>
                    stage <= OFFSET;
            end case;
        end if;
    end process;

end Behavioral;











LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.fixed_pkg.ALL;

ENTITY tb_gyro_estimator IS
END ENTITY tb_gyro_estimator;

ARCHITECTURE tb OF tb_gyro_estimator IS
    COMPONENT gyro_estimator IS
        GENERIC (
            vector_integer_bits    : INTEGER := 16;
            vector_fractional_bits : INTEGER := -16;
            gyro_integer_bits      : INTEGER := 16;
            gyro_fractional_bits   : INTEGER := -16;
            output_integer_bits    : INTEGER := 16;
            output_fractional_bits : INTEGER := -16
        );
        PORT (
            clk            : IN STD_LOGIC;
            rst            : IN STD_LOGIC;
            data_in_valid  : IN BOOLEAN;
            vec_x          : IN sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
            vec_y          : IN sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
            vec_z          : IN sfixed(vector_integer_bits - 1 DOWNTO vector_fractional_bits);
            gyro_x         : IN sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
            gyro_y         : IN sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
            gyro_z         : IN sfixed(gyro_integer_bits - 1 DOWNTO gyro_fractional_bits);
            data_out_valid : OUT BOOLEAN;
            out_x          : OUT sfixed(output_integer_bits - 1 DOWNTO output_fractional_bits);
            out_y          : OUT sfixed(output_integer_bits - 1 DOWNTO output_fractional_bits);
            out_z          : OUT sfixed(output_integer_bits - 1 DOWNTO output_fractional_bits)
        );
    END COMPONENT;

    SIGNAL clk            : STD_LOGIC := '0';
    SIGNAL rst            : STD_LOGIC := '0';
    SIGNAL data_in_valid  : BOOLEAN   := FALSE;
    SIGNAL vec_x          : sfixed(15 DOWNTO -16);
    SIGNAL vec_y          : sfixed(15 DOWNTO -16);
    SIGNAL vec_z          : sfixed(15 DOWNTO -16);
    SIGNAL gyro_x         : sfixed(15 DOWNTO -16);
    SIGNAL gyro_y         : sfixed(15 DOWNTO -16);
    SIGNAL gyro_z         : sfixed(15 DOWNTO -16);
    SIGNAL data_out_valid : BOOLEAN;
    SIGNAL out_x          : sfixed(15 DOWNTO -16);
    SIGNAL out_y          : sfixed(15 DOWNTO -16);
    SIGNAL out_z          : sfixed(15 DOWNTO -16);
    
    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

BEGIN
    uut : gyro_estimator
    PORT MAP(
        clk            => clk,
        rst            => rst,
        data_in_valid  => data_in_valid,
        vec_x          => vec_x,
        vec_y          => vec_y,
        vec_z          => vec_z,
        gyro_x         => gyro_x,
        gyro_y         => gyro_y,
        gyro_z         => gyro_z,
        data_out_valid => data_out_valid,
        out_x          => out_x,
        out_y          => out_y,
        out_z          => out_z
    );

    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    stim_proc : PROCESS
    BEGIN
        -- Reset
        rst <= '1';
        WAIT FOR 100 ns;
        rst <= '0';
        WAIT FOR 100 ns;

        -- Provide input data
        data_in_valid <= TRUE;
        -- out_x = vec_x - vec_y*gyro_z + vec_z*gyro_y
        --  1.0  =  1.0  - 2.0*0.13     + 3.0*0.05
        vec_x         <= to_sfixed(1.0, 15, -16);
        vec_y         <= to_sfixed(2.0, 15, -16);
        vec_z         <= to_sfixed(3.0, 15, -16);
        gyro_x        <= to_sfixed(0.1, 15, -16);
        gyro_y        <= to_sfixed(0.05, 15, -16);
        gyro_z        <= to_sfixed(0.13, 15, -16);
        WAIT FOR TbPeriod;
        data_in_valid <= FALSE;

        -- Wait for output
        WAIT UNTIL data_out_valid = TRUE;
        --ASSERT out_x = to_sfixed(0.4, 15, -16) REPORT "Incorrect out_x value" SEVERITY ERROR;
        --ASSERT out_y = to_sfixed(2.9, 15, -16) REPORT "Incorrect out_y value" SEVERITY ERROR;
        --ASSERT out_z = to_sfixed(1.8, 15, -16) REPORT "Incorrect out_z value" SEVERITY ERROR;
        WAIT FOR TbPeriod*100;
        -- Add more test cases as needed
        
        TbSimEnded <= '1';

        WAIT;
    END PROCESS;
END ARCHITECTURE tb;
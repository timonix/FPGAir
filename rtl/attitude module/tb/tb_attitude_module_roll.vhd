LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY tb_attitude_module_roll IS
END ENTITY tb_attitude_module_roll;

ARCHITECTURE sim OF tb_attitude_module_roll IS

    -- Constants
    CONSTANT data_width : POSITIVE := 16;

    -- Signals
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '0';
    SIGNAL data_in_valid : BOOLEAN := FALSE;
    SIGNAL gravity_x : signed(data_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL gravity_y : signed(data_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL gravity_z : signed(data_width - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_out_valid : BOOLEAN;
    SIGNAL roll : unsigned(data_width - 1 DOWNTO 0);
    
    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

BEGIN

    -- Instantiate the attitude_module
    uut : ENTITY work.attitude_module_roll(rtl)
    GENERIC MAP (
        data_width => data_width
    )
    PORT MAP (
        clk => clk,
        rst => rst,
        data_in_valid => data_in_valid,
        gravity_x => gravity_x,
        gravity_y => gravity_y,
        gravity_z => gravity_z,
        data_out_valid => data_out_valid,
        roll => roll
    );
    
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;
    
    -- Stimulus process
    stim_process : PROCESS
    BEGIN
        -- Reset
        rst <= '1';
        WAIT FOR 100 ns;
        rst <= '0';
        WAIT FOR 100 ns;

        -- Test case 1
        data_in_valid <= TRUE;
        gravity_x <= TO_SIGNED(0, data_width);
        gravity_y <= TO_SIGNED(16384, data_width);  -- 0.5 in Q15 format
        gravity_z <= TO_SIGNED(16384, data_width);  -- 0.5 in Q15 format
        WAIT FOR TbPeriod;
        data_in_valid <= FALSE;
        WAIT FOR TbPeriod*20;
        --WAIT UNTIL data_out_valid = TRUE;
        --ASSERT roll = TO_UNSIGNED(8192, data_width) REPORT "Test case 1 failed" SEVERITY error;

        -- Test case 2
--        data_in_valid <= TRUE;
--        gravity_x <= TO_SIGNED(0, data_width);
--        gravity_y <= TO_SIGNED(-16384, data_width);  -- -0.5 in Q15 format
--        gravity_z <= TO_SIGNED(16384, data_width);   -- 0.5 in Q15 format
--        WAIT FOR clk_period;
--        data_in_valid <= FALSE;
        --WAIT UNTIL data_out_valid = TRUE;
        --ASSERT roll = TO_UNSIGNED(57344, data_width) REPORT "Test case 2 failed" SEVERITY error;

        -- Add more test cases as needed

        WAIT FOR TbPeriod;
        --ASSERT FALSE REPORT "Simulation finished" SEVERITY note;
        TbSimEnded <= '1';
        WAIT;
    END PROCESS;

END ARCHITECTURE sim;
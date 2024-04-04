LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY attitude_module_roll IS
    GENERIC (
        data_width : POSITIVE := 16
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        data_in_valid   : in BOOLEAN;
        gravity_x : IN signed(data_width - 1 DOWNTO 0);
        gravity_y : IN signed(data_width - 1 DOWNTO 0);
        gravity_z : IN signed(data_width - 1 DOWNTO 0);
        
        data_out_valid  : out BOOLEAN;
        roll : OUT unsigned(data_width - 1 DOWNTO 0)
    );
END ENTITY attitude_module_roll;

ARCHITECTURE rtl OF attitude_module_roll IS

    -- Internal signals
    SIGNAL cordic_x : signed(data_width - 1 DOWNTO 0);
    SIGNAL cordic_y : signed(data_width - 1 DOWNTO 0);
    SIGNAL cordic_angle : unsigned(data_width - 1 DOWNTO 0);
    SIGNAL cordic_update : BOOLEAN;
    SIGNAL cordic_ready : BOOLEAN;
    SIGNAL cordic_done : BOOLEAN;

BEGIN

    -- Instantiate the cordic module
    cordic_inst: entity work.cordic
    GENERIC MAP (
        mode => "vector",
        iterations => 15,
        data_width_vector => data_width,
        data_width_angle => data_width
    )
    PORT MAP (
        clk => clk,
        rst => rst,
        i_x => gravity_y,
        i_y => gravity_z,
        i_angle => (OTHERS => '0'),
        update_data => cordic_update,
        ready_to_recieve => cordic_ready,
        computation_done => cordic_done,
        o_x => cordic_x,
        o_y => cordic_y,
        o_angle => cordic_angle
    );

    -- Roll calculation process
    PROCESS (clk)
    BEGIN

        IF rising_edge(clk) THEN
            cordic_update <= data_in_valid;
            data_out_valid <= cordic_done;
            roll <= cordic_angle;
            
            IF rst = '1' THEN
                data_out_valid <= FALSE;
                cordic_update <= FALSE;
            end if;
        END IF;
    END PROCESS;

END ARCHITECTURE rtl;
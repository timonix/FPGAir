LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_radio_servo_gyro_top IS
END tb_radio_servo_gyro_top;

ARCHITECTURE behavior OF tb_radio_servo_gyro_top IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT radio_servo_gyro_top
    PORT(
        sys_clk      : IN  std_logic;
        sys_rst_n    : IN  std_logic;
        led          : OUT std_logic_vector(5 downto 0);
        channel_1    : IN  std_logic;
        Motor_1      : OUT std_logic
    );
END COMPONENT;

    --Inputs
signal clk      : std_logic := '0';
signal sys_rst_n    : std_logic := '1';
signal channel_1    : std_logic := '0';

    --Outputs
signal led          : std_logic_vector(5 downto 0);
signal Motor_1      : std_logic;

signal TbSimEnded : boolean := false;

    -- Clock period definitions
constant clk_period : time := 37 ns; -- Adjust the clock period accordingly

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: radio_servo_gyro_top PORT MAP (
        sys_clk => clk,
        sys_rst_n => sys_rst_n,
        led => led,
        channel_1 => channel_1,
        Motor_1 => Motor_1
    );

    -- Clock process definitions
    clk <= not clk after clk_period / 2 when not TbSimEnded else '0';

    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns.
        sys_rst_n <= '1';
        wait for 100 ns;
        sys_rst_n <= '0';
        wait for 100 ns;

        -- Stimulate Inputs
        -- Example: Generate PWM signal for channel_1
        -- Please adjust the timing and pattern according to your design needs.
        channel_1 <= '1';
        wait for 1500 us; -- High time of the PWM
        channel_1 <= '0';
        wait for 1000 us;  -- Low time of the PWM
        
        
        channel_1 <= '1';
        wait for 1000 us; -- High time of the PWM
        channel_1 <= '0';
        wait for 1500 us;  -- Low time of the PWM
        
        channel_1 <= '1';
        wait for 910 us; -- High time of the PWM
        channel_1 <= '0';
        wait for 1500 us;  -- Low time of the PWM
        
        channel_1 <= '1';
        wait for 2000 us; -- High time of the PWM
        channel_1 <= '0';
        wait for 500 us;  -- Low time of the PWM
        
        channel_1 <= '1';
        wait for 2100 us; -- High time of the PWM
        channel_1 <= '0';
        wait for 400 us;  -- Low time of the PWM
        
        wait for 10000 ns;
        
        TbSimEnded <= true;
        
        -- (Continue with more test patterns or end simulation)
        
        -- Report and finish
        assert FALSE report "End of simulation" severity NOTE;
        wait;
    end process;

END;
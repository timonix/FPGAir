library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cordic_vector_tb is
end cordic_vector_tb;

architecture sim of cordic_vector_tb is
    constant CLOCK_PERIOD : time := 10 ns; -- Clock period (100 MHz)
    
    signal rst_tb : std_logic := '1'; -- Testbench reset signal
    signal i_x_tb : signed(15 downto 0); -- Testbench input x coordinate
    signal i_y_tb : signed(15 downto 0); -- Testbench input y coordinate
    signal i_angle_tb : unsigned(15 downto 0); -- Testbench input angle
    signal update_data_tb : boolean := false; -- Testbench update data signal
    signal ready_to_receive_tb : boolean; -- Testbench ready to receive signal
    signal computation_done_tb : boolean; -- Testbench computation done signal
    signal o_x_tb : signed(15 downto 0); -- Testbench output x coordinate
    signal o_y_tb : signed(15 downto 0); -- Testbench output y coordinate
    signal o_angle_tb : unsigned(15 downto 0); -- Testbench output angle
    
    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';
    
    constant one : unsigned(15 downto 0) := (1 => '1', others => '0');
    signal deg_180 : unsigned(15 downto 0) := shift_left(one,16-2);
    signal deg_90 : unsigned(15 downto 0) := shift_left(one,16-3);
    signal deg_45 : unsigned(15 downto 0) := shift_left(one,16-4);
    
    signal deg_270 : unsigned(15 downto 0) := deg_180 or deg_90; -- minus 90
    signal deg_315 : unsigned(15 downto 0) := deg_180 or deg_90 or deg_45; -- minus 90
    
    
    
    -- Stimulus process
    
    
    
begin
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    
    -- Instantiate DUT
    dut : entity work.cordic(rtl)
    generic map(
        mode => "vector",
        iterations => 15,
        data_width_vector => 16,
        data_width_angle => 16
    )
    port map(
        clk => TbClock,
        rst => rst_tb,
        i_x => i_x_tb,
        i_y => i_y_tb,
        i_angle => i_angle_tb,
        update_data => update_data_tb,
        ready_to_recieve => ready_to_receive_tb,
        computation_done => computation_done_tb,
        o_x => o_x_tb,
        o_y => o_y_tb,
        o_angle => o_angle_tb
    );
    
    process
    begin
        wait for 20 ns; -- Wait for initial stabilization
        rst_tb <= '1';
        wait for 100 ns;
        rst_tb <= '0';
        wait for 100 ns;
        -- Apply inputs
        i_x_tb <= to_signed(10, i_x_tb'length);
        i_y_tb <= to_signed(10, i_y_tb'length);
        --i_angle_tb <= to_unsigned(0, i_angle_tb'length);
        i_angle_tb <= deg_45;
        
        wait for TbPeriod*5;
        
        update_data_tb <= true; -- Trigger data update
        wait for TbPeriod;
        update_data_tb <= false;
        wait for TbPeriod*50;
        -- Display outputs
        report "Output X: " & to_string(o_x_tb);
        report "Output Y: " & to_string(o_y_tb);
        report "Output Angle: " & to_string(o_angle_tb);
        wait for 100 ns;
        TbSimEnded <= '1';
        wait;
    end process;

    
end sim;

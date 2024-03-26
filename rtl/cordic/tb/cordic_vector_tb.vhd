library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.common_pkg.all;
use IEEE.MATH_REAL.ALL;

entity cordic_vector_tb is
end cordic_vector_tb;

architecture tb of cordic_vector_tb is
    constant iterations : positive := 10;
    
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    
    signal x_in        : signed(15 downto 0) := (others => '0');
    signal y_in        : signed(15 downto 0) := (others => '0');
    
    signal data_valid_s : boolean := false;
    signal data_ready_s : boolean;
    
    signal o_x          : signed(15 downto 0);
    signal o_y          : signed(15 downto 0);
    signal o_angle      : unsigned(15 downto 0);
    
    signal update : boolean;
    
    constant clk_period : time := 10 ns;
    
    constant scale_factor: real := 2.0 ** 16/ (2.0 * MATH_PI);
    
    signal target_angle : unsigned(15 downto 0);
    signal error : unsigned(15 downto 0);
    signal error_real : real;
    
impure function calculate_target_angle(
    x_in_f : in signed;
    y_in_f : in signed;
    scale_factor_f : in real
) return unsigned is
    variable y_over_x : real;
    variable scaled_atan : real;
    variable rounded_atan : integer;
    variable target_angle_vec : std_logic_vector(target_angle'range);
    variable target_angle_range : signed(target_angle'range);

begin
    -- Calculate y_over_x
    scaled_atan := arctan(real(to_integer(y_in_f)),real(to_integer(x_in_f))) * scale_factor_f;
    rounded_atan := integer(round(scaled_atan));
    target_angle_vec := std_logic_vector(to_signed(rounded_atan, target_angle_range));
    
    -- Convert target_angle_vec to unsigned
    return unsigned(target_angle_vec);
end function;
    
    
begin
    -- Instantiate the cordic_vector entity
    uut: entity work.cordic_vector
        generic map (
            iterations => iterations,
            data_width_vector => 16,
            data_width_angle => 16
        )
        port map (
            clk => clk,
            rst => rst,
            x_in => x_in,
            y_in => y_in,
            update_data => update,
            ready_to_recieve => open,
            computation_done => open,
            o_x => o_x,
            o_y => o_y,
            o_angle => o_angle
        );
    
    -- Clock process
    clk_process: process
    begin
        while now < 1000 ns loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Reset
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait for clk_period;
        
        -- Test case 1
        x_in <= to_signed(-3, 16);
        y_in <= to_signed(-2, 16);
        wait for clk_period*10;
        update <= true;
        wait for clk_period;
        update <= false;
         wait for 1 ps;

        target_angle <= calculate_target_angle(x_in,y_in,scale_factor);
        wait for 1 ps;
        
        wait for clk_period*30;
        error <= target_angle-o_angle;
        wait for 1 ps;
        error_real <= real(to_integer(error))/scale_factor;
        wait for clk_period*10;

        
        -- Add more test cases as needed
        
        wait;
    end process;
    
end tb;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.fixed_pkg.all;

entity tb_scale_bias_correction is
end entity tb_scale_bias_correction;

architecture sim of tb_scale_bias_correction is
    
    signal clk             : std_logic := '0';
    signal rst             : std_logic := '0';
    signal data_in_valid   : boolean := false;
    signal x_in            : sfixed(15 downto 0);
    signal y_in            : sfixed(15 downto 0);
    signal z_in            : sfixed(15 downto 0);
    signal x_bias          : sfixed(15 downto -16);
    signal y_bias          : sfixed(15 downto -16);
    signal z_bias          : sfixed(15 downto -16);
    signal x_scale         : sfixed(15 downto -16);
    signal y_scale         : sfixed(15 downto -16);
    signal z_scale         : sfixed(15 downto -16);
    signal data_out_valid  : boolean;
    signal x_out           : sfixed(15 downto -16);
    signal y_out           : sfixed(15 downto -16);
    signal z_out           : sfixed(15 downto -16);
    
    signal test_input : real;
    signal test_scale : real := 1.5;
    signal test_bias  : real := 145.0;
    
    
    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';
    
begin
    
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    clk <= TbClock;
    
    -- Instantiate the scale_bias_correction entity
    uut: entity work.scale_bias_correction
    generic map (
        data_in_integer_bits => 16,
        data_in_fractional_bits => 0,
        data_out_integer_bits => 16,
        data_out_fractional_bits => -16,
        scale_integer_bits => 16,
        scale_fractional_bits => -16,
        bias_integer_bits => 16,
        bias_fractional_bits => -16
    )
    port map (
        clk => clk,
        rst => rst,
        data_in_valid => data_in_valid,
        x_in => x_in,
        y_in => y_in,
        z_in => z_in,
        x_bias => x_bias,
        y_bias => y_bias,
        z_bias => z_bias,
        x_scale => x_scale,
        y_scale => y_scale,
        z_scale => z_scale,
        data_out_valid => data_out_valid,
        x_out => x_out,
        y_out => y_out,
        z_out => z_out
    );
    
    -- Stimulus process
    stim_process: process
    begin
        -- Reset
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;
        
        test_input <= 5678.0;
        wait for 1 ps;
        
        data_in_valid <= true;
        
        x_in <= to_sfixed(((test_input)*test_scale)+test_bias, x_in);
        y_in <= to_sfixed(((test_input+10.0)*test_scale)+test_bias, x_in);
        z_in <= to_sfixed(((test_input+20.0)*test_scale)+test_bias, x_in);

        x_bias <= to_sfixed(-test_bias, x_bias);
        y_bias <= to_sfixed(-test_bias, y_bias);
        z_bias <= to_sfixed(-test_bias, z_bias);
        x_scale <= to_sfixed(1.0/test_scale, x_scale);
        y_scale <= to_sfixed(1.0/test_scale, y_scale);
        z_scale <= to_sfixed(1.0/test_scale, z_scale);
        
        wait for TbPeriod;
        
        -- Wait for output
        wait until data_out_valid = true;
        
        -- Check output
--        assert x_out = to_sfixed(test_input, x_out) report "Error: x_out mismatch" severity error;
--        assert y_out = to_sfixed(test_input+1.0, y_out) report "Error: y_out mismatch" severity error;
--        assert z_out = to_sfixed(test_input+2.0, z_out) report "Error: z_out mismatch" severity error;
--
        wait for TbPeriod*10;
        -- Finish simulation
        TbSimEnded <= '1';
        
        wait;
    end process;
end architecture sim;
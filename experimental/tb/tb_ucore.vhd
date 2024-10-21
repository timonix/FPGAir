library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.fixed_pkg.all;

entity tb_ucore is
end entity tb_ucore;

architecture test of tb_ucore is
    -- Constants for integer and fractional bits
    constant integer_bits : integer := 6;
    constant fractional_bits : integer := 12;
    
    -- Clock and reset signals
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    
    -- Input signals
    signal input_A_X, input_A_Y, input_A_Z : sfixed(integer_bits-1 downto -fractional_bits);
    signal input_B_X, input_B_Y, input_B_Z : sfixed(integer_bits-1 downto -fractional_bits);
    signal input_C_X, input_C_Y, input_C_Z : sfixed(integer_bits-1 downto -fractional_bits);
    
    -- Output signals
    signal output_X, output_Y, output_Z : sfixed(integer_bits-1 downto -fractional_bits);
    
    -- Control signals
    signal instruction_start_pointer : integer range 0 to 31 := 1;
    signal run  : boolean := false;
    signal core_done : boolean;
    signal core_ready : boolean;
    
    -- Clock generation process (50MHz clock -> period = 20ns)
    constant clk_period : time := 20 ns;
    
    -- UUT instantiation
    component ucore is
        generic (
            integer_bits : integer := 6;
            fractional_bits : integer := 12
        );
        port (
            clk   : in std_logic;
            rst   : in std_logic;
            input_A_X : in sfixed(integer_bits-1 downto -fractional_bits);
            input_A_Y : in sfixed(integer_bits-1 downto -fractional_bits);
            input_A_Z : in sfixed(integer_bits-1 downto -fractional_bits);
            input_B_X : in sfixed(integer_bits-1 downto -fractional_bits);
            input_B_Y : in sfixed(integer_bits-1 downto -fractional_bits);
            input_B_Z : in sfixed(integer_bits-1 downto -fractional_bits);
            input_C_X : in sfixed(integer_bits-1 downto -fractional_bits);
            input_C_Y : in sfixed(integer_bits-1 downto -fractional_bits);
            input_C_Z : in sfixed(integer_bits-1 downto -fractional_bits);
            output_X : out sfixed(integer_bits-1 downto -fractional_bits);
            output_Y : out sfixed(integer_bits-1 downto -fractional_bits);
            output_Z : out sfixed(integer_bits-1 downto -fractional_bits);
            instruction_start_pointer : in integer range 0 to 31;
            run  : in boolean;
            core_ready : out boolean;
            core_done : out boolean
        );
    end component;
    
    constant TbPeriod : time      := 10 ns;
    signal TbSimRunning : boolean := true;
    signal TbClock    : std_logic := '0';
    
    signal target_X : sfixed(integer_bits-1 downto -fractional_bits);
    signal target_Y : sfixed(integer_bits-1 downto -fractional_bits);
    signal target_Z : sfixed(integer_bits-1 downto -fractional_bits);
    
begin
    
        -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimRunning else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    
    -- UUT (Unit Under Test) instantiation
    UUT: ucore
    generic map (
        integer_bits => integer_bits,
        fractional_bits => fractional_bits
    )
    port map (
        clk   => clk,
        rst   => rst,
        input_A_X => input_A_X,
        input_A_Y => input_A_Y,
        input_A_Z => input_A_Z,
        input_B_X => input_B_X,
        input_B_Y => input_B_Y,
        input_B_Z => input_B_Z,
        input_C_X => input_C_X,
        input_C_Y => input_C_Y,
        input_C_Z => input_C_Z,
        output_X => output_X,
        output_Y => output_Y,
        output_Z => output_Z,
        instruction_start_pointer => instruction_start_pointer,
        run  => run,
        core_done => core_done,
        core_ready => core_ready
    );
    
    -- Test stimulus process
    stimulus: process
    begin
        -- Reset the design
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Apply inputs for vector A, B, and C (as fixed-point values)
        input_A_X <= to_sfixed(2.5, input_A_X);
        input_A_Y <= to_sfixed(-1.25, input_A_Y);
        input_A_Z <= to_sfixed(0.75, input_A_Z);
        
        input_B_X <= to_sfixed(1.5, input_B_X);
        input_B_Y <= to_sfixed(0.5, input_B_Y);
        input_B_Z <= to_sfixed(-2.0, input_B_Z);
        
        input_C_X <= to_sfixed(0.0, input_C_X);
        input_C_Y <= to_sfixed(1.0, input_C_Y);
        input_C_Z <= to_sfixed(-0.5, input_C_Z);
        
        -- Start the process by setting 'run' to true
        
        
        run <= true;
        wait for TbPeriod;
        run <= false;
        
        target_X <= resize (
            arg => input_A_X-input_A_Y*input_B_Z+input_A_Z*input_B_Y,
            size_res => target_X,
            overflow_style => IEEE.fixed_float_types.fixed_saturate,
            round_style => IEEE.fixed_float_types.fixed_truncate
        );
        
        target_Y <= resize (
            arg => input_A_Y-input_A_Z*input_B_X+input_A_X*input_B_Z,
            size_res => target_X,
            overflow_style => IEEE.fixed_float_types.fixed_saturate,
            round_style => IEEE.fixed_float_types.fixed_truncate
        );
        
        target_Z <= resize (
            arg => input_A_Z-input_A_X*input_B_Y+input_A_Y*input_B_X,
            size_res => target_X,
            overflow_style => IEEE.fixed_float_types.fixed_saturate,
            round_style => IEEE.fixed_float_types.fixed_truncate
        );
        
        -- out_x = vec_x - vec_y*gyro_z + vec_z*gyro_y
        -- out_y = vec_y - vec_z*gyro_x + vec_x*gyro_z
        -- out_z = vec_z - vec_x*gyro_y + vec_y*gyro_x
        
        -- Observe done signal and outputs
        wait until core_done = true;
        report "Target Outputs:" &
                             " X = " & real'image(to_real(target_X))&
                             " Y = " & real'image(to_real(target_Y)) &
                             " Z = " & real'image(to_real(target_Z));
        
        assert false report "Simulation complete. Outputs:" &
                             " X = " & real'image(to_real(output_X)) &
                             " Y = " & real'image(to_real(output_Y)) &
                             " Z = " & real'image(to_real(output_Z))
        
        severity note;
        TbSimRunning <= false;
        
        -- End simulation
        wait;
    end process;

end architecture test;

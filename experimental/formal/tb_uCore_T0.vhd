library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.fixed_pkg.all;

use work.common_pkg.all;

entity tb_uCore_T0 is
    port (
        clk   : in std_logic;
        rst   : in std_logic
    );
end entity tb_uCore_T0;

architecture test of tb_uCore_T0 is
    -- Constants for integer and fractional bits
    constant integer_bits : integer := 6;
    constant fractional_bits : integer := 12;
    
    -- Input signals
    signal input_A_X, input_A_Y, input_A_Z : sfixed(integer_bits-1 downto -fractional_bits);
    signal input_B_X, input_B_Y, input_B_Z : sfixed(integer_bits-1 downto -fractional_bits);
    signal input_C_X, input_C_Y, input_C_Z : sfixed(integer_bits-1 downto -fractional_bits);
    
    signal A_X, A_Y, A_Z : sfixed(integer_bits-1 downto -fractional_bits);
    signal B_X, B_Y, B_Z : sfixed(integer_bits-1 downto -fractional_bits);
    signal C_X, C_Y, C_Z : sfixed(integer_bits-1 downto -fractional_bits);
    
    -- Output signals
    signal output_X, output_Y, output_Z : sfixed(integer_bits-1 downto -fractional_bits);
    
    -- Control signals
    signal instruction_start_pointer : integer range 0 to 31 := 1;
    signal run  : boolean := false;
    signal core_done : boolean;
    signal core_ready : boolean;
    
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
    
    signal target_X : sfixed(integer_bits-1 downto -fractional_bits);
    signal target_Y : sfixed(integer_bits-1 downto -fractional_bits);
    signal target_Z : sfixed(integer_bits-1 downto -fractional_bits);
    
    signal step_counter : integer := 0;
    
    signal test_0 : boolean;
    
    signal assume_0 : boolean;
    signal assume_1 : boolean;
    
begin
    
    assume_0 <= abs(input_A_X) < to_sfixed(50.0, input_A_X) AND abs(input_A_Y) < to_sfixed(50.0, input_A_X) AND abs(input_A_Z) < to_sfixed(50.0, input_A_X);
    assume_1 <= abs(input_B_X) < to_sfixed(20.0, input_A_X) AND abs(input_B_Y) < to_sfixed(20.0, input_A_X) AND abs(input_B_Z) < to_sfixed(20.0, input_A_X);

    test_0 <= abs(fixed_sub(target_X,output_X))<to_sfixed(0.00048828125, target_X);

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
    
    process (clk)
    begin
        if rising_edge(clk) then
            run <= false;
            step_counter <= step_counter+1;
            if step_counter = 1 then
                input_A_X <= A_X;
                input_A_Y <= A_Y;
                input_A_Z <= A_Z;
                
                input_B_X <= B_X;
                input_B_Y <= B_Y;
                input_B_Z <= B_Z;
                
                input_C_X <= C_X;
                input_C_Y <= C_Y;
                input_C_Z <= C_Z;
                run <= true;
            end if;
            
            if step_counter = 2 then
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
            end if;
        end if;
    end process;
    
    -- PSL default clock is rising_edge(clk);
    -- PSL S2: assert always (run and core_ready -> next_e[0 to 15] (core_done));
    -- PSL A0: assume always (assume_0);
    -- PSL A1: assume always (assume_1);
    -- PSL T0: assert always (core_done -> test_0);


end architecture test;

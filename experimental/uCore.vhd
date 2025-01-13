library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.fixed_pkg.all;

use work.common_pkg.muladd;
use work.common_pkg.to_sfixed24;
use work.common_pkg.comp2;

entity uCore is
    generic (
        integer_bits : integer := 6;
        fractional_bits : integer := 18
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
        
        instruction_start_pointer : in integer range 0 to 63;
        
        run  : in boolean;
        core_ready : out boolean;
        core_done : out boolean
        
    );
end entity uCore;

architecture rtl of uCore is
    type instruction_T is ( None, Move, Multiply, Move_negative );
    
    signal instruction_pointer : integer range 0 to 63 := 0;
    
    type source_T is (Zero, One, ext_AX, ext_AY, ext_AZ, ext_BX, ext_BY, ext_BZ, ext_CX, ext_CY, ext_CZ, A, B, C, Res, None);
    type sources_T is array (0 to 2) of source_T;
    
    type destination_T is ( None,A,B,C,ext_out);
    
    type instruction_R is record
        instruction : instruction_T;
        source      : sources_T;
        destination : destination_T;
    end record;
    
    constant instruction_RZ : instruction_R := (instruction => None, source => (Zero,Zero,Zero),destination => None);
    
    type ROM_T is array (0 to 63) of instruction_R;
    constant rom: ROM_T := (
        
        -- out_x = vec_x - vec_y*gyro_z + vec_z*gyro_y
        -- out_y = vec_y - vec_z*gyro_x + vec_x*gyro_z
        -- out_z = vec_z - vec_x*gyro_y + vec_y*gyro_x
        1  => (instruction => Move    , source => (ext_AZ, ext_AX, ext_AY ), destination => A),
        2  => (instruction => Move    , source => (ext_BY, ext_BZ, ext_BX ), destination => B),
        3  => (instruction => Move    , source => (Zero  , Zero  , Zero )  , destination => C),
        4  => (instruction => Multiply, source => (None  , None  , None)   , destination => None),
        5  => (instruction => Move    , source => (Res   , Res   , Res )   , destination => C),

        6  => (instruction => Move_negative , source => (ext_AY, ext_AZ, ext_AX ), destination => A),
        7  => (instruction => Move          , source => (ext_BZ, ext_BX, ext_BY ), destination => B),
        8  => (instruction => Multiply      , source => (None  , None  , None)   , destination => None),
        9  => (instruction => Move          , source => (Res   , Res   , Res )   , destination => C),
        
        10 => (instruction => Move    , source => (ext_AX, ext_AY, ext_AZ ), destination => A),
        11 => (instruction => Move    , source => (One   , One   , One )   , destination => B),
        12 => (instruction => Multiply, source => (None  , None  , None)   , destination => None),
        13 => (instruction => Move    , source => (Res   , Res   , Res )   , destination => ext_out),
        
        
        -- Scale and bias A*s+b
        15 => (instruction => Move    , source => (ext_AX, ext_AY, ext_AZ ), destination => A),
        16 => (instruction => Move    , source => (ext_BX, ext_BY, ext_BZ ), destination => B),
        17 => (instruction => Move    , source => (ext_CX, ext_CY, ext_CZ ), destination => C),
        18 => (instruction => Multiply, source => (None  , None  , None)   , destination => None),
        19 => (instruction => Move    , source => (Res   , Res   , Res )   , destination => ext_out),
        
        -- combine
        21 => (instruction => Move    , source => (ext_AX, ext_AY, ext_AZ ), destination => A),
        22 => (instruction => Move    , source => (ext_BX, ext_BY, ext_BZ ), destination => B),
        23 => (instruction => Move    , source => (Zero  , Zero  , Zero )  , destination => C),
        24 => (instruction => Multiply, source => (None  , None  , None)   , destination => None),
        25 => (instruction => Move    , source => (Res   , Res   , Res )   , destination => ext_out),
        
        27 => (instruction => Move    , source => (ext_AX, ext_AY, ext_AZ ), destination => A),
        28 => (instruction => Move    , source => (ext_BX, ext_BY, ext_BZ ), destination => B),
        29 => (instruction => Move    , source => (Res   , Res   , Res )   , destination => C),
        30 => (instruction => Multiply, source => (None  , None  , None)   , destination => None),
        31 => (instruction => Move    , source => (Res   , Res   , Res )   , destination => ext_out),

        
        
        others =>  instruction_RZ);

    signal current_instruction : instruction_R;
    
    type multi_regs is array (0 to 2) of sfixed(integer_bits-1 downto -fractional_bits);
    signal A_regs  : multi_regs;
    signal B_regs  : multi_regs;
    signal C_regs  : multi_regs;
    signal result_regs : multi_regs;
    signal DEBUG_result_regs_X : sfixed(integer_bits-1 downto -fractional_bits);
    signal DEBUG_result_regs_Y : sfixed(integer_bits-1 downto -fractional_bits);
    signal DEBUG_result_regs_Z : sfixed(integer_bits-1 downto -fractional_bits);
    
    signal s_done : boolean := false;
    signal s_ready : boolean := true;

    signal output_regs : multi_regs := (others => (others => '0'));

begin
    

    core_done <= s_done;
    core_ready <= s_ready;
    
    current_instruction <= ROM(instruction_pointer);
    
    DEBUG_result_regs_X <= result_regs(0);
    DEBUG_result_regs_Y <= result_regs(1);
    DEBUG_result_regs_Z <= result_regs(2);
    
    output_X <= output_regs(0);
    output_Y <= output_regs(1);
    output_Z <= output_regs(2);
    
    process (clk)
    variable v_source : multi_regs;
    
    begin
        if rising_edge(clk) then
            
            s_done <= false;
            for i in 0 to 2 loop
                v_source(i) := (others => '0');

                case current_instruction.source(i) is
                    when Zero | None => v_source(i) := (others => '0');
                        
                    when One => v_source(i) := to_sfixed(1.0,v_source(i));
                        
                    when A => v_source(i) := A_regs(i);
                    when B => v_source(i) := B_regs(i);
                    when C => v_source(i) := C_regs(i);
                        
                    when Res => v_source(i) := result_regs(i);
                        
                    when ext_AX => v_source(i) := input_A_X;
                    when ext_AY => v_source(i) := input_A_Y;
                    when ext_AZ => v_source(i) := input_A_Z;
                        
                    when ext_BX => v_source(i) := input_B_X;
                    when ext_BY => v_source(i) := input_B_Y;
                    when ext_BZ => v_source(i) := input_B_Z;
                        
                    when ext_CX => v_source(i) := input_C_X;
                    when ext_CY => v_source(i) := input_C_Y;
                    when ext_CZ => v_source(i) := input_C_Z;
                end case;
                
                case current_instruction.instruction is
                    when Multiply      => result_regs(i) <= muladd( A_regs(i),B_regs(i), C_regs(i),C_regs(i));
                    when Move_negative => v_source(i) := comp2(v_source(i));
                    when Move =>
                    when None =>
                end case;
                
                case current_instruction.destination is
                    when None =>
                    when A  => A_regs(i) <= v_source(i);
                    when B  => B_regs(i) <= v_source(i);
                    when C  => C_regs(i) <= v_source(i);
                    when ext_out => output_regs(i) <= v_source(i); s_done <= true; s_ready <= true;
                end case;
            end loop;
            
            if run and s_ready then
                instruction_pointer <= instruction_start_pointer;
                s_ready <= false;
            end if;
            
            if not s_ready then
                instruction_pointer <= instruction_pointer +1;
            end if;
            
        end if;
    end process;

    -- PSL default clock is rising_edge(clk);
    -- PSL S2: assert always (run and core_ready -> next_e[0 to 33] (core_done));
    -- PSL S1: assert always (run and s_ready -> next (not s_ready));
    
    -- PSL cover {core_done};

    


end architecture;
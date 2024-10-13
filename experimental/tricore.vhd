library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use IEEE.fixed_pkg.all;

use work.common_pkg.muladd;
use work.common_pkg.to_sfixed24;
use work.common_pkg.comp2;

entity tricore is
    generic (
        integer_bits : integer := 6;
        fractional_bits : integer := 12
    );
    port (
        clk   : in std_logic;
        rst : in std_logic;
        
        acc_X : in sfixed(integer_bits-1 downto -fractional_bits);
        acc_Y : in sfixed(integer_bits-1 downto -fractional_bits);
        acc_Z : in sfixed(integer_bits-1 downto -fractional_bits);
        
        gyro_X : in sfixed(integer_bits-1 downto -fractional_bits);
        gyro_Y : in sfixed(integer_bits-1 downto -fractional_bits);
        gyro_Z : in sfixed(integer_bits-1 downto -fractional_bits);
        
        mag_X : in sfixed(integer_bits-1 downto -fractional_bits);
        mag_Y : in sfixed(integer_bits-1 downto -fractional_bits);
        mag_Z : in sfixed(integer_bits-1 downto -fractional_bits);
        
        roll  : in sfixed(integer_bits-1 downto -fractional_bits);
        pitch : in sfixed(integer_bits-1 downto -fractional_bits);
        yaw   : in sfixed(integer_bits-1 downto -fractional_bits);
        
        output_X : out sfixed(integer_bits-1 downto -fractional_bits);
        output_Y : out sfixed(integer_bits-1 downto -fractional_bits);
        output_Z : out sfixed(integer_bits-1 downto -fractional_bits);
        
        instruction_pointer : in integer range 0 to 63
        
    );
end entity tricore;

architecture rtl of tricore is
    type instruction_T is ( None, Multiply, Move_negative );
    
    type source_T is (Zero,One,Alpha,Beta, A,B,C,Res, Adjusted_Gyro_X,Adjusted_Gyro_Y,Adjusted_Gyro_Z, Down_Vec_X,Down_vec_Y,Down_vec_Z,Right_Vec_X,Right_Vec_Y,Right_Vec_Z, ext_acc_X,ext_acc_Y,ext_acc_Z,ext_roll,ext_pitch,ext_yaw,ext_gyro_X,ext_gyro_Y,ext_gyro_Z,ext_mag_X,ext_mag_Y,ext_mag_Z,

            Const_scale_gyro,Const_bias_gyro, Const_scale_acc,Const_bias_acc,
            const_mag_adjust_A,const_mag_adjust_B,const_mag_adjust_C,const_mag_bias
        );
        type sources_T is array (0 to 2) of source_T;
        
        type destination_T is ( None,A,B,C,Adjusted_Gyro,Down_Vec,Right_Vec,ext_out);
        
        constant c_alpha : real := 0.95;
        constant c_beta : real := 0.05;
        
        
        type instruction_R is record
            instruction : instruction_T;
            source      : sources_T;
            destination : destination_T;
        end record;
        
        constant instruction_RZ : instruction_R := (instruction => None, source => (Zero,Zero,Zero),destination => None);
        
    -- out_x = vec_x - vec_y*gyro_z + vec_z*gyro_y
    -- out_y = vec_y - vec_z*gyro_x + vec_x*gyro_z
    -- out_z = vec_z - vec_x*gyro_y + vec_y*gyro_x

        type ROM_T is array (0 to 63) of instruction_R;
        constant rom: ROM_T := (
        -- SCALE AND BIAS GYRO UNTESTED
            1  => (instruction => None, source => (Const_scale_gyro  ,Const_scale_gyro  ,Const_scale_gyro ), destination => A),
            2  => (instruction => None, source => (ext_gyro_X        ,ext_gyro_Y        ,ext_gyro_Z)       , destination => B),
            3  => (instruction => None, source => (Const_bias_gyro   ,Const_bias_gyro   ,Const_bias_gyro)  , destination => C),
            4  => (instruction => Multiply, source => (Zero,Zero,Zero)   , destination => None),
            5  => (instruction => None, source => (Res  ,Res  ,Res ), destination => Adjusted_Gyro),
            
        -- ROTATE GRAVITY VECTOR BY GYRO
        -- out_x = vec_x - vec_y*gyro_z + vec_z*gyro_y
        -- out_y = vec_y - vec_z*gyro_x + vec_x*gyro_z
        -- out_z = vec_z - vec_x*gyro_y + vec_y*gyro_x
            6  => (instruction => None,     source => (Down_vec_Z  ,Down_vec_X  ,Down_vec_Y ), destination => A),
            7  => (instruction => None,     source => (Adjusted_Gyro_Y ,Adjusted_Gyro_Z ,Adjusted_Gyro_X), destination => B),
            8  => (instruction => Multiply, source => (Zero   ,Zero   ,Zero), destination => C),
            9  => (instruction => Multiply, source => (Zero   ,Zero   ,Zero), destination => None),
            
            10  => (instruction => None,          source => (Down_vec_Y  ,Down_vec_Z  ,Down_vec_X ), destination => A),
            11  => (instruction => Move_negative, source => (Adjusted_Gyro_Z ,Adjusted_Gyro_X ,Adjusted_Gyro_Y), destination => B),
            12  => (instruction => None,          source => (Res    ,Res    ,Res),   destination => C),
            13  => (instruction => Multiply,      source => (Zero   ,Zero   ,Zero), destination => None),
            
            14 => (instruction => None,     source => (Down_vec_X ,Down_vec_Y ,Down_vec_Z ), destination => A),
            15 => (instruction => None,     source => (One   ,One   ,One)   , destination => B),
            16 => (instruction => None,     source => (Res    ,Res    ,Res),   destination => C),
            17 => (instruction => Multiply, source => (Zero   ,Zero   ,Zero), destination => None),
            
        -- Scale gyro part by alpha UNTESTED
            
            18 => (instruction => None, source => (Res,Res,Res)         , destination => A),
            19 => (instruction => None, source => (Alpha,Alpha,Alpha)   , destination => B),
            20 => (instruction => None, source => (Zero   ,Zero   ,Zero),   destination => C),
            21 => (instruction => Multiply, source => (Zero   ,Zero   ,Zero), destination => None),
            22 => (instruction => None, source => (Res  ,Res  ,Res ), destination => Down_vec),
            
        -- SCALE AND BIAS ACC UNTESTED
            23 => (instruction => None, source => (Const_scale_acc  ,Const_scale_acc  ,Const_scale_acc ), destination => A),
            24 => (instruction => None, source => (ext_acc_X        ,ext_acc_Y        ,ext_acc_Z)       , destination => B),
            25 => (instruction => None, source => (Const_bias_acc   ,Const_bias_acc   ,Const_bias_acc)  , destination => C),
            26 => (instruction => Multiply, source => (Zero   ,Zero   ,Zero), destination => None),

        -- Mix acc and gyro
            27 => (instruction => None, source => (Down_vec_Y ,Down_vec_Z  ,Down_vec_X ), destination => A),
            28 => (instruction => None, source => (One  ,One  ,One) , destination => B),
            29 => (instruction => None, source => (Res  ,Res  ,Res) , destination => C),
            30 => (instruction => Multiply, source => (Zero ,Zero ,Zero), destination => None),
            31 => (instruction => None, source => (Res  ,Res  ,Res ), destination => Down_vec),
            32 => (instruction => None, source => (Res  ,Res  ,Res ), destination => ext_out),
            
            
            others =>  instruction_RZ);

        signal current_instruction : instruction_R;
        
        type multi_regs is array (0 to 2) of sfixed(integer_bits-1 downto -fractional_bits);
        signal A_regs  : multi_regs;
        signal B_regs  : multi_regs;
        signal C_regs  : multi_regs;
        signal result_regs : multi_regs;
        
        signal Adjusted_gyro_regs : multi_regs;
        signal Down_vec_regs  : multi_regs;
        signal Right_vec_regs : multi_regs;
        

        function to_multireg (A : in real; B : in real; C : in real) return multi_regs is
        variable res : multi_regs;
    begin
        res(0) := to_sfixed(A,integer_bits-1,-fractional_bits);
        res(1) := to_sfixed(B,integer_bits-1,-fractional_bits);
        res(2) := to_sfixed(C,integer_bits-1,-fractional_bits);
        return res;
    end;

    constant scale_gyro : multi_regs := to_multireg(1.0,0.134,0.65);
    constant bias_gyro  : multi_regs := to_multireg(2.0,0.1234,0.665);

    constant scale_acc  : multi_regs := to_multireg(1.24,0.1374,0.675);
    constant bias_acc   : multi_regs := to_multireg(1.11,0.1634,0.865);

    constant mag_adjust_A : multi_regs := to_multireg(1.191,0.1634,0.85);
    constant mag_adjust_B : multi_regs := to_multireg(1.112,0.164,0.865);
    constant mag_adjust_C : multi_regs := to_multireg(1.141,0.634,0.65);

    constant mag_bias : multi_regs := to_multireg(2.11,0.1634,0.065);

    signal output_regs : multi_regs;


begin
    
    current_instruction <= ROM(instruction_pointer);
    
    output_X <= output_regs(0);
    output_Y <= output_regs(1);
    output_Z <= output_regs(2);
    
    process (clk)
    variable v_source : multi_regs;
    
    begin
        if rising_edge(clk) then
            for i in 0 to 2 loop
                v_source(i) := (others => '0');
                case current_instruction.source(i) is
                    when A => v_source(i) := A_regs(i);
                    when B => v_source(i) := B_regs(i);
                    when C => v_source(i) := C_regs(i);
                        
                    when Res => v_source(i) := result_regs(i);
                        
                    when Adjusted_Gyro_X => v_source(i) := Adjusted_gyro_regs(0);
                    when Adjusted_Gyro_Y => v_source(i) := Adjusted_gyro_regs(1);
                    when Adjusted_Gyro_Z => v_source(i) := Adjusted_gyro_regs(2);
                        
                    when Down_Vec_X => v_source(i) := Down_vec_regs(0);
                    when Down_Vec_Y => v_source(i) := Down_vec_regs(1);
                    when Down_Vec_Z => v_source(i) := Down_vec_regs(2);

                    when ext_acc_X => v_source(i) := acc_X;
                    when ext_acc_Y => v_source(i) := acc_Y;
                    when ext_acc_Z => v_source(i) := acc_Z;
                        
                    when ext_gyro_X => v_source(i) := Gyro_X;
                    when ext_gyro_Y => v_source(i) := Gyro_Y;
                    when ext_gyro_Z => v_source(i) := Gyro_Z;
                        
                    when ext_mag_X => v_source(i) := mag_X;
                    when ext_mag_Y => v_source(i) := mag_Y;
                    when ext_mag_Z => v_source(i) := mag_Z;
                        
                    when Right_Vec_X => v_source(i) := Right_vec_regs(0);
                    when Right_Vec_Y => v_source(i) := Right_vec_regs(1);
                    when Right_Vec_Z => v_source(i) := Right_vec_regs(2);
                        
                    when ext_roll  => v_source(i) := roll;
                    when ext_pitch => v_source(i) := pitch;
                    when ext_yaw   => v_source(i) := yaw;
                        
                    when const_mag_adjust_A => v_source(i) := mag_adjust_A(i);
                    when const_mag_adjust_B => v_source(i) := mag_adjust_B(i);
                    when const_mag_adjust_C => v_source(i) := mag_adjust_C(i);
                    when const_mag_bias     => v_source(i) := mag_bias(i);

                    when const_scale_gyro => v_source(i) := scale_gyro(i);
                    when const_bias_gyro  => v_source(i) := bias_gyro(i);
                    when const_scale_acc  => v_source(i) := scale_acc(i);
                    when const_bias_acc   => v_source(i) := bias_acc(i);
                        
                    when Beta  => v_source(i) := to_sfixed(c_beta,v_source(i));
                    when Alpha => v_source(i) := to_sfixed(c_alpha,v_source(i));
                    when One   => v_source(i) := to_sfixed(1.0,v_source(i));
                    when Zero  => v_source(i) := to_sfixed(0.0,v_source(i));
                        
                end case;
                
                case current_instruction.instruction is
                    when Multiply      => result_regs(i) <= muladd( A_regs(i),B_regs(i), C_regs(i),C_regs(i));
                    when Move_negative => v_source(i) := comp2(v_source(i));
                    when None =>
                end case;
                
                case current_instruction.destination is

                    when A  => A_regs(i) <= v_source(i);
                    when B  => B_regs(i) <= v_source(i);
                    when C  => C_regs(i) <= v_source(i);

                    when Adjusted_gyro  => Adjusted_gyro_regs(i) <= v_source(i);
                        
                    when Down_vec  => Down_vec_regs(i)  <= v_source(i);
                    when Right_vec => Right_vec_regs(i) <= v_source(i);
                        
                    when ext_out => output_regs(i) <= v_source(i);
                        
                end case;
                
            end loop;
            if rst = '1' then
                Down_vec_regs <= (others => (others => '0'));
            end if;
        end if;
    end process;
    

end architecture;
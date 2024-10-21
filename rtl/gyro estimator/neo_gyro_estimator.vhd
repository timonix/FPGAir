library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.fixed_pkg.all;

entity neo_gyro_estimator is
    generic (
        gyro_scale : real := 1/131*0.0174532925*2**10*0.0005;
        integer_bits : integer := 6;
        fractional_bits : integer := 18
    );
    port (
        clk   : in std_logic;
        rst : in std_logic;
        
        gyro_x : in std_logic_vector(15 downto 0);
        gyro_y : in std_logic_vector(15 downto 0);
        gyro_z : in std_logic_vector(15 downto 0);
        
        gravity_x : in sfixed(integer_bits-1 downto -fractional_bits);
        gravity_y : in sfixed(integer_bits-1 downto -fractional_bits);
        gravity_z : in sfixed(integer_bits-1 downto -fractional_bits);
        
        new_estimate_x : out sfixed(integer_bits-1 downto -fractional_bits);
        new_estimate_y : out sfixed(integer_bits-1 downto -fractional_bits);
        new_estimate_z : out sfixed(integer_bits-1 downto -fractional_bits);
        
        acc_estimate_x : in sfixed(integer_bits-1 downto -fractional_bits);
        acc_estimate_y : in sfixed(integer_bits-1 downto -fractional_bits);
        acc_estimate_z : in sfixed(integer_bits-1 downto -fractional_bits);
        
        start_processing : boolean
        
    );
end entity neo_gyro_estimator;

architecture rtl of neo_gyro_estimator is
    
    signal input_A_X : sfixed(integer_bits-1 downto -fractional_bits);
    signal input_A_Y : sfixed(integer_bits-1 downto -fractional_bits);
    signal input_A_Z : sfixed(integer_bits-1 downto -fractional_bits);
    
    signal input_B_X : sfixed(integer_bits-1 downto -fractional_bits);
    signal input_B_Y : sfixed(integer_bits-1 downto -fractional_bits);
    signal input_B_Z : sfixed(integer_bits-1 downto -fractional_bits);
    
    signal input_C_X : sfixed(integer_bits-1 downto -fractional_bits);
    signal input_C_Y : sfixed(integer_bits-1 downto -fractional_bits);
    signal input_C_Z : sfixed(integer_bits-1 downto -fractional_bits);
    
    signal core_output_x : sfixed(integer_bits-1 downto -fractional_bits);
    signal core_output_y : sfixed(integer_bits-1 downto -fractional_bits);
    signal core_output_z : sfixed(integer_bits-1 downto -fractional_bits);
    
    signal instruction_start_pointer : integer range 0 to 31;
    signal run : boolean;
    signal core_ready : boolean;
    signal core_done : boolean;
    
    signal step : integer range 0 to 31;

begin
    uCore_inst: entity work.uCore
    generic map(
        integer_bits => integer_bits,
        fractional_bits => fractional_bits
    )
    port map(
        clk => clk,
        rst => rst,
        input_A_X => input_A_X,
        input_A_Y => input_A_Y,
        input_A_Z => input_A_Z,
        input_B_X => input_B_X,
        input_B_Y => input_B_Y,
        input_B_Z => input_B_Z,
        input_C_X => input_C_X,
        input_C_Y => input_C_Y,
        input_C_Z => input_C_Z,
        output_X => core_output_x,
        output_Y => core_output_y,
        output_Z => core_output_z,
        instruction_start_pointer => instruction_start_pointer,
        run => run,
        core_ready => core_ready,
        core_done => core_done
    );
    
    process (clk)
    begin
        if rising_edge(clk) then
            if start_processing then
                step <= 1;
                
                
            end if;
            if step = 1 then
                input_A_X <= (others => '0');
                for i in gyro_x'range loop
                    input_A_X(integer_bits-i) <= gyro_x(i);
                end loop;
                input_B_X <= to_sfixed(gyro_scale,input_B_X);
                input_C_X <= to_sfixed(0.0,input_C_X);
                instruction_start_pointer <= 15;
                run <= true;
                step <= 2;
            elsif step = 2 then
                run <= false;
                if core_ready then step <= 3; end if;
            elsif step = 3 then
                input_A_X <= gravity_x;
                input_A_Y <= gravity_y;
                input_A_Z <= gravity_z;
                
                input_B_X <= core_output_x;
                input_B_Y <= core_output_y;
                input_B_Z <= core_output_z;
                run <= true;
                instruction_start_pointer <= 1;
                step <= 4;
            elsif step = 4 then
                run <= false;
                if core_ready then step <= 5; end if;
            elsif step = 5 then
                input_A_X <= to_sfixed(0.95,input_A_X);
                input_A_Y <= to_sfixed(0.95,input_A_Y);
                input_A_Z <= to_sfixed(0.95,input_A_Z);
                input_B_X <= core_output_x;
                input_B_Y <= core_output_y;
                input_B_Z <= core_output_z;
                run <= true;
                instruction_start_pointer <= 21;
                step <= 6;
            elsif step = 6 then
                run <= false;
                if core_ready then step <= 7; end if;
            elsif step = 7 then
                input_A_X <= to_sfixed(0.05,input_A_X);
                input_A_Y <= to_sfixed(0.05,input_A_Y);
                input_A_Z <= to_sfixed(0.05,input_A_Z);
                input_B_X <= acc_estimate_x;
                input_B_Y <= acc_estimate_y;
                input_B_Z <= acc_estimate_z;
                run <= true;
                instruction_start_pointer <= 27;
                step <= 8;
            elsif step = 8 then
                run <= false;
                if core_ready then step <= 9; end if;
            end if;
            
            if rst = '1' then
                step <= 0;
            end if;
        end if;
    end process;


end architecture;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.fixed_pkg.all;


package common_pkg is
    
    constant c_DUMMY : integer := 65536;
    constant c_fixed_point_width : integer := 24;
    
    constant dbus_addr_bits : natural := 24;
    constant dbus_range : natural := 2**dbus_addr_bits-1;
    
    type t_i2c_ctrl is (NOP_E, START, STOP, RW);
    
    type dbus_command is (RD,WR,CLR);
    function to_dbus_command(A : std_logic_vector) return dbus_command;

    type dbus is record
        target_address  : natural range 0 to dbus_range;
        source_address : natural range 0 to dbus_range;
        command  : dbus_command;
        data     : std_logic_vector(7 downto 0);
    end record dbus;
    
    constant C_dbus : dbus := (data => (others => '0'),
        target_address => 0,
        source_address => 0,
        command => RD);
    
    function to_natural(A : std_logic_vector) return natural;
    
    function reverse(A : std_logic_vector) return std_logic_vector;

    function fixed_add (A : in sfixed; B : in sfixed) return sfixed;
    function fixed_sub (A : in sfixed; B : in sfixed) return sfixed;
end package common_pkg;

-- Package Body Section
package body common_pkg is
    function to_dbus_command(A : std_logic_vector) return dbus_command is
        
    begin
        case A is
            when "00" =>
                return RD;
            when "01" =>
                return WR;
            when "10" =>
                return CLR;
            when others =>
                return RD;
                
        end case;
        
    end;
    
    function fixed_add (A : in sfixed; B : in sfixed) return sfixed is
begin
    return resize (
        arg => A + B,
        size_res => A,
        overflow_style => IEEE.fixed_float_types.fixed_wrap,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function to_natural(A : std_logic_vector) return natural is
begin
    return TO_INTEGER(UNSIGNED(A));
    
end;

function reverse(A : std_logic_vector) return std_logic_vector is
    variable inverted_vector : std_logic_vector(A'range);
begin
    for i in A'Right to A'left loop
        inverted_vector(i) := A(A'length+A'low-i);
    end loop;
    
    return inverted_vector;
    
end;

function fixed_sub (A : in sfixed; B : in sfixed) return sfixed is
begin
    return resize (
        arg => A - B,
        size_res => A,
        overflow_style => IEEE.fixed_float_types.fixed_wrap,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;


function Bitwise_AND (
    i_vector : in std_logic_vector(3 downto 0)
)
return std_logic is
begin
    return (i_vector (0) and i_vector (1) and i_vector (2) and i_vector (3));
end;

end package body common_pkg;
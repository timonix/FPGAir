library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.fixed_pkg.all;

package common_pkg is
    
    constant c_DUMMY : integer := 65536;
    constant c_fixed_point_width : integer := 24;
    
    type t_i2c_ctrl is (NOP_E, START, STOP, RW);
    
    type dbus_master_in is record
        ready    : boolean;
    end record dbus_master_in;
    
    type dbus_master_out is record
        address  : std_logic_vector(7 downto 0);
        valid    : boolean;
        data     : std_logic_vector(7 downto 0);
    end record dbus_master_out;

    function fixed_add (A : in sfixed; B : in sfixed) return sfixed;
    function fixed_sub (A : in sfixed; B : in sfixed) return sfixed;
    function fixed_mul_add (A : in sfixed; B : in sfixed; C : in sfixed) return sfixed;
end package common_pkg;

-- Package Body Section
package body common_pkg is
    
    function fixed_add (A : in sfixed; B : in sfixed) return sfixed is
begin
    return resize (
        arg => A + B,
        size_res => A,
        overflow_style => IEEE.fixed_float_types.fixed_wrap,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
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

function fixed_mul_add (A : in sfixed; B : in sfixed; C : in sfixed) return sfixed is
begin
    return resize (
        arg => A * B + C,
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
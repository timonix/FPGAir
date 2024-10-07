library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.fixed_pkg.all;
use IEEE.math_real.all;


package common_pkg is
    
    constant c_DUMMY : integer := 65536;
    constant c_fixed_point_width : integer := 24;
    
    
    
    constant dbus_addr_bits : natural := 16;
    constant dbus_range : natural := 2**dbus_addr_bits-1;
    
    type t_i2c_ctrl is (NOP_E, START, STOP, RW);
    
    function clog2(A : integer) return integer;
    
    type dbus_command is (RD,WR,CLR,INJECT);
    function to_dbus_command(A : std_logic_vector) return dbus_command;
    
    type attitude is record
        roll : sfixed(0 downto -16);
        pitch : sfixed(0 downto -16);
        yaw : sfixed(0 downto -16);
    end record attitude;
    
    type raw_sensor is record
        X : signed(15 downto 0);
        Y : signed(15 downto 0);
        Z : signed(15 downto 0);
    end record raw_sensor;
    

    type dbus is record
        target_address  : natural range 0 to dbus_range;
        source_address : natural range 0 to dbus_range;
        command  : dbus_command;
        data     : std_logic_vector(7 downto 0);
        marked_for_deletion : boolean;
    end record dbus;
    
    constant C_dbus : dbus := (data => (others => '0'),
        target_address => 0,
        source_address => 0,
        command => RD,
        marked_for_deletion => false);
    
    function to_natural(A : std_logic_vector) return natural;
    
    function TO_STDLOGICVECTOR(A : character) return std_logic_Vector;
    function TO_STDLOGICVECTOR_STRING(A : string) return std_logic_Vector;
    
    function reverse(A : std_logic_vector) return std_logic_vector;
    
    function muladd(a : attitude; x:attitude; b: attitude) return attitude;
    
    function addmul(A : in sfixed; B : in sfixed; C : in sfixed; output_size: in sfixed ) return sfixed;
    function muladd(A : in sfixed; B : in sfixed; C : in sfixed; output_size: in sfixed ) return sfixed;
    function muladd(A : in sfixed; B : in real;   C : in sfixed; output_size: in sfixed ) return sfixed;
    function mulsub(A : in sfixed; B : in sfixed; C : in sfixed; output_size: in sfixed ) return sfixed;
    
    function "+" (a : attitude; b: attitude) return attitude;
    
    function "*" (a : real; b: integer) return integer;
    function "*" (a : real; b: integer) return real;

    function fixed_add (A : in sfixed; B : in sfixed) return sfixed;
    function fixed_add (A : in sfixed; B : in sfixed; output_size: in sfixed) return sfixed;
    function fixed_sub (A : in sfixed; B : in sfixed) return sfixed;
    function fixed_sub (A : in sfixed; B : in sfixed; output_size: in sfixed) return sfixed;
    function fixed_mul (A : in sfixed; B : in sfixed) return sfixed;
    function fixed_mul (A : in sfixed; B : in sfixed; output_size: in sfixed) return sfixed;
    function fixed_mul (A : in sfixed; B : in real) return sfixed;
    function fixed_mul (A : in sfixed; B : in real; output_size: in sfixed) return sfixed;
    function cum_mul (A : in sfixed; B : in sfixed; C : in sfixed) return sfixed;
    function map_onto(source : in sfixed; target : in sfixed) return sfixed;
end package common_pkg;

-- Package Body Section
package body common_pkg is
    
    function muladd(a : attitude; x:attitude; b: attitude) return attitude is
    variable res : attitude;
begin
    res.roll := a.roll*x.roll+b.roll;
    res.pitch := a.pitch*x.pitch+b.pitch;
    res.yaw := a.yaw*x.yaw+b.yaw;
    return res;
end function;

function "*" (a : real; b: integer) return integer is
variable res : attitude;
begin
    return integer(real(b)*a);
end function;

function "*" (a : real; b: integer) return real is
variable res : attitude;
begin
    return real(b)*a;
end function;

function "+"(a : attitude; b: attitude) return attitude is
variable res : attitude;
begin
    res.roll := a.roll+b.roll;
    res.pitch := a.pitch+b.pitch;
    res.yaw := a.yaw+b.yaw;
    return res;
end function;

function clog2(A: integer) return integer is
    variable result : integer;
begin
    result := integer(ceil(log2(real(a))));
return result;
end;

function TO_STDLOGICVECTOR_STRING(A: string) return std_logic_Vector is
    variable result : std_logic_vector(A'low*8 to A'high*8+7);
begin
    for i in A'range loop
        result(i*8 to i*8+7) := TO_STDLOGICVECTOR(A(i));
    end loop;
    
    return result;
end;

function TO_STDLOGICVECTOR(A : character) return std_logic_Vector is
begin
    case A is
        when ' ' => return x"20";
        when '!' => return x"21";
        when '"' => return x"22";
        when '#' => return x"23";
        when '$' => return x"24";
        when '%' => return x"25";
        when '&' => return x"26";
        when ''' => return x"27";
        when '(' => return x"28";
                when ')' => return x"29";
        when '*' => return x"2a";
        when '+' => return x"2b";
        when ',' => return x"2c";
        when '-' => return x"2d";
        when '.' => return x"2e";
        when '/' => return x"2f";
        when '0' => return x"30";
        when '1' => return x"31";
        when '2' => return x"32";
        when '3' => return x"33";
        when '4' => return x"34";
        when '5' => return x"35";
        when '6' => return x"36";
        when '7' => return x"37";
        when '8' => return x"38";
        when '9' => return x"39";
        when ':' => return x"3a";
        when ';' => return x"3b";
        when '<' => return x"3c";
        when '=' => return x"3d";
        when '>' => return x"3e";
        when '?' => return x"3f";
        when '@' => return x"40";
        when 'A' => return x"41";
        when 'B' => return x"42";
        when 'C' => return x"43";
        when 'D' => return x"44";
        when 'E' => return x"45";
        when 'F' => return x"46";
        when 'G' => return x"47";
        when 'H' => return x"48";
        when 'I' => return x"49";
        when 'J' => return x"4a";
        when 'K' => return x"4b";
        when 'L' => return x"4c";
        when 'M' => return x"4d";
        when 'N' => return x"4e";
        when 'O' => return x"4f";
        when 'P' => return x"50";
        when 'Q' => return x"51";
        when 'R' => return x"52";
        when 'S' => return x"53";
        when 'T' => return x"54";
        when 'U' => return x"55";
        when 'V' => return x"56";
        when 'W' => return x"57";
        when 'X' => return x"58";
        when 'Y' => return x"59";
        when 'Z' => return x"5a";
        when '[' => return x"5b";
        when '\' => return x"5c";
        when ']' => return x"5d";
        when '^' => return x"5e";
        when '_' => return x"5f";
        when '`' => return x"60";
        when 'a' => return x"61";
        when 'b' => return x"62";
        when 'c' => return x"63";
        when 'd' => return x"64";
        when 'e' => return x"65";
        when 'f' => return x"66";
        when 'g' => return x"67";
        when 'h' => return x"68";
        when 'i' => return x"69";
        when 'j' => return x"6a";
        when 'k' => return x"6b";
        when 'l' => return x"6c";
        when 'm' => return x"6d";
        when 'n' => return x"6e";
        when 'o' => return x"6f";
        when 'p' => return x"70";
        when 'q' => return x"71";
        when 'r' => return x"72";
        when 's' => return x"73";
        when 't' => return x"74";
        when 'u' => return x"75";
        when 'v' => return x"76";
        when 'w' => return x"77";
        when 'x' => return x"78";
        when 'y' => return x"79";
        when 'z' => return x"7a";
        when '{' => return x"7b";
        when '|' => return x"7c";
        when '}' => return x"7d";
        when '~' => return x"7e";
        when CR => return x"0D";
        when LF => return x"0A";
            
        when others => return x"00";
            
    end case;
    
end;


function to_dbus_command(A : std_logic_vector) return dbus_command is
    variable tmp : std_logic_vector(1 downto 0);
begin
    
    tmp := a;
    case tmp is
        when "00" =>
            return RD;
        when "01" =>
            return WR;
        when "10" =>
            return CLR;
        when "11" =>
            return INJECT;
        when others =>
            return RD;
            
    end case;
    
end;

function map_onto(source : in sfixed; target : in sfixed) return sfixed is
variable tmp : sfixed(target'range);
    --variable i : natural range source'range;
begin
    tmp := (others => source(source'high)); -- Initialize tmp with zeros
    tmp(source'low downto target'low) := (others => '0');
    
    for i in source'range loop
        tmp(i) := source(i); -- Copy source to tmp
    end loop;
    return tmp;
end function;


function fixed_add (A : in sfixed; B : in sfixed) return sfixed is
begin
    return resize (
        arg => A + B,
        size_res => A,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function fixed_add (A : in sfixed; B : in sfixed; output_size : in sfixed) return sfixed is
begin
    return resize (
        arg => A + B,
        size_res => output_size,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
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

function fixed_mul (A : in sfixed; B : in sfixed) return sfixed is

begin
    return resize (
        arg => A * B,
        size_res => A,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function fixed_mul (A : in sfixed; B : in sfixed; output_size : in sfixed) return sfixed is

begin
    
    return resize (
        arg => A * B,
        size_res => output_size,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function fixed_mul (A : in sfixed; B : in real) return sfixed is

begin
    return resize (
        arg => A * B,
        size_res => A,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function fixed_mul (A : in sfixed; B : in real; output_size : in sfixed) return sfixed is

begin
    
    return resize (
        arg => A * B,
        size_res => output_size,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function fixed_sub (A : in sfixed; B : in sfixed) return sfixed is
variable result : sfixed(A'high + 1 downto A'low);
begin
    
    return resize (
        arg => A - B,
        size_res => A,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function fixed_sub (A : in sfixed; B : in sfixed; output_size : in sfixed) return sfixed is
variable result : sfixed(A'high + 1 downto A'low);
begin
    
    return resize (
        arg => A - B,
        size_res => output_size,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function addmul (A : in sfixed; B : in sfixed; C : in sfixed; output_size: in sfixed ) return sfixed is
begin
    return resize (
        arg => (A + B) * C,
        size_res => output_size,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function muladd (A : in sfixed; B : in sfixed; C : in sfixed; output_size: in sfixed ) return sfixed is
begin
    return resize (
        arg => (A * B) + C,
        size_res => output_size,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function muladd (A : in sfixed; B : in real; C : in sfixed; output_size: in sfixed ) return sfixed is
begin
    return resize (
        arg => (A * B) + C,
        size_res => output_size,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function mulsub (A : in sfixed; B : in sfixed; C : in sfixed; output_size: in sfixed ) return sfixed is
begin
    return resize (
        arg => (A * B) - C,
        size_res => output_size,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
        round_style => IEEE.fixed_float_types.fixed_truncate
    );
end;

function cum_mul (A : in sfixed; B : in sfixed; C : in sfixed) return sfixed is
begin
    return resize (
        arg => A * B + C,
        size_res => C,
        overflow_style => IEEE.fixed_float_types.fixed_saturate,
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
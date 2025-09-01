library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.fixed_pkg.all;
use IEEE.math_real.all;

library std;
use std.textio.all;

package common_pkg is
    type integer_array is array (natural range<>) of integer;
    
    function TO_STDLOGICVECTOR(A : character) return std_logic_Vector;
    function TO_STDLOGICVECTOR_STRING(A : string) return std_logic_Vector;
    
end package;

package body common_pkg is
   
    
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
end package body;
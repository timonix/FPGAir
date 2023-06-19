library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package fixed_point_pkg is
    

    type fixed is array (integer range <>) of std_ulogic;
    
    function "NOT" (a : fixed) return fixed;
    function "+" (a : fixed; b : fixed) return fixed;
    function "-" (a : fixed; b : fixed) return fixed;
    function "*" (a : fixed; b : fixed) return fixed;
    
                        --function "+" (a: fixed; b: signed) return fixed;
                        --function "-" (a: fixed; b: signed) return fixed;
                        --function "*" (a: fixed; b: signed) return fixed;
    
                        --function "+" (a: fixed; b: unsigned) return fixed;
                        --function "-" (a: fixed; b: unsigned) return fixed;
                        --function "*" (a: fixed; b: unsigned) return fixed;
    
                        --function "+" (a: fixed; b: integer) return fixed;
                        --function "-" (a: fixed; b: integer) return fixed;
                        --function "*" (a: fixed; b: integer) return fixed;
    
                        --function shl (a: fixed; count: natural) return fixed;
                        --function shr (a: fixed; count: natural) return fixed;
    
    function to_fixed (value : real; int_bits : natural; fractional_bits : natural) return fixed;
                            --function to_fixed (value : signed; int_bits : natural; fractional_bits : natural) return fixed;
                            --function to_fixed (value : unsigned; int_bits : natural; fractional_bits : natural) return fixed;
                            --function to_fixed (value : integer; int_bits : natural; fractional_bits : natural) return fixed;
    
                            --function from_bits (bits : signed; int_bits : natural; fractional_bits : natural) return fixed;
                            --function from_bits (bits : unsigned; int_bits : natural; fractional_bits : natural) return fixed;
                            --function from_bits (bits : std_logic_vector; int_bits : natural; fractional_bits : natural) return fixed;
    
    function from_bits (bits : signed; int_bits : natural; fractional_bits : integer) return fixed;
    function from_bits (bits : fixed) return signed;
    
    function resize (a : fixed; int_bits : natural; fractional_bits : integer) return fixed;
    function to_string (a : fixed) return string;
    
end package fixed_point_pkg;

package body fixed_point_pkg is
    
    function to_fixed (value : integer; int_bits : natural; fractional_bits : natural) return fixed is
        variable res : fixed (int_bits - 1 downto - fractional_bits);
    begin
        return from_bits(to_signed(value, int_bits + fractional_bits), int_bits, fractional_bits);
        
    end function to_fixed;

    function to_fixed (value : real; int_bits : natural; fractional_bits : natural) return fixed is
        variable res : fixed (int_bits - 1 downto - fractional_bits);
    begin
        return to_fixed(integer(value * 2.0 ** (fractional_bits)), int_bits, fractional_bits);
        
    end function to_fixed;

    function to_string (a : fixed) return string is
        variable res : string (0 to a'LENGTH - 1);
    begin
        for i in res'range loop
            res(res'HIGH - i) := std_logic'image(a(a'LOW + i))(2); -- extract the character representation of the std_logic
        end loop; return res;
    end function to_string;

    function resize (a : fixed; int_bits : natural; fractional_bits : integer) return fixed is
        variable res : fixed(int_bits downto - abs(fractional_bits));
    begin
        res := (others => '0');
        res(res'HIGH downto a'high) := (others => a(a'high)); --sign extend
        
        if a'HIGH >= res'HIGH and a'LOW <= res'LOW then --both shrink
            res := a(res'HIGH downto res'low);
        elsif a'HIGH <= res'HIGH and a'LOW <= res'LOW then -- frac shrink, int grows
            res(a'HIGH downto 0) := a(a'HIGH downto 0);
            res(0 downto res'low) := a(0 downto res'low);
        elsif a'HIGH >= res'HIGH and a'LOW >= res'LOW then -- frac grows, int shrink
            res(res'HIGH downto 0) := a(res'HIGH downto 0);
            res(0 downto a'low) := a(0 downto a'low);
        elsif a'HIGH <= res'HIGH and a'LOW >= res'LOW then --both grow
            res(a'range) := a;
        end if; return res;

    end function resize;

    function from_bits (bits : signed; int_bits : natural; fractional_bits : integer) return fixed is
        variable res : fixed(int_bits - 1 downto - abs(fractional_bits));
    begin
        for I in bits'LOW to bits'HIGH loop
            res(I + res'low) := bits(I);
        end loop; return res;

    end function from_bits;

    function from_bits (bits : fixed) return signed is
        variable res : signed(bits'LENGTH - 1 downto 0);
    begin
        for I in res'LOW to res'HIGH loop
            res(I) := bits(I + bits'low);
        end loop; return res;
        
    end function from_bits;

    function "NOT" (a : fixed) return fixed is
        variable res : fixed(a'HIGH downto a'low);
    begin
        for I in res'LOW to res'HIGH loop
            res(I) := not a(I);
        end loop; return res;
        
    end function "NOT";

    function "+" (a : fixed; b : fixed) return fixed is
        variable res : fixed(maximum(a'high, b'high) downto minimum(a'low, b'low));
        variable CBIT : STD_LOGIC := '0';
        variable L : fixed(res'HIGH downto res'low) := resize(a, res'high, res'low);
        variable R : fixed(res'HIGH downto res'low) := resize(b, res'high, res'low);
    begin
        for I in res'LOW to res'HIGH loop
            res(I) := CBIT xor L(I) xor R(I);
            CBIT := (CBIT and L(I)) or (CBIT and R(I)) or (L(I) and R(I));
        end loop; return res;
        
    end function "+";

    function "-" (a : fixed; b : fixed) return fixed is
        variable res : fixed(maximum(a'high, b'high) downto minimum(a'low, b'low));
        variable CBIT : STD_LOGIC := '1';
        variable L : fixed(res'HIGH downto res'low) := resize(a, res'high, res'low);
        variable R : fixed(res'HIGH downto res'low) := not resize(b, res'high, res'low);
    begin
        for I in res'LOW to res'HIGH loop
            res(I) := CBIT xor L(I) xor R(I);
            CBIT := (CBIT and L(I)) or (CBIT and R(I)) or (L(I) and R(I));
        end loop; return res;
        
    end function "-";

    function "*" (a : fixed; b : fixed) return fixed is

        variable L : signed(a'LENGTH - 1 downto 0) := from_bits(a);
        variable R : signed(b'LENGTH - 1 downto 0) := from_bits(b);
        variable LR : signed(a'LENGTH + b'LENGTH - 1 downto 0) := L * R;
        variable res : fixed(a'HIGH + b'HIGH + 1 downto a'LOW + b'low);
    begin
        res := from_bits(LR, res'HIGH + 1, res'low); return res;
        
    end function "*";

end package body fixed_point_pkg;
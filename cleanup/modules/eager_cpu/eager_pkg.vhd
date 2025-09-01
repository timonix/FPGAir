library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.textio.all;

package eager_pkg is
    constant C_EAGER_ROM_WIDTH : positive := 8;
    constant C_EAGER_DATA_WIDTH   : integer := 32;
    type EAGER_ROM_T is array (natural range<>) of std_logic_vector(C_EAGER_ROM_WIDTH-1 downto 0);
    type EAGER_RAM_T is array (natural range<>) of std_logic_vector(C_EAGER_DATA_WIDTH-1 downto 0);
    
    
    impure function read_eager_rom(
        file_name : string;
        depth     : positive
    ) return EAGER_ROM_T;
    
    impure function read_eager_ram(
        file_name : string;
        depth     : positive
    ) return EAGER_RAM_T;
    
    constant C_B_OP   : std_logic_vector := "0001";
    constant C_A_OP   : std_logic_vector := "00100";
    constant C_X_OP   : std_logic_vector := "00101";
    constant C_RAM_OP : std_logic_vector := "00110";
    
    constant C_OP_HALT    : std_logic_Vector := x"00"; --    00000000 # HALT
    constant C_OP_NOP     : std_logic_Vector := x"01"; --    00000001 # NOP
    constant C_OP_MULADD  : std_logic_Vector := x"02"; --    00000010 # MULADD
    
    
end package;

package body eager_pkg is

  -- helper: bit_vector -> std_logic_vector
    procedure bv_to_slv(
        bv  : in  bit_vector;
        slv : out std_logic_vector
    ) is
    begin
    -- assume same length; copy 0/1
        for i in slv'range loop
            if bv(i) = '1' then
                slv(i) := '1';
            else
                slv(i) := '0';
            end if;
        end loop;
    end procedure;
    
    impure function read_eager_ram(
        file_name : string;
        depth     : positive
    ) return EAGER_RAM_T is
        file     f        : text;
        variable status   : file_open_status;
        variable line_buf : line;
        variable bv       : bit_vector(C_EAGER_DATA_WIDTH-1 downto 0);
        variable slv      : std_logic_vector(C_EAGER_DATA_WIDTH-1 downto 0);
        variable result   : EAGER_RAM_T(0 to depth-1);
        variable good     : boolean;
    begin
        file_open(status, f, file_name, read_mode);
        if status /= open_ok then
            for i in 0 to depth-1 loop
                result(i) := (others => '0');
            end loop;
            return result;
        end if;

        for i in 0 to depth-1 loop
            if endfile(f) then
                result(i) := (others => '0');
            else
                readline(f, line_buf);
        -- READ into bit_vector (this overload exists in std.textio)
                read(line_buf, bv, good);
                if good then
                    bv_to_slv(bv, slv);
                    result(i) := slv;
                else
                    result(i) := (others => '0');
                end if;
            end if;
        end loop;

        file_close(f);
        return result;
    end function;

    impure function read_eager_rom(
        file_name : string;
        depth     : positive
    ) return EAGER_ROM_T is
        file     f        : text;
        variable status   : file_open_status;
        variable line_buf : line;
        variable bv       : bit_vector(C_EAGER_ROM_WIDTH-1 downto 0);
        variable slv      : std_logic_vector(C_EAGER_ROM_WIDTH-1 downto 0);
        variable result   : EAGER_ROM_T(0 to depth-1);
        variable good     : boolean;
    begin
        file_open(status, f, file_name, read_mode);
        if status /= open_ok then
            for i in 0 to depth-1 loop
                result(i) := (others => '0');
            end loop;
            return result;
        end if;

        for i in 0 to depth-1 loop
            if endfile(f) then
                result(i) := (others => '0');
            else
                readline(f, line_buf);
                read(line_buf, bv, good);  -- read as bit_vector
                if good then
                    bv_to_slv(bv, slv);
                    result(i) := slv;
                else
                    result(i) := (others => '0');
                end if;
            end if;
        end loop;

        file_close(f);
        return result;
    end function;
end package body;
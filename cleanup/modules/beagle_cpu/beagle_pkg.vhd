library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
use std.textio.all;

package beagle_pkg is
    constant C_BEAGLE_ROM_WIDTH  : positive := 8;
    constant C_BEAGLE_DATA_WIDTH : integer := 32;
    constant C_FRACTIONAL_WIDTH  : integer := 20;
    constant C_INTEGER_WIDTH     : integer := C_BEAGLE_DATA_WIDTH-C_FRACTIONAL_WIDTH;
    
    type EAGER_ROM_T is array (natural range<>) of std_logic_vector(C_BEAGLE_ROM_WIDTH-1 downto 0);
    type EAGER_RAM_T is array (natural range<>) of std_logic_vector(C_BEAGLE_DATA_WIDTH-1 downto 0);
    
    
    impure function read_eager_rom(
        file_name : string;
        depth     : positive
    ) return EAGER_ROM_T;
    
    impure function read_eager_ram(
        file_name : string;
        depth     : positive
    ) return EAGER_RAM_T;
    
    
    constant C_OP_HALT    : std_logic_Vector := x"00"; --    00000000 # HALT
    constant C_OP_NOP     : std_logic_Vector := x"01"; --    00000001 # NOP
    constant C_OP_MULADD  : std_logic_Vector := x"02"; --    00000010 # MULADD
    constant C_OP_MOV     : std_logic_vector := "001"; --    001SSSDD # MOV
                                                       --    1AAAAAAA # LDADDR
    constant C_OP_NEG_A   : std_logic_Vector := x"03";
    constant C_OP_NEG_B   : std_logic_Vector := x"04";

    constant C_SRC_A    : std_logic_vector := "001";
    constant C_SRC_B    : std_logic_vector := "010";
    constant C_SRC_X    : std_logic_vector := "011";
    constant C_SRC_RAM  : std_logic_vector := "100";
    constant C_SRC_RES  : std_logic_vector := "101";
    constant C_SRC_ZERO : std_logic_vector := "110";
    constant C_SRC_ONE  : std_logic_vector := "111";
    
    constant C_DST_A    : std_logic_vector := "00";
    constant C_DST_B    : std_logic_vector := "01";
    constant C_DST_X    : std_logic_vector := "10";
    constant C_DST_RAM  : std_logic_vector := "11";
    
    constant REG_GYRO_X  : unsigned(6 downto 0) := "1000000";
    constant REG_GYRO_Y  : unsigned(6 downto 0) := "1000001";
    constant REG_GYRO_Z  : unsigned(6 downto 0) := "1000010";
    constant REG_ACC_X   : unsigned(6 downto 0) := "1000011";
    constant REG_ACC_Y   : unsigned(6 downto 0) := "1000100";
    constant REG_ACC_Z   : unsigned(6 downto 0) := "1000101";
    constant REG_TEMP    : unsigned(6 downto 0) := "1000110";
    
    constant REG_UART_TX : unsigned(6 downto 0) := "1111111";
    constant REG_UART_RX : unsigned(6 downto 0) := "1111110";
    
end package;

package body beagle_pkg is

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
        variable bv       : bit_vector(C_BEAGLE_DATA_WIDTH-1 downto 0);
        variable slv      : std_logic_vector(C_BEAGLE_DATA_WIDTH-1 downto 0);
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
        variable bv       : bit_vector(C_BEAGLE_ROM_WIDTH-1 downto 0);
        variable slv      : std_logic_vector(C_BEAGLE_ROM_WIDTH-1 downto 0);
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
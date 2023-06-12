library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package common_pkg is
    
    constant c_DUMMY : integer := 65536;
    
    type t_i2c_ctrl is (NOP_E, START, STOP, RW);
    
    --constant c_i2c_ctrl_nop        : std_logic_vector := "00";
    --constant c_i2c_ctrl_send_start : std_logic_vector := "01";
    --constant c_i2c_ctrl_send_stop  : std_logic_vector := "10";
    --constant c_i2c_ctrl_rw         : std_logic_vector := "11";
    
    
end package common_pkg;

-- Package Body Section
package body common_pkg is
    
    function Bitwise_AND (
        i_vector : in std_logic_vector(3 downto 0)
    )
    return std_logic is
    begin
        return (i_vector (0) and i_vector (1) and i_vector (2) and i_vector (3));
    end;
    
end package body common_pkg;
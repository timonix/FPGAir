library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.beagle_pkg.all;

entity beagle_bus is
    port (
        clk   : in std_logic;
        reset : in std_logic;
        
        beagle_addr          : in unsigned(6 downto 0);

        beagle_data_in_valid : out boolean;
        beagle_data_in  : out std_logic_vector(C_BEAGLE_DATA_WIDTH-1 downto 0);
        beagle_data_out : in  std_logic_vector(C_BEAGLE_DATA_WIDTH-1 downto 0);
        beagle_write    : in  boolean;
        
        gyro_x      : in std_logic_vector(15 downto 0);
        gyro_y      : in std_logic_vector(15 downto 0);
        gyro_z      : in std_logic_vector(15 downto 0);
        
        acc_x      : in std_logic_vector(15 downto 0);
        acc_y      : in std_logic_vector(15 downto 0);
        acc_z      : in std_logic_vector(15 downto 0);
        
        temperature : in std_logic_vector(15 downto 0);
        
        debug_tx    : out std_logic_vector(31 downto 0);
        debug_rx    : in std_logic_vector(31 downto 0);
        debug_valid : out boolean
        
    );
end entity beagle_bus;

architecture rtl of beagle_bus is
    function pack16(v : std_logic_vector(15 downto 0)) return std_logic_vector is
        variable r : std_logic_vector(31 downto 0);
    begin
        r(31 downto 24) := (others => v(15));  -- sign bit
        r(23 downto 8)  := v;
        r(7 downto 0)   := (others => '0');
        return r;
    end function;
begin

    
    process (clk)
    begin
        if rising_edge(clk) then
            beagle_data_in_valid <= beagle_addr(beagle_addr'high) = '1';
            
            if beagle_addr = REG_UART_RX then beagle_data_in <= debug_rx; end if;
            if beagle_addr = REG_GYRO_X  then beagle_data_in <= pack16(gyro_x); end if;
            if beagle_addr = REG_GYRO_Y  then beagle_data_in <= pack16(gyro_y); end if;
            if beagle_addr = REG_GYRO_Z  then beagle_data_in <= pack16(gyro_z); end if;
            if beagle_addr = REG_ACC_X   then beagle_data_in <= pack16(acc_x); end if;
            if beagle_addr = REG_ACC_Y   then beagle_data_in <= pack16(acc_y); end if;
            if beagle_addr = REG_ACC_Z   then beagle_data_in <= pack16(acc_z); end if;
            if beagle_addr = REG_TEMP    then beagle_data_in <= pack16(temperature); end if;
            
            debug_valid <= false;
            if beagle_addr = REG_UART_TX and beagle_write then debug_tx <= beagle_data_out; debug_valid <= true; end if;
            
        end if;
    end process;

end architecture;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.common_pkg.ALL;

entity sim_mpu6050 is
    Port (
        rst : in std_logic;
        scl : inout STD_LOGIC;
        sda : inout STD_LOGIC
    );
end sim_mpu6050;

architecture sim of sim_mpu6050 is
    -- I2C
    type i2c_state_type is (WAITING_FOR_START, ADDRESS, ADDRESS_ACK,RELEASE_ADDRESS_ACK, WRITE_CURRENT_ADDRESS, STOP);
    signal i2c_state : i2c_state_type := WAITING_FOR_START;
    signal i2c_addr : std_logic_vector(6 downto 0) := "1101000"; -- Device address (0x68)
    signal i2c_rw : std_logic := '0';
    signal i2c_reg_addr : std_logic_vector(7 downto 0) := (others => '0');
    signal i2c_data_out : std_logic_vector(7 downto 0) := (others => '0');
    signal i2c_bit_count : integer range 0 to 8 := 0;
    
    signal DEBUG : std_logic_vector(0 to 31) := To_StdLogicVector_String("1111");
    
    signal address_correct : boolean := false;
    signal current_register : unsigned(7 downto 0) := (others => '0');
    signal read_command : boolean := false;
    
    
    
    signal current_data : std_logic_vector(7 downto 0) := (others => '0');

    type sensor_data_type is array (0 to 255) of std_logic_vector(7 downto 0);
    signal sensor_registers : sensor_data_type := (others => (others => '0'));
    
    function all_values_valid(input_vector : std_logic_vector) return boolean is
    begin
        for i in input_vector'range loop
            if (input_vector(i) /= '0' and input_vector(i) /= '1') then
                return false;
            end if;
        end loop;
        return true;
    end function all_values_valid;
    
    function is_high(i : std_logic) return boolean is
    begin

        if (i = 'H') or (i='1') then
            return true;
        end if;
        return false;
    end function is_high;
    
    function resolve(i : std_logic) return std_logic is
    begin
        if is_high(i) then
            return '1';
        end if;
        return '0';
    end function resolve;
    
begin
    
    process(scl,sda,rst)
    
    begin
        if rst = '1' then
            sda <= 'H';
            scl <= 'H';
        end if;
        if falling_edge(sda) and is_high(scl) then
            DEBUG <= To_StdLogicVector_String("STAR");
            i2c_state <= ADDRESS;
            current_data <= (others => 'U');
        end if;
        
        if rising_edge(sda) and is_high(scl) then
            DEBUG <= To_StdLogicVector_String("STOP");
            i2c_state <= WAITING_FOR_START;
            address_correct <= false;
        end if;
        
        if rising_edge(scl) and i2c_state = ADDRESS then
            DEBUG <= To_StdLogicVector_String("ADDR");
            current_data(0) <= resolve(sda);
            current_data(7 downto 1) <= current_data(6 downto 0);
            if all_values_valid(current_data(6 downto 0)&resolve(sda)) then
                i2c_state <= ADDRESS_ACK;
            end if;
        end if;
        
        if falling_edge(scl) and i2c_state = ADDRESS_ACK then
            DEBUG <= To_StdLogicVector_String("W AD");
            address_correct <= false;
            if current_data(7 downto 1) = i2c_addr then
                sda <= '0';
                DEBUG <= To_StdLogicVector_String("C AD");
                address_correct <= true;
                read_command <= is_high(current_data(0));
            end if;
            
            i2c_state <= RELEASE_ADDRESS_ACK;
        end if;
        
        if falling_edge(scl) and i2c_state = RELEASE_ADDRESS_ACK then
            DEBUG <= To_StdLogicVector_String("REL ");
            sda <= 'H';
            if read_command then
                
            else
                i2c_state <= WRITE_CURRENT_ADDRESS;
                current_register <= (others => 'U');
            end if;
        end if;
        
        if falling_edge(scl) and i2c_state = WRITE_CURRENT_ADDRESS then
            DEBUG <= To_StdLogicVector_String("N  P");
            current_register(0) <= resolve(sda);
            current_register(7 downto 1) <= current_register(6 downto 0);
            if all_values_valid(std_logic_vector(current_register(6 downto 0))&resolve(sda)) then
                i2c_state <= STOP;
            end if;
        end if;

        
    end process;
    

end architecture sim;
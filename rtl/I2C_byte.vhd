library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity I2C_byte is
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.4;
        simulation : boolean := false
    );
    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        sda         : inout STD_LOGIC;
        scl         : inout STD_LOGIC;
        
        o_working : out std_logic;
        
        i_ctrl : in  std_logic_vector(1 downto 0);
        i_ack  : in  std_logic;
        i_data : in  std_logic_vector(7 downto 0);
        
        o_ack  : out std_logic;
        o_data : out std_logic_vector(7 downto 0)
    );
end entity I2C_byte;

architecture rtl of I2C_byte is
    
    
    procedure SET_SDA(constant value : in STD_LOGIC) is
    begin
        if value = '1' then
            sda <= 'Z';
        else
            sda <= '0';
        end if;
        
        if simulation then
            sda <= value;
        end if;
    end procedure SDA_ON;
    
    procedure SET_SCL(constant value : in STD_LOGIC) is
    begin
        if value = '1' then
            scl <= 'Z';
        else
            scl <= '0';
        end if;
        
        if simulation then
            scl <= value;
        end if;
    end procedure SDA_ON;
    
    
    
    constant c_ctrl_nop        : std_logic_vector := "00";
    constant c_ctrl_send_start : std_logic_vector := "01";
    constant c_ctrl_send_stop  : std_logic_vector := "10";
    constant c_ctrl_rw         : std_logic_vector := "11";
    
    signal s_latched_command   : std_logic_vector(1 downto 0);
    signal s_latched_data      : std_logic_vector(7 downto 0);
    signal s_latched_ack       : std_logic;
    
    constant clock_divisor : positive := positive(frequency_mhz / (4.0 * i2c_frequency_mhz));
    signal clock_divider_counter : natural range 0 to clock_divisor + 1 := 0;
    signal i2c_clock : STD_LOGIC := '0';
    
    signal s_stage : integer range 0 to 10;
    signal s_bit_id : integer range 0 to 7;

begin
    
    i2c_clock_proc: process(clk)
    begin
        if rising_edge(clk) then
            clock_divider_counter <= clock_divider_counter+1;
            i2c_clock <= '0';
            if clock_divider_counter = clock_divisor then
                clock_divider_counter <= 0;
                i2c_clock <= '1';
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            
            if s_latched_command <= c_ctrl_nop then
                s_stage <= 0;
            end if;
            
            if s_latched_command = c_ctrl_send_start then
                o_working <= '1';
                if s_stage = 1 and i2c_clock = 1 then
                    s_stage <= 2;
                elsif s_stage = 2 and i2c_clock = 1 then
                    SET_SDA('1');
                    s_stage <= 3;
                elsif s_stage = 3 and i2c_clock = 1 then
                    SET_SCL('1');
                    s_stage <= 4;
                elsif s_stage = 4 and i2c_clock = 1 then
                    SET_SDA('0');
                    s_stage <= 5;
                elsif s_stage = 5 and i2c_clock = 1 then
                    SET_SCL('0');
                    s_stage <= 6;
                elsif s_stage = 6 and i2c_clock = 1 then
                    s_stage <= 0;
                end if;
            end if;
            
            if s_latched_command = c_ctrl_send_stop then
                o_working <= '1';
                if s_stage = 1 and i2c_clock = 1 then
                    s_stage <= 2;
                elsif s_stage = 2 and i2c_clock = 1 then
                    SET_SCL('0');
                    s_stage <= 3;
                elsif s_stage = 3 and i2c_clock = 1 then
                    SET_SCL('1');
                    s_stage <= 4;
                elsif s_stage = 4 and i2c_clock = 1 then
                    SET_SDA('1');
                    s_stage <= 5;
                elsif s_stage = 5 and i2c_clock = 1 then
                    s_stage <= 0;
                end if;
            end if;
            
--            bool Tx(uint8_t dat){
--
--            for(uint8_t i = 8; i; i--){
--                (dat & 0x80) ? SDA_ON : SDA_OFF; //Mask for the eigth bit
--                dat<<=1;  //Move
--                dly();
--                SCL_ON;
--                dly();
--                SCL_OFF;
--                dly();
--            }
--                SDA_ON;
--                SCL_ON;
--                dly();
--                bool ack = !SDA_READ;    // Acknowledge bit
--                SCL_OFF;
--                return ack;
--            }
            
            if s_latched_command = c_ctrl_rw then
                o_working <= '1';
                if s_stage = 1 and i2c_clock = 1 then
                    s_bit_id <= 7;
                    SET_SDA(s_latched_data(7));
                    s_latched_data(7 downto 1) <= s_latched_data(6 downto 0);
                    s_latched_data(0) <= sda;
                    s_stage <= s_stage + 1;
                elsif s_stage = 2 and i2c_clock = 1 then
                    SET_SCL('1');
                    s_stage <= s_stage + 1;
                elsif s_stage = 3 and i2c_clock = 1 then
                    SET_SCL('0');
                    
                    if s_bit_id = 0 then
                        s_stage <= 4;
                    else
                        s_bit_id <= s_bit_id -1;
                        s_stage <= 1;
                    end if;
                elsif s_stage = 4 and i2c_clock = 1 then
                    
                    
                elsif s_stage = 5 and i2c_clock = 1 then
                    s_stage <= 0;
                end if;
            end if;
            
            if s_stage = 0 then
                s_latched_command <= i_ctrl;
                s_latched_data <= i_data;
                s_latched_ack <= i_ack;
                s_stage <= 1;
            end if;
            
            if rst = '1' then
                s_latched_command <= c_ctrl_nop;
                s_stage <= 0;
                o_working <= '0';
            end if;
        end if;
    end process;


end architecture rtl;
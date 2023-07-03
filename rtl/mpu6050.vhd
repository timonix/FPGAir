library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

entity mpu6050 is
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.4;
        simulation : boolean := true
    );
    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        sda         : inout STD_LOGIC;
        scl         : inout STD_LOGIC;
       
        
        gyro_x      : out std_logic_vector(15 downto 0);
        gyro_y      : out std_logic_vector(15 downto 0);
        gyro_z      : out std_logic_vector(15 downto 0);
        
        acc_x      : out std_logic_vector(15 downto 0);
        acc_y      : out std_logic_vector(15 downto 0);
        acc_z      : out std_logic_vector(15 downto 0);
        
        temperature : out std_logic_vector(15 downto 0);

        o_working : out boolean;
        i_update : in boolean
        
    );
end entity mpu6050;

architecture rtl of mpu6050 is
    

    constant MPU_ADDRESS_WRITE : std_logic_vector(7 downto 0) := x"68";
    constant MPU_ADDRESS_READ : std_logic_vector(7 downto 0) := x"69";
    constant clock_divisor : positive := positive(frequency_mhz / (4.0 * i2c_frequency_mhz));
    signal clock_divider_counter : natural range 0 to clock_divisor + 1 := 0;
    signal i2c_clock : STD_LOGIC := '0';

    signal s_stage : natural range 0 to 1023;
    

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
    procedure OPEN_DRAIN_SDA(constant value : in STD_LOGIC) is
    begin
        if value = '1' then
            sda <= 'Z';
        else
            sda <= '0';
        end if;
        
        if simulation then
            sda <= value;
        end if;
    end procedure OPEN_DRAIN_SDA;
    
    procedure OPEN_DRAIN_SCL(constant value : in STD_LOGIC) is
    begin
        if value = '1' then
            scl <= 'Z';
        else
            scl <= '0';
        end if;
        
        if simulation then
            scl <= value;
        end if;
    end procedure OPEN_DRAIN_SCL;
    
    procedure SEND_START(
        constant reference : in natural;
        constant end_point : in natural
        
    ) is
    begin
        assert end_point = reference + 3;
        if s_stage = reference then
            OPEN_DRAIN_SDA('1');
        elsif s_stage = reference + 1 then
            OPEN_DRAIN_SCL('1');
        elsif s_stage = reference + 2 then
            OPEN_DRAIN_SDA('0');
        elsif s_stage = reference + 3 then
            OPEN_DRAIN_SCL('0');
        end if;
        
    end procedure SEND_START;
    
    procedure SEND_STOP(
        constant reference : in natural;
        constant end_point : in natural
        
    ) is
    begin
        assert end_point = reference + 3;
        if s_stage = reference then
            OPEN_DRAIN_SCL('0');
        elsif s_stage = reference + 1 then
            OPEN_DRAIN_SCL('1');
        elsif s_stage = reference + 2 then
            OPEN_DRAIN_SDA('1');
        elsif s_stage = reference + 3 then

        end if;
        
    end procedure SEND_STOP;
    
    procedure SEND_RESTART(
        constant reference : in natural;
        constant end_point : in natural
        
    ) is
    begin
        assert end_point = reference + 3 report
               "The value of 'end_point' is " & integer'image(end_point) &
               "The value of 'reference' is " & integer'image(reference + 3);
        if s_stage = reference then
            OPEN_DRAIN_SCL('0');
        elsif s_stage = reference + 1 then
            OPEN_DRAIN_SCL('1');
        elsif s_stage = reference + 2 then
            OPEN_DRAIN_SDA('0');
        elsif s_stage = reference + 3 then
            OPEN_DRAIN_SCL('0');
        end if;
        
    end procedure SEND_RESTART;


    procedure SEND_BIT(constant reference : in natural;
        constant end_point : in natural;
        constant data : std_logic) is
    begin
        assert end_point = reference + 3 report
               "The value of 'end_point' is " & integer'image(end_point) &
               "The value of 'reference' is " & integer'image(reference + 3);
        
        if s_stage = reference then
            OPEN_DRAIN_SDA(data);
        elsif s_stage = reference + 1 then
            OPEN_DRAIN_SCL('1');
        elsif s_stage = reference + 2 then
            OPEN_DRAIN_SCL('1');
        elsif s_stage = reference + 3 then
            OPEN_DRAIN_SCL('0');
        end if;
    end procedure;

    procedure SEND_BYTE(
        constant reference : in natural;
        constant end_point : in natural;
        constant data : std_logic_vector
        
    ) is
        variable data_with_ack : std_logic_vector(8 downto 0) := data & '1';
    begin
        assert end_point = reference + 8*4+ 3
        report "The value of 'end_point' is " & integer'image(end_point) &
               "The value of 'reference' is " & integer'image(reference + 8*4+ 3);
        for b in 0 to 8 loop
            SEND_BIT(reference + b*4, reference + b*4 + 3, data_with_ack(8-b));
        end loop;
    end procedure SEND_BYTE;
    
    
    procedure READ_BYTE(
        constant reference : in natural;
        constant end_point : in natural;
        signal data : out std_logic_vector;
        constant ack : in std_logic
        
    ) is

    begin
        assert end_point = reference + 8*4+ 3
        report "The value of 'end_point' is " & integer'image(end_point) &
               "The value of 'reference' is " & integer'image(reference + 8*4+ 3);
        
        for b in 0 to 8 loop
            if s_stage = reference + b*4 then
                if b = 8 then
                    OPEN_DRAIN_SDA(ack);
                else
                    OPEN_DRAIN_SDA('1');
                end if;
            elsif s_stage = reference + b*4 + 1 then
                if not (b = 8) then
                    data(data'left-b) <= sda;
                end if;
                OPEN_DRAIN_SCL('1');
            elsif s_stage = reference + b*4 + 2 then
                OPEN_DRAIN_SCL('1');
            elsif s_stage = reference + b*4 + 3 then
                OPEN_DRAIN_SCL('0');
            end if;
        end loop;

        
        
    end procedure READ_BYTE;

    begin
        if rising_edge(clk) and i2c_clock = '1' then
            
            SEND_START(1 ,4);
            SEND_BYTE(5, 40,MPU_ADDRESS_WRITE); -- send address
            SEND_BYTE(41, 76,X"6B");
            SEND_BYTE(77, 112,X"00"); -- reset device
            
            
            SEND_RESTART(113,116);
            SEND_BYTE(117,152,MPU_ADDRESS_WRITE);
            SEND_BYTE(153,188,X"1B"); -- CONFIG
            SEND_BYTE(189,224,X"10"); -- 00010000 (+/- 8g full scale range)
            SEND_BYTE(225,260,X"10"); -- 00010000 (1000deg/s full scale)
            
            SEND_STOP(261,264);
            
            SEND_START(264,267);
            SEND_BYTE(268,303,MPU_ADDRESS_WRITE);
            SEND_BYTE(304,339,X"43"); --
            
            SEND_RESTART(340,343);
            SEND_BYTE(344,379,MPU_ADDRESS_READ);
            READ_BYTE(380,415,acc_x(15 downto 8),'0');
            READ_BYTE(416,451,acc_x(7 downto 0),'0');
            READ_BYTE(452,487,acc_y(15 downto 8),'0');
            READ_BYTE(488,523,acc_y(7 downto 0),'0');
            READ_BYTE(524,559,acc_z(15 downto 8),'0');
            READ_BYTE(560,595,acc_z(7 downto 0),'0');
            
            READ_BYTE(596,631,temperature(15 downto 8),'0');
            READ_BYTE(632,667,temperature(7 downto 0),'0');
            
            READ_BYTE(668,703,gyro_x(15 downto 8),'0');
            READ_BYTE(704,739,gyro_x(7 downto 0),'0');
            READ_BYTE(740,775,gyro_y(15 downto 8),'0');
            READ_BYTE(776,811,gyro_y(7 downto 0),'0');
            READ_BYTE(812,847,gyro_z(15 downto 8),'0');
            READ_BYTE(848,883,gyro_z(7 downto 0),'1');
            
            SEND_STOP(884,887);
            
            
        end if;
    end process;
    
    
    o_working <= not (s_stage = 0);
    process(clk)
    begin
        if rising_edge(clk) then
            
            if i2c_clock = '1' then
                if s_stage=1023 then
                    s_stage <= 0;
                else
                    s_stage <= s_stage+1;
                end if;
            end if;
            
            if s_stage = 0 then
                s_stage <= 0;
            end if;
            
            if i_update then
                s_stage <= 1;
            end if;
            
            if rst = '1' then
                s_stage <= 0;
                
            end if;
        end if;
    end process;


end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

entity mpu6050 is
    generic(
        frequency_mhz : real := 27.0;
        i2c_frequency_mhz : real := 0.4;
        start_on_reset : boolean := true;
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
        i_reset_mpu : in boolean := false;
        i_update : in boolean
        
    );
end entity mpu6050;

architecture rtl of mpu6050 is
    

    constant MPU_ADDRESS_WRITE : std_logic_vector(7 downto 0) := "11010000";
    constant MPU_ADDRESS_READ : std_logic_vector(7 downto 0) :=  "11010001";
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
            
            --Loop from here
            SEND_START(265,268);
            SEND_BYTE(269,304,MPU_ADDRESS_WRITE);
            SEND_BYTE(305,340,X"3B"); --
            
            SEND_RESTART(341,344);
            SEND_BYTE(345,380,MPU_ADDRESS_READ);
            READ_BYTE(381,416,acc_x(15 downto 8),'0');
            READ_BYTE(417,452,acc_x(7 downto 0),'0');
            READ_BYTE(453,488,acc_y(15 downto 8),'0');
            READ_BYTE(489,524,acc_y(7 downto 0),'0');
            READ_BYTE(525,560,acc_z(15 downto 8),'0');
            READ_BYTE(561,596,acc_z(7 downto 0),'0');
            
            READ_BYTE(597,632,temperature(15 downto 8),'0');
            READ_BYTE(633,668,temperature(7 downto 0),'0');
            
            READ_BYTE(669,704,gyro_x(15 downto 8),'0');
            READ_BYTE(705,740,gyro_x(7 downto 0),'0');
            READ_BYTE(741,776,gyro_y(15 downto 8),'0');
            READ_BYTE(777,812,gyro_y(7 downto 0),'0');
            READ_BYTE(813,848,gyro_z(15 downto 8),'0');
            READ_BYTE(849,884,gyro_z(7 downto 0),'1');
            
            SEND_STOP(885,888);
            
            
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
                s_stage <= 265;
            end if;
            
            if i_reset_mpu then
                s_stage <= 1;
            end if;
            
            if rst = '1' then
                s_stage <= 0;
                if start_on_reset then
                    s_stage <= 1;
                end if;
            end if;
        end if;
    end process;


end architecture;
library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.t_i2c_ctrl;

entity mpu_using_fifo is
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
        
        i_update_accelerometer : in boolean;
        i_update_gyroscope: in boolean
        
    );
end mpu_using_fifo;

architecture rtl of mpu_using_fifo is

    signal s_byte_working : boolean;

    signal s_ctrl    : t_i2c_ctrl;

    signal s_ack_to_byte     : std_logic;
    signal s_data_to_byte    : std_logic_vector (7 downto 0);

    signal s_ack_from_byte    : std_logic;
    signal s_data_from_byte    : std_logic_vector (7 downto 0);

    constant last_stage :natural := 1023;
    signal s_stage : natural range 0 to last_stage;
    
    constant mpu_addr_W : std_logic_vector (7 downto 0) := "11010000";
    constant mpu_addr_R : std_logic_vector (7 downto 0) := "11010001";
    
    constant pwr_mgt_0 : std_logic_vector (7 downto 0) := x"6b";
    
    constant gyro_sensitivity_reg : std_logic_vector (7 downto 0) := x"1B";
    constant gyro_sensitivity_data : std_logic_vector (7 downto 0) := x"10";
    constant acc_sensitivity_data : std_logic_vector (7 downto 0) := x"10";
    
    constant fifo_enable_reg: std_logic_vector (7 downto 0) := x"23";
    constant fifo_enable_data: std_logic_vector (7 downto 0) := "01110000"; --enable gyro and accelerometer
    
    constant interupt_enable_reg : std_logic_vector (7 downto 0) := x"38";
    constant interupt_enable_data : std_logic_vector (7 downto 0) := x"01";
    
    constant user_ctrl : std_logic_vector (7 downto 0) := x"6a";
    constant user_ctrl_enable_fifo : std_logic_vector (7 downto 0) := "01000000";
    constant user_ctrl_reset_fifo : std_logic_vector (7 downto 0) := "00000100";
    
    constant fifo_data : std_logic_vector (7 downto 0) := x"74";
    constant accelerometer_data_reg : std_logic_vector (7 downto 0) := x"3B";

    --I2Cwrite(MPU, 0x6B, 0b10000000); // Reset device
    --__delay_ms(100);
    
    --I2Cwrite(MPU, 0x6A, 0b00000100); // Reset FIFO
    --I2Cwrite(MPU, 0x6B, 0b00000001); // Internal Clock set to Gyro output

    --I2Cwrite(MPU, 0x1B, 0b00000000); // Gyro sensitivity
    --I2Cwrite(MPU, 0x1C, 0b00000000); // Accelerometer sensitivity
    
    --I2Cwrite(MPU, 0x23, 0b00001000); // Load Accel to FIFO

    --I2Cwrite(MPU, 0x6A, 0b01000000); // Enable FIFO
    

begin

    dut : entity work.I2C_byte(rtl)
    generic map (
        frequency_mhz => 27.0,
        i2c_frequency_mhz => i2c_frequency_mhz,
        simulation => simulation
    )
    port map (clk       => clk,
        rst       => rst,
        sda       => sda,
        scl       => scl,
        o_working => s_byte_working,
        i_ctrl    => s_ctrl,
        i_ack     => s_ack_to_byte,
        i_data    => s_data_to_byte,
        o_ack     => s_ack_from_byte,
        o_data    => s_data_from_byte);

    -- EDIT: Check that clk is really your main clock signal
    
    i2c_clock_proc: process(clk)
    procedure next_stage(constant increase : in boolean) is
    begin
        if increase then
            s_stage <= s_stage + 1;
        end if;
    end procedure;
    
    begin
        if rising_edge(clk) then
            --if not s_byte_working then
            --    s_stage <= s_stage + 1;
            --end if;
            s_ctrl <= NOP_E;
            
            case s_stage is
                
                ----------------RESET DEVICE------------------------
                when 0 => next_stage(true);
                when 1 => next_stage(not s_byte_working);
                    s_ctrl <= START;
                when 2 => next_stage(true);
                when 3 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= mpu_addr_W;
                when 4 => next_stage(true);
                when 5 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= pwr_mgt_0;
                when 6 => next_stage(true);
                when 7 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= (others => '0');
                when 8 => next_stage(true);
                when 9 => next_stage(not s_byte_working);
                    s_ctrl <= STOP;
                when 10 to 15 => next_stage(true);
                    
                ----------------RESET FIFO------------------------
                when 16 => next_stage(true);
                when 17 => next_stage(not s_byte_working);
                    s_ctrl <= START;
                when 18 => next_stage(true);
                when 19 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= mpu_addr_W;
                when 20 => next_stage(true);
                when 21 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= user_ctrl;
                when 22 => next_stage(true);
                when 23 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= user_ctrl_reset_fifo;
                when 24 => next_stage(true);
                when 25 => next_stage(not s_byte_working);
                    s_ctrl <= STOP;
                when 26 to 31 => next_stage(true);
                    
                    
                ----------------Set sensitivity------------------------
                when 32 => next_stage(not s_byte_working);
                    s_ctrl <= START;
                    
                when 33 => next_stage(true);
                when 34 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= mpu_addr_W;
                when 35 => next_stage(true);
                when 36 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= gyro_sensitivity_reg;
                when 37 => next_stage(true);
                when 38 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= gyro_sensitivity_data;
                when 39 => next_stage(true);
                when 40 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= acc_sensitivity_data;
                when 41 => next_stage(true);
                when 42 => next_stage(not s_byte_working);
                    s_ctrl <= STOP;
                when 43 to 50 => next_stage(true);
                    
                ----------------configure fifo data------------------------
                when 51 => next_stage(true);
                when 52 => next_stage(not s_byte_working);
                    s_ctrl <= START;
                when 53 => next_stage(true);
                when 54 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= mpu_addr_W;
                when 55 => next_stage(true);
                when 56 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= fifo_enable_reg;
                when 57 => next_stage(true);
                when 58 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= fifo_enable_data;
                when 59 => next_stage(true);
                when 60 => next_stage(not s_byte_working);
                    s_ctrl <= STOP;
                when 61 to 62=> next_stage(true);
                    
                ---------------configure interrupt ------------------------
                when 63 => next_stage(true);
                when 64 => next_stage(not s_byte_working);
                    s_ctrl <= START;
                when 65 => next_stage(true);
                when 66 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= mpu_addr_W;
                when 67 => next_stage(true);
                when 68 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= interupt_enable_reg;
                when 69 => next_stage(true);
                when 70 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= interupt_enable_data;
                when 71 => next_stage(true);
                when 72 => next_stage(not s_byte_working);
                    s_ctrl <= STOP;
                when 73 to 80=> next_stage(true);
                    
                ----------------ENABLE FIFO------------------------
                when 81 => next_stage(true);
                when 82 => next_stage(not s_byte_working);
                    s_ctrl <= START;
                when 83 => next_stage(true);
                when 84 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= mpu_addr_W;
                when 85 => next_stage(true);
                when 86 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= user_ctrl;
                when 87 => next_stage(true);
                when 88 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= user_ctrl_enable_fifo;
                when 89 => next_stage(true);
                when 90 => next_stage(not s_byte_working);
                    s_ctrl <= STOP;
                when 91 => s_stage <= last_stage;

                    
                ----------------SET ADDRESS ACCELEROMETER------------------------
                when 100 => next_stage(not s_byte_working);
                    s_ctrl <= START;
                when 101 => next_stage(true);
                when 102 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= mpu_addr_W;
                when 103 => next_stage(true);
                when 104 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= accelerometer_data_reg;
                when 105 => next_stage(true);
                when 106 => next_stage(not s_byte_working);
                    s_ctrl <= STOP;
                when 107 => next_stage(true);
                    
                ----------------READ ACCELEROMETER------------------------
                when 108 => next_stage(not s_byte_working);
                    s_ctrl <= START;
                when 109 => next_stage(true);
                when 110 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= mpu_addr_R;
                when 111 to 120 => next_stage(true);
                    
                ----------------acc_x------------------------
                when 121 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 122 => next_stage(true);
                when 123 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                    acc_x(7 downto 0) <= s_data_from_byte;
                when 124 => next_stage(true);
                when 125 => next_stage(not s_byte_working);
                    acc_x(15 downto 8) <= s_data_from_byte;
                when 126 => next_stage(true);
                when 127 => next_stage(not s_byte_working);
                when 128 to 140 => next_stage(true);
                    
                ----------------acc_y------------------------
                when 141 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 142 => next_stage(true);
                when 143 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                    acc_y(7 downto 0) <= s_data_from_byte;
                when 144 => next_stage(true);
                when 145 => next_stage(not s_byte_working);
                    acc_y(15 downto 8) <= s_data_from_byte;
                when 146 => next_stage(true);
                when 147 => next_stage(not s_byte_working);
                when 148 to 160 => next_stage(true);
                    
                ----------------acc_z------------------------
                when 161 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 162 => next_stage(true);
                when 163 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= (others => '1');
                    acc_z(7 downto 0) <= s_data_from_byte;
                when 164 => next_stage(true);
                when 165 => next_stage(not s_byte_working);
                    acc_z(15 downto 8) <= s_data_from_byte;
                when 166 => next_stage(true);
                when 167 => next_stage(not s_byte_working);
                    s_ctrl <= STOP;
                when 168 to 179 => s_stage <= last_stage;
                    
                    
                ----------------SET ADDRESS FIFO------------------------
                when 180 => next_stage(not s_byte_working);
                    s_ctrl <= START;
                when 181 => next_stage(true);
                when 182 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= mpu_addr_W;
                when 183 => next_stage(true);
                when 184 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= fifo_data;
                when 185 => next_stage(true);
                when 186 => next_stage(not s_byte_working);
                    s_ctrl <= STOP;
                when 187 => next_stage(true);
                    
                ----------------READ GYRO------------------------
                when 188 => next_stage(not s_byte_working);
                    s_ctrl <= START;
                when 189 => next_stage(true);
                when 190 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= mpu_addr_R;
                when 191 to 200 => next_stage(true);
                    
                    
                ----------------gyro_x------------------------
                when 201 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 202 => next_stage(true);
                when 203 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                    gyro_x(7 downto 0) <= s_data_from_byte;
                when 204 => next_stage(true);
                when 205 => next_stage(not s_byte_working);
                    gyro_x(15 downto 8) <= s_data_from_byte;
                when 206 => next_stage(true);
                when 207 => next_stage(not s_byte_working);
                when 208 to 210 => next_stage(true);
                    
                ----------------gyro_y------------------------
                when 211 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 212 => next_stage(true);
                when 213 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                    gyro_y(7 downto 0) <= s_data_from_byte;
                when 214 => next_stage(true);
                when 215 => next_stage(not s_byte_working);
                    gyro_y(15 downto 8) <= s_data_from_byte;
                when 216 => next_stage(true);
                when 217 => next_stage(not s_byte_working);
                when 218 to 220 => next_stage(true);
                    
                ----------------gyro_z------------------------
                when 221 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 222 => next_stage(true);
                when 223 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= (others => '1');
                    gyro_z(7 downto 0) <= s_data_from_byte;
                when 224 => next_stage(true);
                when 225 => next_stage(not s_byte_working);
                    gyro_z(15 downto 8) <= s_data_from_byte;
                when 226 => next_stage(true);
                when 227 => next_stage(not s_byte_working);
                    s_ctrl <= STOP;
                when 228 to 240 => next_stage(true);
                    
                when 241 => s_stage <= last_stage;
                    
                    
               -- when 241 => next_stage(not s_byte_working);
                --    s_ctrl <= STOP;
                --when 242 => s_stage <= last_stage;
                    
                    
                    
                when others =>
                    o_working <= false;
                    s_stage <= last_stage;
                    s_ctrl <= NOP_E;
                    
            end case;
            
            if i_update_gyroscope then
                o_working <= true;
                s_stage <= 180;
            end if;
            
            if i_update_accelerometer then
                o_working <= true;
                s_stage <= 100;
            end if;
            
            if i_reset_mpu then
                s_stage <= 0;
            end if;
            
            if rst = '1' then
                s_ctrl <= NOP_E;
                s_stage <= last_stage;
                if start_on_reset then
                    s_stage <= 0;
                end if;
            end if;

        end if;
    end process;

end rtl;
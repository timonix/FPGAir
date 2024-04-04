library ieee;
use ieee.std_logic_1164.all;

use work.common_pkg.t_i2c_ctrl;

entity mpu is
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
        
        data_valid : out boolean;
        o_working : out boolean;
        i_reset_mpu : in boolean := false;
        i_update : in boolean
        
    );
end mpu;

architecture rtl of mpu is

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
    constant data_addr : std_logic_vector (7 downto 0) := x"3b";

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
            data_valid <= false;
            
            case s_stage is
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
                when 10 => s_stage <= last_stage;
                    
                ----------------Set address------------------------
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
                    s_data_to_byte <= data_addr;
                when 22 => next_stage(true);
                when 23 => next_stage(not s_byte_working);
                    s_ctrl <= STOP;
                    
                when 24 => next_stage(true);
                when 25 => next_stage(not s_byte_working);
                    s_ctrl <= START;
                when 26 => next_stage(true);
                when 27 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= mpu_addr_R;
                when 28 => next_stage(true);
                    ----------------acc_x------------------------
                when 29 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 30 => next_stage(true);
                when 31 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                    acc_x(15 downto 8) <= s_data_from_byte;
                when 32 => next_stage(true);
                when 33 => next_stage(not s_byte_working);
                    acc_x(7 downto 0) <= s_data_from_byte;
                when 34 => next_stage(true);
                when 35 => next_stage(not s_byte_working);
                when 36 to 40 => next_stage(true);
                    
                ----------------acc_y------------------------
                when 41 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 42 => next_stage(true);
                when 43 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                    acc_y(15 downto 8) <= s_data_from_byte;
                when 44 => next_stage(true);
                when 45 => next_stage(not s_byte_working);
                    acc_y(7 downto 0) <= s_data_from_byte;
                when 46 => next_stage(true);
                when 47 => next_stage(not s_byte_working);
                when 48 to 60 => next_stage(true);
                    
                ----------------acc_z------------------------
                when 61 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 62 => next_stage(true);
                when 63 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                    acc_z(15 downto 8) <= s_data_from_byte;
                when 64 => next_stage(true);
                when 65 => next_stage(not s_byte_working);
                    acc_z(7 downto 0) <= s_data_from_byte;
                when 66 => next_stage(true);
                when 67 => next_stage(not s_byte_working);
                when 68 to 70 => next_stage(true);
                    
                ----------------temp------------------------
                when 71 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 72 => next_stage(true);
                when 73 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                    temperature(15 downto 8) <= s_data_from_byte;
                when 74 => next_stage(true);
                when 75 => next_stage(not s_byte_working);
                    temperature(7 downto 0) <= s_data_from_byte;
                when 76 => next_stage(true);
                when 77 => next_stage(not s_byte_working);
                when 78 to 90 => next_stage(true);
                    
                ----------------gyro x------------------------
                when 91 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 92 => next_stage(true);
                when 93 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                    gyro_x(15 downto 8) <= s_data_from_byte;
                when 94 => next_stage(true);
                when 95 => next_stage(not s_byte_working);
                    gyro_x(7 downto 0) <= s_data_from_byte;
                when 96 => next_stage(true);
                when 97 => next_stage(not s_byte_working);
                when 98 to 100 => next_stage(true);
                    
                ----------------gyro y------------------------
                when 101 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 102 => next_stage(true);
                when 103 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                    gyro_y(15 downto 8) <= s_data_from_byte;
                when 104 => next_stage(true);
                when 105 => next_stage(not s_byte_working);
                    gyro_y(7 downto 0) <= s_data_from_byte;
                when 106 => next_stage(true);
                when 107 => next_stage(not s_byte_working);
                when 108 to 120 => next_stage(true);
                    
                ----------------gyro z------------------------
                when 121 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '1';
                    s_data_to_byte <= (others => '1');
                when 122 => next_stage(true);
                when 123 => next_stage(not s_byte_working);
                    s_ctrl <= RW;
                    s_ack_to_byte <= '0';
                    s_data_to_byte <= (others => '1');
                    gyro_z(15 downto 8) <= s_data_from_byte;
                when 124 => next_stage(true);
                when 125 => next_stage(not s_byte_working);
                    gyro_z(7 downto 0) <= s_data_from_byte;
                    s_ctrl <= STOP;
                    data_valid <= true;
                when 126 => next_stage(true);
                when 127 => next_stage(not s_byte_working);
                when 128 to 140 => next_stage(true);

                when others =>
                    o_working <= false;
                    s_stage <= last_stage;
                    s_ctrl <= NOP_E;
                    
            end case;
            
            if i_update then
                o_working <= true;
                s_stage <= 17;
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.beagle_pkg.all;
use work.common_pkg.all;

entity balloon_top is
    generic (
        frequency_mhz : real := 27.0;
        simulation : boolean := false
    );
    port (
        clk    : in std_logic;
        resetn : in std_logic;
        
        sda : inout std_logic;
        scl : inout std_logic;
        
        tx_ext : out std_logic;
        rx_ext : in std_logic
        
    );
end entity balloon_top;

architecture rtl of balloon_top is
    signal reset : std_logic;
    signal acc_x : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_y : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_z : STD_LOGIC_VECTOR(15 downto 0);
    
    signal gyro_x : STD_LOGIC_VECTOR(15 downto 0);
    signal gyro_y : STD_LOGIC_VECTOR(15 downto 0);
    signal gyro_z : STD_LOGIC_VECTOR(15 downto 0);

    signal mpu_data_valid : boolean;
    
    signal read_mpu : boolean;
    
    signal mpu_failure : boolean;
    
    signal beagle_addr : unsigned(6 downto 0);
    signal beagle_data_in_valid : boolean;
    signal beagle_data_in : STD_LOGIC_VECTOR(31 downto 0);
    signal beagle_data_out : STD_LOGIC_VECTOR(31 downto 0);
    signal beagle_write : boolean;
    
    signal program_counter : STD_LOGIC_VECTOR(7 downto 0);
    signal program_counter_valid : boolean;
    
    signal debug_tx : STD_LOGIC_VECTOR(31 downto 0);
    signal debug_valid : boolean;
    constant timings_us : integer_array := (0,500,1000,1500,5);
    signal sequencer_outputs : BOOLEAN_VECTOR(timings_us'low to timings_us'high);
    
    signal counter : integer range 0 to 2**18-1 := 0;
begin
    reset <= not resetn;
    
    sequencer_inst: entity work.sequencer
    generic map(
        frequency_mhz => frequency_mhz,
        timings_us => (0,500,1000,1500)
    )
    port map(
        clk => clk,
        rst => reset,
        enable => true,
        outputs => sequencer_outputs
    );
    
    mpu6050_inst : entity work.brute_6050
    generic map (
        frequency_mhz => frequency_mhz,
        i2c_frequency_mhz => 0.4,
        reset_on_reset => true,
        start_on_reset => true,
        simulation => simulation,
        error_detection => true
    )
    port map (
        clk => clk,
        rst => reset,
        sda => sda,
        scl => scl,
        acc_x => acc_x,
        acc_y => acc_y,
        acc_z => acc_z,
        gyro_x => gyro_x,
        gyro_y => gyro_y,
        gyro_z => gyro_z,
        mpu_data_valid => open,
        update_mpu => sequencer_outputs(0) or sequencer_outputs(1) or sequencer_outputs(2) or sequencer_outputs(3),
        mpu_failure => mpu_failure
    );
    
    beagle_inst: entity work.beagle
    generic map (
        program_addr_width => 10
    )
    port map(
        clk => clk,
        reset => reset,
        ext_addr => beagle_addr,
        ext_data_in_valid => beagle_data_in_valid,
        ext_data_in => beagle_data_in,
        ext_data_out => beagle_data_out,
        ext_write => beagle_write,
        program_counter_valid => sequencer_outputs(4),
        program_counter => to_unsigned(0,10)
    );
    
    
    uart_rx_inst: entity work.uart_rx
    generic map(
        frequency_mhz => frequency_mhz,
        baud_rate_mhz => 115200.0/1000000.0
    )
    port map(
        clk => clk,
        rst => reset,
        enable => true,
        rx => rx_ext,
        data => open,
        data_valid => open
    );
    
    beagle_bus_inst: entity work.beagle_bus
    port map(
        clk => clk,
        reset => reset,
        beagle_addr => beagle_addr,
        beagle_data_in_valid => beagle_data_in_valid,
        beagle_data_in => beagle_data_in,
        beagle_data_out => beagle_data_out,
        beagle_write => beagle_write,
        gyro_x => gyro_x,
        gyro_y => gyro_y,
        gyro_z => gyro_z,
        acc_x => acc_x,
        acc_y => acc_y,
        acc_z => acc_z,
        temperature => (others => '1'),
        debug_tx => debug_tx,
        debug_rx => x"DEADBEEF",
        debug_valid => debug_valid
    );
    
    data_unloader_inst: entity work.data_unloader
    generic map(
        frequency_mhz => frequency_mhz,
        boot_message => "H",
        delimiter => ' ',
        num_bytes => 4
    )
    port map(
        clk => clk,
        rst => reset,
        o_ready => open,
        i_valid => debug_valid,
        i_data => debug_tx,
        o_tx => tx_ext
    );
    

end architecture;
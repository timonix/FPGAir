library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.beagle_pkg.all;
use work.common_pkg.all;


entity consumate_top is
    generic (
        frequency_mhz : real := 27.0;
        simulation : boolean := false
    );
    port (
        clk    : in std_logic;
        resetn : in std_logic;
        
        sda : inout std_logic;
        scl : inout std_logic;
        
        led_ext : out std_logic;
        
        led_running : out std_logic;
        
        tx_ext : out std_logic;
        rx_ext : in std_logic
        
    );
end entity consumate_top;

architecture rtl of consumate_top is
    
    signal q_reset  : std_logic;
    signal q_resetn : std_logic;
                                         --S   S    S   S   Scale Est_gyro print
    constant timings_us : integer_array := (0,500,1000,1500,100,  200,     300);
    signal sequencer_outputs : BOOLEAN_VECTOR(timings_us'low to timings_us'high);
    
    signal mpu_failure : boolean;
    
    signal beagle_addr : unsigned(6 downto 0);
    signal beagle_data_in_valid : boolean;
    signal beagle_data_in : STD_LOGIC_VECTOR(31 downto 0);
    signal beagle_data_out : STD_LOGIC_VECTOR(31 downto 0);
    signal beagle_write : boolean;
    
    signal program_run : boolean;
    signal program_select : unsigned(9 downto 0);
    
    signal acc_x : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_y : STD_LOGIC_VECTOR(15 downto 0);
    signal acc_z : STD_LOGIC_VECTOR(15 downto 0);
    
    signal gyro_x : STD_LOGIC_VECTOR(15 downto 0);
    signal gyro_y : STD_LOGIC_VECTOR(15 downto 0);
    signal gyro_z : STD_LOGIC_VECTOR(15 downto 0);
    
    signal debug_tx : STD_LOGIC_VECTOR(31 downto 0);
    signal debug_valid : boolean;
    
begin
    
    process (clk)
    begin
        if rising_edge(clk) then
            program_run <= false;
            if sequencer_outputs(4) then
                program_select <= TO_UNSIGNED(50,10); --Scale bias
                program_run <= true;
            end if;
            
            if sequencer_outputs(5) then
                program_select <= TO_UNSIGNED(18,10); --Est_gyro
                program_run <= true;
            end if;
            
            if sequencer_outputs(6) then
                program_select <= TO_UNSIGNED(0,10); --print
                program_run <= true;
            end if;
            
        end if;
    end process;
    
    led_ext <= '0' when mpu_failure else '1';
    led_running <= q_resetn;
    
    reset_sync_inst: entity work.reset_sync
    generic map(
        RST_ACTIVE_HIGH => false
    )
    port map(
        clk => clk,
        rst_in => resetn,
        reset  => q_reset,
        resetn => q_resetn
    );

    sequencer_inst: entity work.sequencer
    generic map(
        frequency_mhz => frequency_mhz,
        timings_us => timings_us
    )
    port map(
        clk => clk,
        rst => q_reset,
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
        rst => q_reset,
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
        reset => q_reset,
        ext_addr => beagle_addr,
        ext_data_in_valid => beagle_data_in_valid,
        ext_data_in => beagle_data_in,
        ext_data_out => beagle_data_out,
        ext_write => beagle_write,
        program_counter_valid => program_run,
        program_counter => program_select
    );
    
    beagle_bus_inst: entity work.beagle_bus
    port map(
        clk => clk,
        reset => q_reset,
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
    
    buffered_data_unloader_inst: entity work.buffered_data_unloader
    generic map(
        frequency_mhz => frequency_mhz,
        boot_message => "hello",
        num_bytes => 4,
        buffer_size => 32
    )
    port map(
        clk => clk,
        rst => q_reset,
        o_ready => open,
        i_valid => debug_valid,
        i_data => debug_tx,
        o_tx => tx_ext
    );

end architecture;
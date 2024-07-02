library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_moss is
    generic (
        frequency_mhz : real := 27.0;
        baud_rate_mhz : real := 115200.0/1000000.0;
        boot_message : String := "unload.";
        delimiter : character := 'D'
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        radio_channel_ext : in std_logic_vector(1 to 6);
        led : out std_logic;
        tx_ext : out std_logic
    );
end entity top_moss;

architecture Behavioral of top_moss is
    -- Component declarations
    component radio_channel is
        generic (
            frequency_mhz : real := 27.0
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            enable : in boolean;
            channel_pwm : in std_logic;
            channel_data : out unsigned(10 downto 0)
        );
    end component;

    component data_unloader is
        generic(
            frequency_mhz : real := 27.0;
            baud_rate_mhz : real := 115200.0/1000000.0;
            boot_message : String := "unload.";
            delimiter : character := 'D';
            num_bytes : positive := 14
        );
        port(
            clk : in std_logic;
            rst : in std_logic;
            o_ready : out boolean;
            i_valid : in boolean;
            i_data : in std_logic_vector(num_bytes*8-1 downto 0);
            o_tx : out std_logic
        );
    end component;

    -- Signals
    
    type channel_data_array is array (1 to 6) of unsigned(10 downto 0);
    signal channel_data : channel_data_array;
    signal channel : unsigned (10 downto 0);
    signal unloader_ready : boolean;
    signal unloader_valid : boolean;
    signal unloader_data : std_logic_vector(14*8-1 downto 0);
    
    -- State machine signals
    type state_type is (IDLE, SEND_CH0, SEND_CH1, SEND_CH2, SEND_CH3, SEND_CH4, SEND_CH5);
    signal current_state, next_state : state_type;
    
    signal system_armed : boolean;

begin
    
    
    
    -- Instantiate 6 radio channels
    gen_channels: for i in 1 to 6 generate
        channel_inst: radio_channel
        generic map (
            frequency_mhz => frequency_mhz
        )
        port map (
            clk => clk,
            rst => rst,
            enable => true,
            channel_pwm => radio_channel_ext(i),
            channel_data => channel_data(i)
        );
    end generate;
    
    pulser_inst : entity work.arming
    port map (
        clk => clk,        -- Connect to your clock signal
        rst => rst,      -- Connect to your reset signal
        channel_1 => channel_data(1),  -- Connect to your channel 1 signal
        channel_2 => channel_data(2),  -- Connect to your channel 2 signal
        channel_3 => channel_data(3),  -- Connect to your channel 3 signal
        channel_4 => channel_data(4),  -- Connect to your channel 4 signal
        channel_5 => channel_data(5),  -- Connect to your channel 5 signal
        armed => system_armed     -- Connect to your armed signal
    );
    
    unloader_data(7*16+15-16 downto 7*16+11-16+1) <= (others => '0');
    unloader_data(7*16+11-16) <= '1';-- when system_armed else '0';
    
    led <= '0' when system_armed else '1';

    ch:for i in 1 to 6 generate
        unloader_data(i*16+15-16 downto i*16+11-16) <= (others => '0');
        unloader_data(i*16+10-16 downto i*16-16) <= std_logic_vector(channel_data(i));
    end generate;

    -- Instantiate data unloader
    unloader_inst: data_unloader
    port map (
        clk => clk,
        rst => rst,
        o_ready => open,
        i_valid => true,
        i_data => unloader_data,
        o_tx => tx_ext
    );


end architecture Behavioral;
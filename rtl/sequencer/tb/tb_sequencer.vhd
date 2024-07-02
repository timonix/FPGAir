library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sequencer is
end tb_sequencer;

architecture Behavioral of tb_sequencer is
    constant TbPeriod : time := 37.037 ns; -- 27 MHz clock period
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';
    signal clk : std_logic;
    signal rst : std_logic;
    signal enable : boolean;
    signal update_pid : boolean;
    signal update_mpu : boolean;
    signal send_pulse : boolean;
    signal calculate_attitude : boolean;
    
    -- Component declaration for the unit under test (UUT)
    component sequencer
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        enable     : in  boolean;
        update_pid : out boolean;
        update_mpu : out boolean;
        send_pulse : out boolean;
        calculate_attitude : out BOOLEAN
    );
end component;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: sequencer
    port map (
        clk => clk,
        rst => rst,
        enable => enable,
        update_pid => update_pid,
        update_mpu => update_mpu,
        send_pulse => send_pulse,
        calculate_attitude => calculate_attitude
    );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    -- Stimulus process
    stimulus: process
    begin
        -- Initialize inputs
        rst <= '0';
        enable <= FALSE;
        wait for 100 ns;
        
        -- Reset the UUT
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        
        -- Enable the UUT
        enable <= TRUE;
        wait for 4 ms;

        -- Disable the UUT
        enable <= FALSE;
        wait for 10 * TbPeriod;

        -- End simulation
        TbSimEnded <= '1';
        wait;
    end process;

end Behavioral;

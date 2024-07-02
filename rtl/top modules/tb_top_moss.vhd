library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top_moss is
end tb_top_moss;

architecture Behavioral of tb_top_moss is
    -- Component declaration
    component top_moss is
        generic (
            frequency_mhz : real := 27.0;
            baud_rate_mhz : real := 115200.0/1000000.0;
            boot_message : String := "unload.";
            delimiter : character := 'D'
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            channel_pwms : in std_logic_vector(5 downto 0);
            o_tx : out std_logic
        );
    end component;

    -- Constants
    constant CLK_PERIOD : time := 37 ns;  -- ~27 MHz

    -- Signals
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal channel_pwms : std_logic_vector(5 downto 0) := (others => '0');
    signal o_tx : std_logic;
    
    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: top_moss
    port map (
        clk => clk,
        rst => rst,
        channel_pwms => channel_pwms,
        o_tx => o_tx
    );

    -- Clock process
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 100 ns
        rst <= '1';
        wait for 100 ns;
        rst <= '0';

        -- Wait for global reset to finish
        wait for 100 ns;

        -- Test different PWM inputs
        channel_pwms <= "101010";
        wait for 1 ms;

        channel_pwms <= "010101";
        wait for 1 ms;

        channel_pwms <= "111000";
        wait for 1 ms;

        channel_pwms <= "000111";
        wait for 1 ms;
        
        TbSimEnded <= '1';

        -- End simulation
        wait;
    end process;

end Behavioral;
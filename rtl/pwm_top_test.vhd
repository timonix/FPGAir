library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_top_test is
    port (
        sys_clk      : in  std_logic;
        sys_rst_n     : in  std_logic;
        output_pin : out STD_LOGIC;
        micro_clock_pin : out STD_LOGIC
    );
end pwm_top_test;

architecture rtl of pwm_top_test is

    
    signal speed_input : UNSIGNED(10 downto 0);-- := "00111110100";
    signal counter : UNSIGNED(30 downto 0);
    
    component pwm is
        generic(
            frequency_mhz : real := 27.0
        );
        port(
            clk  : in std_logic;
            rst : in STD_LOGIC;
            enable : in BOOLEAN;
            speed : in UNSIGNED(10 downto 0);
            output : out STD_LOGIC;
            sync : out STD_LOGIC
        );
    end component;

    
begin
    
    speed_input(9 downto 0) <= counter(30 downto 21);
    speed_input(10) <= '0';
    
    radio_module : pwm
    port map (
        clk => sys_clk,
        rst => sys_rst_n,
        enable => true,
        speed => speed_input,
        output => output_pin,
        sync => micro_clock_pin
    );
    
    process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            counter <= counter + 1;
        end if;
    end process;
    
end rtl;
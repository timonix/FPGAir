library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_top_test is
    port (
        sys_clk      : in  std_logic;
        sys_rst_n     : in  std_logic;
        output_pin : out STD_LOGIC
    );
end pwm_top_test;

architecture rtl of pwm_top_test is

    
    constant speed_input : STD_LOGIC_VECTOR(10 downto 0) := "00111110100";
    
    component pwm is
        generic(
            frequency_mhz : real := 27.0
        );
        port(
            clk  : in std_logic;
            rst : in STD_LOGIC;
            speed : in STD_LOGIC_VECTOR(10 downto 0);
            output : out STD_LOGIC
        );
    end component;

    
begin
    
    radio_module : pwm
    port map (
        clk => sys_clk,
        rst => sys_rst_n,
        speed => speed_input,
        output => output_pin
    ); 
    

    
end rtl;
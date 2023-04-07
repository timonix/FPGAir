library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        sys_clk      : in  std_logic;
        sys_rst_n     : in  std_logic;
        led  : out std_logic_vector(5 downto 0);
        channel_1 : in std_logic
    );
end top;

architecture rtl of top is

    signal multiplier : unsigned(9 downto 0);
    signal signal_1 : STD_LOGIC_VECTOR(9 downto 0);
    
    component radio is
        generic(
            frequency_mhz : real := 27.0
        );
        port(
            clk  : in std_logic;
            rst : in STD_LOGIC;
            channel_1 : in STD_LOGIC;
            signal_1 : out STD_LOGIC_VECTOR(9 downto 0);
            multiplier : in unsigned(9 downto 0)
        );
    end component;

    
begin
    
led(5 downto 0) <= signal_1(9 downto 4);
    radio_module : radio
    port map (
        clk => sys_clk,
        rst => sys_rst_n,
        channel_1 => channel_1,
        signal_1 => signal_1,
        multiplier => multiplier
    );
    
    p_1_HZ : process (sys_clk) is

    begin
        if rising_edge(sys_clk) then
            multiplier <= multiplier+1;
        end if;
        
    end process p_1_HZ;
    
    

    
end rtl;
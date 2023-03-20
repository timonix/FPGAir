library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity test_02_tb is
end entity test_02_tb;

architecture rtl of test_02_tb is
    
    constant period_time : time      := 83333 ps;
    signal   finished    : std_logic := '0';
    
    signal CLK : std_logic;
    signal LED : std_logic;
    signal a_number : STD_LOGIC_VECTOR(7 downto 0) := "01100101";
    
    component test_02 is
        port(
            CLK : in     std_logic;
            LED : buffer std_logic := '0'
        );
    end component test_02;
    
begin

    sim_time_proc: process
    begin
        wait for 200 ms;
        finished <= '1';
        wait;
    end process sim_time_proc;

    clk_proc: process
    begin
        while finished /= '1' loop
            CLK <= '0';
            wait for period_time/2;
            CLK <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;
    
    u1: test_02
    port map
    (
        CLK => CLK,
        LED => LED
    );

end architecture rtl; 
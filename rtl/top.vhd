library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity top is
  port (
    sys_clk      : in  std_logic;
    sys_rst_n     : in  std_logic;
    led  : out std_logic_vector(5 downto 0)
    );
end top;
 
architecture rtl of top is
 
  signal counter : unsigned(24 downto 0);
begin
 
  led <= std_logic_vector(counter(24 downto 24-5));
   
  p_1_HZ : process (sys_clk) is

  begin
    if rising_edge(sys_clk) then
      counter <= counter + 1;

      if sys_rst_n = '1' then
        counter <= (others => '0');
      end if;
    end if;
  end process p_1_HZ;
 
   

 
end rtl;
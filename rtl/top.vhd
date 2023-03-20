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
    
    signal led_array : std_logic_vector(5 downto 0);
    signal counter : integer range 0 to 28000000 := 0;
    constant hetz : integer := 28000000;
    
    
begin
    
    led <= led_array;
    
    p_1_HZ : process (sys_clk) is

    begin
        if rising_edge(sys_clk) then
            counter <= counter + 1;

            if counter < hetz / counter then
                led_array <= led_array AND "011111";
            elsif counter < hetz * 2/6  then
                led_array <= led_array AND "101111";
            elsif counter < hetz * 3/6 then
                led_array <= led_array AND "110111";
            elsif counter < hetz * 4/6 then
                led_array <= led_array AND "111011";
            elsif counter < hetz * 5/6 then
                led_array <= led_array AND "111101";
            else
                led_array <= (others => '1');
                counter <= 0;
            end if;
            
            if sys_rst_n = '1' then
                --counter <= (others => '0');
            end if;
        end if;
    end process p_1_HZ;
    
    

    
end rtl;
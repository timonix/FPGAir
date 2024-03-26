library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filter is
    generic(
        shift_amount : integer := 7;
        data_width : POSITIVE := 16
    );
    
    port (
        clk   : in  std_logic;
        reset : in  std_logic;
        input : in  signed(data_width-1 downto 0);
        output: out signed(data_width-1 downto 0)
    );
end entity filter;

architecture Behavioral of filter is
    signal last_value : signed(data_width-1 downto 0) := (others => '0');
begin
    process (clk, reset)
    begin
        if rising_edge(clk) then
            last_value <= shift_right(last_value, 1) + shift_right(input,shift_amount);
            if reset = '1' then
                last_value <= (others => '0');
            end if;
        end if;
    end process;

    output <= shift_left(last_value,1);
end architecture Behavioral;
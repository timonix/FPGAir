library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity arming is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        force_disarm : in boolean;-- := false;
        channel_1 : in UNSIGNED(10 downto 0);
        channel_2 : in UNSIGNED(10 downto 0);
        channel_3 : in UNSIGNED(10 downto 0);
        channel_4 : in UNSIGNED(10 downto 0);
        channel_5 : in UNSIGNED(10 downto 0);
        armed : out BOOLEAN
    );
end arming;

architecture Behavioral of arming is
    signal armed_state : boolean := false;
    
    --PSL default clock is rising_edge(clk);
    
begin
    process(clk)
    begin
        
        if rising_edge(clk) then
            -- Check arming conditions
            if  channel_1 < 1350 and
            channel_2 < 1350 and
            channel_3 > 1650 and
            channel_4 > 1650 and
            channel_5 > 1650 then
                armed_state <= true;
            -- Check disarming condition
            elsif channel_5 < 1400 then
                armed_state <= false;
            end if;
            
            if rst = '1' or force_disarm then
                armed_state <= false;
            end if;
        end if;
    end process;

    armed <= armed_state;
    
    --PSL NEXT_0_a : assert always (force_disarm -> next (not armed_state));


end Behavioral;
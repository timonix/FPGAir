library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity atan_tb is
end entity atan_tb;

architecture Behavioral of atan_tb is
    constant n: natural := 17;
    constant table_size: natural := 17;
    signal index: natural range 0 to table_size-1;
    signal value: signed(n-1 downto 0);
    

begin
    
    
    -- Instantiate the atan_lookup_table entity
    uut: entity work.atan_table
        generic map (
            max_index => table_size-1,
            value_size => n
        )
        port map (
            index => index,
            value => value
        );
    

    -- Stimulus process
    stim_proc: process
    begin
        -- Test all index values from 0 to 15
        for i in 0 to table_size-1 loop
            index <= i;
            wait for 10 ns;

        end loop;

        -- End the simulation
        wait;
    end process;

end architecture Behavioral;
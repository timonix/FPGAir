-----------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_unloader_test_top is
    port (
        -- Define the external ports for the uart_system
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        tx : out STD_LOGIC
        -- other ports as required
    );
end entity data_unloader_test_top;

architecture Behavioral of data_unloader_test_top is
    
    signal data : UNSIGNED(15 downto 0);
    signal ready : boolean;

begin
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                data <= (others => '0');
            elsif ready then
                data <= data + 1;
            end if;
        end if;
    end process;

    DUT: entity work.data_unloader(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 1000000.0/1000000.0,
        boot_message  => "FPGAir data unload test:",
        delimiter     => 'D',
        num_bytes     => 2
    )
    port map (
        clk     => clk,
        rst     => rst,
        o_ready => ready,
        i_valid => true,
        i_data  => std_logic_vector(data),
        o_tx    => tx
    );

end Behavioral;
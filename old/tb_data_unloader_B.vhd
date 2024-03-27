-----------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_data_unloader_2B is

end entity tb_data_unloader_2B;



architecture Behavioral of tb_data_unloader_2B is
    
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC;
    signal tx : STD_LOGIC;
    signal tx_2 : STD_LOGIC;
    
    signal data : UNSIGNED(15 downto 0);
    signal ready : boolean;

    signal s_tx : std_logic;
    constant clk_period : time := 37 ns;  -- assuming 27 MHz for simplicity, adjust accordingly
    
    signal TbSimEnded : boolean := false;

begin
    
    clk <= not clk after clk_period / 2 when not TbSimEnded else '0';
    
    stim_proc: process
    begin
        -- Apply reset
        rst <= '1';
        wait for 100 * clk_period;
        rst <= '0';
        wait for 100000 * clk_period;
        --wait for 10000 * clk_period;

        --i_data <= "00110011";  -- Another example byte
        --i_valid <= true;
        --wait until o_ready = true;
        --i_valid <= false;
        
        -- More tests can be added as necessary

        TbSimEnded <= true;
        wait;  -- Hold simulation
    end process;

    tx <= s_tx;
    tx_2 <= s_tx;
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

    DUT: entity work.data_unloader_2(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 100000.0/1000000.0,
        boot_message  => "FPGAir:",
        delimiter     => 'D',
        num_bytes     => 2
    )
    port map (
        clk     => clk,
        rst     => rst,
        o_ready => ready,
        i_valid => true,
        i_data  => std_logic_vector(data),
        o_tx    => s_tx
    );

end Behavioral;
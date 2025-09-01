
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity balloon_top_tb is
end entity balloon_top_tb;

architecture rtl of balloon_top_tb is
    signal clk_period : time := 1 ns;
    signal tb_clk : std_logic;
    signal tb_rst : std_logic;
    signal sda : std_logic;
    signal scl : std_logic;
    
    signal tx_ext : std_logic;
    signal rx_ext : std_logic := '1';
begin
    
    clk_process : process
    begin
        while true loop
            tb_clk <= '0';
            wait for clk_period / 2;
            tb_clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;
    
    process
    begin
        tb_rst <= '0';
        wait for 10 ns;
        tb_rst <= '1';
        wait;
    end process;

    balloon_top_inst: entity work.balloon_top
    generic map(
        frequency_mhz => 27.0,
        simulation => true
    )
    port map(
        clk => tb_clk,
        resetn => tb_rst,
        sda => sda,
        scl => scl,
        tx_ext => tx_ext,
        rx_ext => rx_ext
    );
    

end architecture;
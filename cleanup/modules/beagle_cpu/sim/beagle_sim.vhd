library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.beagle_pkg.all;

entity beagle_sim is
end entity beagle_sim;

architecture rtl of beagle_sim is
    signal clk_period : time := 1 ns;
    signal tb_clk : std_logic;
    signal tb_rst : std_logic;
    
    signal ext_addr : unsigned(6 downto 0);
    signal ext_data_in_valid : boolean := false;
    signal ext_data_in : std_logic_Vector(C_BEAGLE_DATA_WIDTH-1 downto 0);
    signal ext_data_out : std_logic_Vector(C_BEAGLE_DATA_WIDTH-1 downto 0);
    signal ext_write : boolean;
    
    signal program_counter_valid : boolean := false;
    signal program_counter : unsigned(8-1 downto 0);
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
        tb_rst <= '1';
        wait for 10 ns;
        tb_rst <= '0';
        wait;
    end process;

    beagle_inst: entity work.beagle
    generic map (
        program_addr_width => 8
    )
    port map(
        clk => tb_clk,
        reset => tb_rst,
        ext_addr => ext_addr,
        ext_data_in => ext_data_in,
        ext_data_in_valid => ext_data_in_valid,
        ext_data_out => ext_data_out,
        ext_write => ext_write,
        program_counter_valid => program_counter_valid,
        program_counter => program_counter
    );

end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity eager_tb_pc is
end entity eager_tb_pc;

architecture rtl of eager_tb_pc is

    constant clk_period : time := 10 ns;

    constant program_addr_width : integer := 4;
    signal tb_clk, tb_reset : std_logic;
    signal set_program_counter : boolean := false;
    signal program_counter_value : unsigned(program_addr_width-1 downto 0);
    
    signal sim_ended :boolean := false;
    
begin
    
        -- Clock generation process
    clk_process : process
    begin
        while sim_ended = false loop
            tb_clk <= '0';
            wait for clk_period / 2;
            tb_clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;
    
        -- Reset and stimulus process
    stim_proc : process
    begin
        -- Initial reset
        tb_reset <= '1';
        wait for clk_period * 2;
        tb_reset <= '0';
        wait until rising_edge(tb_clk);
        -- Wait for 10 clock cycles
        wait for clk_period * 10;

        -- Set program_counter_value to 2 and assert set_program_counter
        program_counter_value <= to_unsigned(1, program_addr_width);
        set_program_counter <= true;
        wait for clk_period;
        set_program_counter <= false;
        wait for clk_period * 30;
        

        assert false report "SIM ENDED";
        wait; -- Wait forever
    end process;

    eager_inst: entity work.eager
    generic map(
        program_addr_width => program_addr_width,
        rom_init => "eager_init.rom"
    )
    port map(
        clk => tb_clk,
        reset => tb_reset,
        ext_data_in => (others => '0'),
        program_counter_valid => set_program_counter,
        program_counter => program_counter_value
    );
    
    

end architecture;
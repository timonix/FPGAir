library ieee;
use ieee.std_logic_1164.all;
use work.common_pkg.all;

entity data_unloader is
    generic(
        frequency_mhz : real := 27.0;
        baud_rate_mhz : real := 115200.0/1000000.0;
        boot_message : String := "unload.";
        delimiter : character := 'D';
        num_bytes : positive := 2

    );
    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        o_ready       : out boolean;
        i_valid       : in boolean;
        i_data        : in std_logic_vector(num_bytes*8-1 downto 0);
        
        o_tx         : out STD_LOGIC

    );
end data_unloader;

architecture rtl of data_unloader is

    constant bits_per_message : POSITIVE := 10;
    constant buffer_size : POSITIVE := maximum(num_bytes+1, boot_message'length)+1;

    signal s_data : STD_LOGIC_VECTOR(buffer_size*bits_per_message-1 downto 0);
    signal s_ready : boolean;

    constant period_time : natural := integer(frequency_mhz/baud_rate_mhz);
    signal period_counter : natural range 0 to period_time + 1;
    signal set_ready : boolean;
    


begin
    
    o_ready <= s_ready;
    
    process(clk)
    begin
        if rising_edge(clk) then
            o_tx <= s_data(0);
            if rst = '1' then
                o_tx <= '1';
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            
            if set_ready and period_counter = 0 then
                s_ready <= true;
            end if;
            
            if (and s_data) = '1' then
                set_ready <= true;
            end if;
            
            if i_valid and s_ready then
                set_ready <= false;
                s_ready <= false;
            end if;
            
            if rst = '1' then
                s_ready <= false;
            end if;
        end if;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            
            if not (period_counter = 0) then
                period_counter <= period_counter - 1;
            end if;
            
            --load data
            if s_ready and i_valid then
                s_data(0+10) <= '0';
                s_data(8+10 downto 1+10) <= TO_STDLOGICVECTOR(delimiter);
                s_data(9+10) <= '1';
                
                for i in 2 to num_bytes+1 loop
                    s_data(i*bits_per_message) <= '0';
                    s_data(i*bits_per_message+8 downto i*bits_per_message+1) <= i_data((i-2)*8+7 downto (i-2)*8);
                    s_data(i*bits_per_message+9) <= '1';
                end loop;
            end if;
            
            
            if period_counter = 0 then
                s_data(buffer_size*bits_per_message-1 downto 0) <= '1' & s_data(buffer_size*bits_per_message-1 downto 1);
                period_counter <= period_time;
            end if;
            
            if rst = '1' then
                s_data <= (others => '1');
                for i in boot_message'range loop
                    s_data(i*bits_per_message) <= '0';
                    s_data(i*bits_per_message+8 downto i*bits_per_message+1) <= TO_STDLOGICVECTOR(boot_message(i));
                    s_data(i*bits_per_message+9) <= '1';
                end loop;
            end if;
            
        end if;

    end process;

end architecture rtl;
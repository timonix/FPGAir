library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_adapter_small is
    generic (
        frequency_mhz : real := 27.0;
        baud_rate_mhz : real := 115200.0/1000000.0;
        num_bytes_in : natural := 2
    );
    port (
        
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in boolean;

        i_data : in STD_LOGIC_VECTOR(num_bytes_in * 8 - 1 downto 0);
        i_valid : in boolean;
        o_ready : out boolean;
        
        m_uart_port_data : out STD_LOGIC_VECTOR(7 downto 0);
        m_uart_port_data_valid : out boolean;
        m_uart_port_ready : in boolean
        
    );
end entity uart_adapter_small;

architecture rtl of uart_adapter_small is
    
    type uart_data_T is record
        data : std_logic_vector(7 downto 0);
        present : boolean;
    end record;
    
    type data_buffer_T is array (0 to num_bytes_in) of uart_data_T;
    
    signal data_buffer : data_buffer_T;
    
    signal s_ready : boolean;
    
    constant c_header : STD_LOGIC_VECTOR(7 downto 0) := x"AA";
    
begin
    
    process(data_buffer)
    begin
        s_ready <= true; -- Initially assume all are false
        for i in 0 to data_buffer'length loop
            if data_buffer(i).present = true then
                s_ready <= false; -- If any boolean is true, set all_false to false
                exit; -- No need to check further
            end if;
        end loop;
    end process;
    
    m_uart_port_data <= data_buffer(0).data;
    m_uart_port_data_valid <= data_buffer(0).present;
    
    o_ready <= s_ready;
    
    
    process (clk)
    begin
        if rising_edge(clk) then
            
            if m_uart_port_ready then
                for i in 0 to num_bytes_in loop
                    data_buffer(i) <= data_buffer(i+1);
                end loop;
                data_buffer(data_buffer'length).present <= false;
                
            end if;
            
            if s_ready and i_valid then
                data_buffer(0).data <= c_header;
                data_buffer(0).present <= true;
                for i in 0 to num_bytes_in loop
                    data_buffer(i+1).data <= i_data(i*8+7 downto i*8);
                    data_buffer(i+1).present <= true;
                end loop;
            end if;
            
            if rst = '1' then
                for i in 0 to num_bytes_in loop
                    data_buffer(i).present <= false;
                end loop;
            end if;
            
        end if;

    end process;

end architecture rtl;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_adapter is
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
end entity uart_adapter;

architecture rtl of uart_adapter is
    
    type state_t is (idle_E, working_E, next_byte_E, dead_end_E);
    signal state : state_t;
    
    signal s_data_in : STD_LOGIC_VECTOR((num_bytes_in+1)*8-1 downto 0);

    signal s_byte_counter : natural range 0 to num_bytes_in + 1;
    
    constant c_header : STD_LOGIC_VECTOR(7 downto 0) := x"AA";
    
    -- Function to shift a std_logic_vector to the right
    function shift_right_vector(signal vec: std_logic_vector; shift_amount: integer) return std_logic_vector is
begin
        -- Assuming vec is an unsigned vector. Use unsigned(vec) for unsigned vectors, or signed(vec) for signed vectors.
    return std_logic_vector(shift_right(unsigned(vec), shift_amount));
end function;

begin
    
    o_ready <= state = idle_E;
    m_uart_port_data <= s_data_in(7 downto 0);
    
    process (clk)
    begin
        if rising_edge(clk) then
            
            m_uart_port_data_valid <= False;

            if state = idle_E and i_valid then
                s_data_in <= i_data & c_header;
                state <= working_E;
            end if;
            
            if state = working_E then
                if m_uart_port_ready then
                    m_uart_port_data_valid <= True;
                    state <= next_byte_E;
                end if;
            end if;

            if state = next_byte_E then
                s_data_in <= shift_right_vector(s_data_in, 8);
                s_byte_counter <= s_byte_counter + 1;
                if s_byte_counter = num_bytes_in + 1 then
                    state <= idle_E;
                    s_byte_counter <= 0;
                else
                    state <= working_E;
                end if;
            end if;
            
            if rst = '1' then
                state <= idle_E;
                s_byte_counter <= 0;
            end if;
            
        end if;

    end process;

end architecture rtl;
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

        data_in : in STD_LOGIC_VECTOR(num_bytes_in * 8 - 1 downto 0);
        data_valid_in : in boolean;
        ready : out boolean;
        
        data_out : out STD_LOGIC_VECTOR(7 downto 0);
        data_valid_out : out boolean;
        uart_ready : in boolean
        
    );
end entity uart_adapter;

architecture rtl of uart_adapter is
    
    type state_t is (idle_E, working_E, next_byte_E, dead_end_E);
    signal state : state_t;
    
    signal s_data_in : STD_LOGIC_VECTOR((num_bytes_in+1)*8-1 downto 0);

    signal s_byte_counter : natural range 0 to num_bytes_in + 1;
    
    constant c_header : STD_LOGIC_VECTOR(7 downto 0) := x"83";
    
    -- Function to shift a std_logic_vector to the right
    function shift_right_vector(signal vec: std_logic_vector; shift_amount: integer) return std_logic_vector is
        begin
        -- Assuming vec is an unsigned vector. Use unsigned(vec) for unsigned vectors, or signed(vec) for signed vectors.
        return std_logic_vector(shift_right(unsigned(vec), shift_amount));
    end function;

begin
    
    ready <= state = idle_E;
    data_out <= s_data_in(7 downto 0);
    
    process (clk)
    begin
        if rising_edge(clk) then
            
            data_valid_out <= False;

            if state = idle_E and data_valid_in then
                s_data_in <= data_in & c_header;
                state <= working_E;
            end if;
            
            if state = working_E then
                if uart_ready then
                    data_valid_out <= True;
                    state <= next_byte_E;
                end if;
            end if;

            if state = next_byte_E then
                s_data_in <= shift_right_vector(s_data_in, 8);
                s_byte_counter <= s_byte_counter + 1;
                if s_byte_counter = num_bytes_in + 1 then
                    state <= dead_end_E;
                    s_byte_counter <= 0;
                else
                    state <= idle_E;
                end if;
            end if;
            
            if rst = '1' then
                state <= idle_E;
                s_byte_counter <= 0;
            end if;
            
        end if;

    end process;

end architecture rtl;
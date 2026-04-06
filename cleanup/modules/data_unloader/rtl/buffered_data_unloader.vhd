library ieee;
use ieee.std_logic_1164.all;
use work.common_pkg.all;


entity buffered_data_unloader is
    generic(
        frequency_mhz : real := 27.0;
        baud_rate : integer := 115200;
        boot_message : String := "unload.";
        num_bytes : positive := 2;
        buffer_size : positive := 32
    );
    port(
        
        clk         : in std_logic;
        rst         : in STD_LOGIC;
        
        o_ready       : out boolean;
        i_valid       : in boolean;
        i_data        : in std_logic_vector(num_bytes*8-1 downto 0);
        
        o_tx         : out STD_LOGIC

    );
end buffered_data_unloader;

architecture rtl of buffered_data_unloader is
    
    -- ===== FIFO storage ===== --
    subtype t_word is std_logic_vector(num_bytes*8-1 downto 0);
    type t_mem is array (0 to buffer_size-1) of t_word;

    signal mem   : t_mem := (others => (others => '0'));
    signal wr_ptr : integer range 0 to buffer_size-1 := 0;
    signal rd_ptr : integer range 0 to buffer_size-1 := 0;
    
    signal q_ready : boolean := true;
    
    constant bits_per_message : POSITIVE := 10; -- Start bit, message, end bit
    constant tx_buffer_num_bytes : POSITIVE := maximum(num_bytes, boot_message'length)+1;
    
    constant C_BUFFER_EMPTY : STD_LOGIC_VECTOR(bits_per_message*tx_buffer_num_bytes-1 downto 0) := (others => '1');
    signal q_tx_buffer : STD_LOGIC_VECTOR(bits_per_message*tx_buffer_num_bytes-1 downto 0) := C_BUFFER_EMPTY;
    signal q_tx_buffer_ready : boolean := false;
    signal s_tx_pulse : std_logic;
    signal q_fifo_has_data : boolean;

begin
    
    -- ticks at 115200 baud
    baud_timer_inst: entity work.baud_timer
    generic map(
        g_frequency_mhz => frequency_mhz,
        g_baud_rate => baud_rate,
        g_counter_precision => 14
    )
    port map(
        clk => clk,
        o_pulse => s_tx_pulse
    );
    
    o_ready <= q_ready;
    
    process(clk)
    begin
        if rising_edge(clk) then
            o_tx <= q_tx_buffer(0);
            if rst = '1' then
                o_tx <= '1';
            end if;
        end if;
    end process;
    
    process (clk)
    variable v_count : integer range 0 to buffer_size := 0;
    begin
        if rising_edge(clk) then
            
            if v_count < buffer_size then
                q_ready <= true;
            end if;
            

            q_fifo_has_data <= v_count > 0;
            
            
            -- loading fifo
            if q_ready and i_valid then
                q_ready <= false;
                v_count := v_count + 1;
                if wr_ptr = buffer_size-1 then wr_ptr <= 0; else wr_ptr <= wr_ptr + 1;  end if;
                mem(wr_ptr) <= i_data;
            end if;
            
            -- loading tx buffer
            if q_tx_buffer_ready and q_fifo_has_data then
                for i in 0 to num_bytes-1 loop
                    q_tx_buffer(i*bits_per_message) <= '0';
                    q_tx_buffer(i*bits_per_message+8 downto i*bits_per_message+1) <= mem(rd_ptr)(i*8+7 downto 0+i*8);
                    q_tx_buffer(i*bits_per_message+9) <= '1';
                end loop;
                
                if rd_ptr = buffer_size-1 then rd_ptr <= 0; else rd_ptr <= rd_ptr + 1; end if;
                
                v_count := v_count - 1;
                q_tx_buffer_ready <= false;
            end if;
            
            if s_tx_pulse = '1' then
                q_tx_buffer(bits_per_message*tx_buffer_num_bytes-1 downto 0) <= '1' & q_tx_buffer(bits_per_message*tx_buffer_num_bytes-1 downto 1);
                if q_tx_buffer = C_BUFFER_EMPTY then
                    q_tx_buffer_ready <= true;
                end if;
            end if;
            
            if rst = '1' then
                -- Boot message
                q_tx_buffer <= C_BUFFER_EMPTY;
                for i in boot_message'range loop
                    q_tx_buffer(i*bits_per_message) <= '0';
                    q_tx_buffer(i*bits_per_message+8 downto i*bits_per_message+1) <= TO_STDLOGICVECTOR(boot_message(i));
                    q_tx_buffer(i*bits_per_message+9) <= '1';
                end loop;
                v_count := 0;
                q_tx_buffer_ready <= false;
            end if;
            
            
            
        end if;
    end process;

    

end architecture;
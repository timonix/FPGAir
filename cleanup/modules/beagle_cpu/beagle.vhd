library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

use work.beagle_pkg.all;

entity beagle is
    generic (
        program_addr_width : integer := 8;
        rom_init           : String  := "beagle_init.rom";
        ram_init           : String  := "beagle_init.ram"
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;
        
        ext_addr     : out unsigned(6 downto 0);
        ext_data_in_valid : in boolean;
        ext_data_in  : in  std_logic_vector(C_BEAGLE_DATA_WIDTH-1 downto 0);
        ext_data_out : out std_logic_vector(C_BEAGLE_DATA_WIDTH-1 downto 0);
        ext_write    : out boolean;
        
        program_counter_valid : in boolean;
        program_counter : in unsigned(program_addr_width-1 downto 0)
        
    );
end entity beagle;

architecture rtl of beagle is
    signal rom : EAGER_ROM_T(0 to 2**program_addr_width-1) := read_eager_rom(rom_init,2**program_addr_width);
    signal ram : EAGER_RAM_T(0 to 2**6-1) := read_eager_ram(ram_init,2**6);
    
    signal A,X,B,RES  : sfixed(C_INTEGER_WIDTH-1 downto -C_FRACTIONAL_WIDTH) := (others => '0');
    signal mov_src  : std_logic_vector(2 downto 0);
    signal mov_dst  : std_logic_vector(1 downto 0);
    signal mov_data : sfixed(C_INTEGER_WIDTH-1 downto -C_FRACTIONAL_WIDTH);
    
    signal PC : unsigned(program_addr_width-1 downto 0) := (others => '0');
    signal current_op : std_logic_vector(7 downto 0);
    
    signal ram_addr     : unsigned(6 downto 0) := (others => '0');
    signal ram_data_in  : sfixed(C_INTEGER_WIDTH-1 downto -C_FRACTIONAL_WIDTH);
    signal ram_data_out : sfixed(C_INTEGER_WIDTH-1 downto -C_FRACTIONAL_WIDTH);
    signal ram_write    : boolean;
    
    signal internal_ram : sfixed(C_INTEGER_WIDTH-1 downto -C_FRACTIONAL_WIDTH);
    signal internal_address : boolean;
    
begin
    
    mov_src <= current_op(4 downto 2);
    mov_dst <= current_op(1 downto 0);
    
    mov_data <= A when mov_src = C_SRC_A else
    B when mov_src = C_SRC_B else
    X when mov_src = C_SRC_X else
    ram_data_in when mov_src = C_SRC_RAM else
    RES when mov_src = C_SRC_RES else
    to_sfixed(1,mov_data) when mov_src = C_SRC_ONE else
    to_sfixed(0,mov_data);
    
    current_op <= rom(to_integer(PC));
    
    internal_address <= ram_addr(6) = '0';
    ext_data_out     <= to_slv(ram_data_out);
    ext_addr         <= ram_addr;
    ext_write        <= ram_write;
    
    ram_data_in  <= to_sfixed(ext_data_in,C_INTEGER_WIDTH-1,-C_FRACTIONAL_WIDTH) when ext_data_in_valid else internal_ram;
    internal_ram <= to_sfixed(ram(to_integer(ram_addr(5 downto 0))),C_INTEGER_WIDTH-1,-C_FRACTIONAL_WIDTH);
    
    process (clk)
    begin
        if rising_edge(clk) then
            if internal_address AND ram_write then
                report to_String(to_std_logic_vector(ram_data_out));
                ram(to_integer(ram_addr(5 downto 0))) <= to_std_logic_vector(ram_data_out);
            end if;
        end if;
    end process;
    
    process (clk)
    begin
        if rising_edge(clk) then
            if program_counter_valid then
                PC <= program_counter;
            elsif current_op /= C_OP_HALT then
                PC <= PC + 1;
            end if;
            if reset = '1' then
                PC       <= (others => '0');
            end if;
        end if;
    end process;
    
    process (clk)
    
    begin
        if rising_edge(clk) then
            if current_op(7) = '1' then
                ram_addr <= unsigned(current_op(6 downto 0));
            end if;
            ram_write <= false;
            if current_op(7 downto 5) = C_OP_MOV then
                if mov_dst = C_DST_A then A <= mov_data; end if;
                if mov_dst = C_DST_B then B <= mov_data; end if;
                if mov_dst = C_DST_X then X <= mov_data; end if;
                if mov_dst = C_DST_RAM then
                    ram_data_out <= mov_data;
                    ram_write <= true;
                end if;
            end if;
            
            if current_op = C_OP_NEG_A then A <= resize(-A, RES'high, RES'low); end if;
            if current_op = C_OP_NEG_B then B <= resize(-B, RES'high, RES'low); end if;
            if current_op = C_OP_MULADD then
                RES <= resize(A*X+B, RES'high, RES'low);
            end if;
        end if;
    end process;

end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common_pkg.all;
use work.eager_pkg.all;

entity eager is
    generic (
        program_addr_width : integer := 8;
        rom_init           : String  := "eager_init.rom";
        ram_init           : String  := "eager_init.ram"
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;
        
        ext_addr     : out unsigned(6 downto 0);
        ext_data_in  : in  signed(C_EAGER_DATA_WIDTH-1 downto 0);
        ext_data_out : out signed(C_EAGER_DATA_WIDTH-1 downto 0);
        ext_write    : out boolean;
        
        program_counter_valid : boolean;
        program_counter : unsigned(program_addr_width-1 downto 0)
        
    );
end entity eager;

architecture rtl of eager is

    signal rom : EAGER_ROM_T(0 to 2**program_addr_width-1) := read_eager_rom(rom_init,2**program_addr_width);
    signal ram : EAGER_RAM_T(0 to 2**6-1) := read_eager_ram(ram_init,2**6);
    
    signal A,X   : signed(C_EAGER_DATA_WIDTH-1 downto 0) := (others => '0');
    signal B,RES : signed(C_EAGER_DATA_WIDTH*2-1 downto 0) := (others => '0');
    
    signal B_H,B_M,B_L       : signed(C_EAGER_DATA_WIDTH-1 downto 0);
    signal RES_H,RES_M,RES_L : signed(C_EAGER_DATA_WIDTH-1 downto 0);
    
    signal B_SOURCE : std_logic_vector(3 downto 0);
    constant C_B_SOURCE_B     : std_logic_vector := "0000";
    constant C_B_SOURCE_NEG   : std_logic_vector := "0001";
    constant C_B_SOURCE_AM    : std_logic_vector := "0010";
    constant C_B_SOURCE_AL    : std_logic_vector := "0011";
    constant C_B_SOURCE_XM    : std_logic_vector := "0100";
    constant C_B_SOURCE_XL    : std_logic_vector := "0101";
    constant C_B_SOURCE_RES   : std_logic_vector := "0110";
    constant C_B_SOURCE_ZERO  : std_logic_vector := "0111";
    constant C_B_SOURCE_RAM_H : std_logic_vector := "1000";
    constant C_B_SOURCE_RAM_M : std_logic_vector := "1001";
    constant C_B_SOURCE_RAM_L : std_logic_vector := "1010";
    
    --A,-A,X ,RES_M,RES_L, B_M,B_L,RAM
    signal A_SOURCE : std_logic_vector(2 downto 0);
    signal X_SOURCE : std_logic_vector(2 downto 0);
    constant C_AX_SOURCE_A     : std_logic_vector := "000";
    constant C_AX_SOURCE_NEG   : std_logic_vector := "001"; -- A only
    constant C_AX_SOURCE_ONE   : std_logic_vector := "001"; -- X only
    constant C_AX_SOURCE_RES_M : std_logic_vector := "010";
    constant C_AX_SOURCE_RES_L : std_logic_vector := "011";
    constant C_AX_SOURCE_BM    : std_logic_vector := "100";
    constant C_AX_SOURCE_BL    : std_logic_vector := "101";
    constant C_AX_SOURCE_RAM   : std_logic_vector := "110";
    constant C_AX_SOURCE_X     : std_logic_vector := "111";
    
    --RAM <= A,X,RES_H,RES_M,RES_L,B_M,B_L,RAM
    signal RAM_SOURCE : std_logic_vector(2 downto 0);
    constant C_RAM_SOURCE_A     : std_logic_vector := "000";
    constant C_RAM_SOURCE_RES_H : std_logic_vector := "001";
    constant C_RAM_SOURCE_RES_M : std_logic_vector := "010";
    constant C_RAM_SOURCE_RES_L : std_logic_vector := "011";
    constant C_RAM_SOURCE_BM    : std_logic_vector := "100";
    constant C_RAM_SOURCE_BL    : std_logic_vector := "101";
    constant C_RAM_SOURCE_RAM   : std_logic_vector := "110";
    constant C_RAM_SOURCE_X     : std_logic_vector := "111";

    signal ram_addr     : unsigned(6 downto 0) := (others => '0');
    signal ram_data_in  : signed(C_EAGER_DATA_WIDTH-1 downto 0);
    signal ram_data_out : signed(C_EAGER_DATA_WIDTH-1 downto 0);
    signal ram_write    : boolean;
    
    signal internal_ram : signed(C_EAGER_DATA_WIDTH-1 downto 0);
    signal internal_address : boolean;
    
    signal PC : unsigned(program_addr_width-1 downto 0) := (others => '0');
    
    signal current_op : std_logic_vector(C_EAGER_ROM_WIDTH-1 downto 0);
    
--    1AAAAAAA # LDMA
    signal is_LDMA_op : boolean;
    signal is_B_OP    : boolean;
    signal is_A_OP    : boolean;
    signal is_X_OP    : boolean;
    signal is_RAM_OP  : boolean;
    
begin
    
    is_LDMA_op <= current_op(7) = '1';
    is_B_OP    <= current_op(7 downto 4) = C_B_OP;
    is_A_OP    <= current_op(7 downto 5) = C_A_OP;
    is_X_OP    <= current_op(7 downto 5) = C_X_OP;
    is_RAM_OP  <= current_op(7 downto 5) = C_RAM_OP;
    
    B_SOURCE <= current_op(3 downto 0);
    
    internal_address <= ram_addr(6) = '0';
    ext_data_out <= ram_data_out;
    ext_addr     <= ram_addr;
    ext_write    <= ram_write;
    
    ram_data_in <= internal_ram when internal_address else ext_data_in;
    internal_ram <= signed(ram(to_integer(ram_addr(5 downto 0))));
    
    process (clk)
    begin
        if rising_edge(clk) then
            if internal_address AND ram_write then
                ram(to_integer(ram_addr(5 downto 0))) <= std_logic_vector(ram_data_out);
            end if;
        end if;
    end process;
    
    
    B_H <= B(C_EAGER_DATA_WIDTH*2-1 downto C_EAGER_DATA_WIDTH);
    B_M <= B(C_EAGER_DATA_WIDTH+C_EAGER_DATA_WIDTH/2-1 downto C_EAGER_DATA_WIDTH/2);
    B_L <= B(C_EAGER_DATA_WIDTH-1 downto 0);
    
    RES_H <= RES(C_EAGER_DATA_WIDTH*2-1 downto C_EAGER_DATA_WIDTH);
    RES_M <= RES(C_EAGER_DATA_WIDTH+C_EAGER_DATA_WIDTH/2-1 downto C_EAGER_DATA_WIDTH/2);
    RES_L <= RES(C_EAGER_DATA_WIDTH-1 downto 0);
    
    current_op <= rom(to_integer(PC));
    
    BREG:process (clk)
    begin
        if rising_edge(clk) then
            if is_B_OP then
                if B_SOURCE = C_B_SOURCE_NEG then B <= -B; end if;
                if B_SOURCE = C_B_SOURCE_RES then B <= RES; end if;
                if B_SOURCE = C_B_SOURCE_AM then
                    B(C_EAGER_DATA_WIDTH*2-1 downto C_EAGER_DATA_WIDTH+C_EAGER_DATA_WIDTH/2) <= (others =>A(C_EAGER_DATA_WIDTH-1));
                    B(C_EAGER_DATA_WIDTH/2-1 downto 0) <= (others => '0');
                    B(C_EAGER_DATA_WIDTH+C_EAGER_DATA_WIDTH/2-1 downto C_EAGER_DATA_WIDTH/2) <= A;
                end if;
                if B_SOURCE = C_B_SOURCE_AL then
                    B <= (others =>A(C_EAGER_DATA_WIDTH-1));
                    B(C_EAGER_DATA_WIDTH-1 downto 0) <= A;
                end if;
                if B_SOURCE = C_B_SOURCE_XM then
                    B(C_EAGER_DATA_WIDTH*2-1 downto C_EAGER_DATA_WIDTH+C_EAGER_DATA_WIDTH/2) <= (others =>X(C_EAGER_DATA_WIDTH-1));
                    B(C_EAGER_DATA_WIDTH/2-1 downto 0) <= (others => '0');
                    B(C_EAGER_DATA_WIDTH+C_EAGER_DATA_WIDTH/2-1 downto C_EAGER_DATA_WIDTH/2) <= X;
                end if;
                if B_SOURCE = C_B_SOURCE_XL then
                    B <= (others =>X(C_EAGER_DATA_WIDTH-1));
                    B(C_EAGER_DATA_WIDTH-1 downto 0) <= X;
                end if;
                if B_SOURCE = C_B_SOURCE_RAM_H then
                    B <= (others =>'0');
                    B(C_EAGER_DATA_WIDTH*2-1 downto C_EAGER_DATA_WIDTH) <= ram_data_in;
                end if;
                if B_SOURCE = C_B_SOURCE_RAM_M then
                    B(C_EAGER_DATA_WIDTH*2-1 downto C_EAGER_DATA_WIDTH+C_EAGER_DATA_WIDTH/2) <= (others =>ram_data_in(C_EAGER_DATA_WIDTH-1));
                    B(C_EAGER_DATA_WIDTH-1 downto 0) <= (others => '0');
                    B(C_EAGER_DATA_WIDTH+C_EAGER_DATA_WIDTH/2-1 downto C_EAGER_DATA_WIDTH/2) <= ram_data_in;
                end if;
                if B_SOURCE = C_B_SOURCE_RAM_L then
                    B <= (others =>ram_data_in(C_EAGER_DATA_WIDTH-1));
                    B(C_EAGER_DATA_WIDTH-1 downto 0) <= ram_data_in;
                end if;
            end if;
            if reset = '1' then
                B <= (others =>'0');
            end if;
        end if;
    end process;

    process (clk)
    variable mov_data : signed(C_EAGER_DATA_WIDTH-1 downto 0);
    begin
        if rising_edge(clk) then
            if program_counter_valid then
                PC <= program_counter;
            elsif current_op /= C_OP_HALT then
                PC <= PC + 1;
            end if;
            
            if is_LDMA_op then
                ram_addr <= unsigned(current_op(6 downto 0));
            end if;
            
            if current_op = C_OP_MULADD then
                RES <= A*X+B;
            end if;
        end if;
        
        if reset = '1' then
            PC       <= (others => '0');
            ram_addr <= (others => '0');
        end if;
        
    end process;



end architecture;
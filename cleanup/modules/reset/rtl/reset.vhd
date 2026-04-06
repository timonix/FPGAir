library ieee;
use ieee.std_logic_1164.all;

entity reset_sync is
    generic (
        RST_ACTIVE_HIGH : boolean := true
    );
    port (
        clk     : in  std_logic;
        rst_in  : in  std_logic;   -- reset input (polarity selectable)
        reset   : out std_logic;   -- synchronous, active-high
        resetn  : out std_logic    -- synchronous, active-low
    );
end entity reset_sync;

architecture rtl of reset_sync is
    signal rst_in_norm : std_logic;
    signal rst_ff1     : std_logic := '1';
    signal rst_ff2     : std_logic := '1';
begin

    -- Normalize reset to active-high internally
    rst_in_norm <= rst_in when RST_ACTIVE_HIGH else not rst_in;

    process(clk)
    begin
        if rising_edge(clk) then
            rst_ff1 <= rst_in_norm;
            rst_ff2 <= rst_ff1;
        end if;
    end process;

    reset  <= rst_ff2;
    resetn <= not rst_ff2;

end architecture rtl;

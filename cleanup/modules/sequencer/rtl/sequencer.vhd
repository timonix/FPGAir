library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common_pkg.all;

entity sequencer is
    generic (
        frequency_mhz : real := 27.0;
        timings_us : integer_array := (0,500,1000,1500);
        cycle_length_us : integer := 2000
    );
    port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;
        enable              : in  boolean;
        outputs             : out BOOLEAN_VECTOR(timings_us'low to timings_us'high)
    );
end sequencer;

architecture rtl of sequencer is
    constant clk_cycles_per_us : integer := integer(frequency_mhz);
    
    signal us_timer : integer range 0 to clk_cycles_per_us := 0;
    signal cycle_timer : integer range 0 to cycle_length_us := 0;
    
begin
    
    process (clk)
    begin
        if rising_edge(clk) then
            outputs <= (others => false);
            if us_timer < clk_cycles_per_us and enable then
                us_timer <= us_timer + 1;
            else -- once per us
                us_timer <= 0;
                
                if cycle_timer < cycle_length_us and enable then
                    cycle_timer <= cycle_timer+1;
                else
                    cycle_timer <= 0;
                end if;
                
                for i in timings_us'range loop
                    if timings_us(i) = cycle_timer then
                        outputs(i) <= true; --high for one clock cycle
                    end if;
                end loop;
                
            end if;
        end if;
    end process;
end architecture;
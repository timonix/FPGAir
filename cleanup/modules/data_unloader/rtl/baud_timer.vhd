library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_timer is
    generic(
        g_frequency_mhz : real := 27.0;
        g_baud_rate     : integer := 115200;
        g_counter_precision : integer := 16
    );
    
    port (
        clk     : in  std_logic;
        o_pulse : out std_logic
    );
end entity baud_timer;

architecture rtl of baud_timer is
    
    type frac_result is record
        num : integer;
        den : integer;
    end record;
    
    function find_params(
        n             : integer := g_baud_rate;
        clk_rate      : integer := integer(g_frequency_mhz * 1000000.0);
        max_threshold : integer := 2**g_counter_precision
    ) return frac_result is

        variable p0 : integer := 0;
        variable q0 : integer := 1;

        variable p1 : integer := 1;
        variable q1 : integer := 0;

        variable p2, q2 : integer;

        variable a : integer;
        variable num : integer := n;
        variable den : integer := clk_rate;
        variable r   : integer;

        variable res : frac_result;

    begin

        while den /= 0 loop

            a := num / den;

            p2 := a * p1 + p0;
            q2 := a * q1 + q0;

            exit when q2 > max_threshold;

            p0 := p1;
            q0 := q1;
            p1 := p2;
            q1 := q2;

            r := num - a * den;

            exit when r = 0;

            num := den;
            den := r;

        end loop;

        res.num := p1;
        res.den := q1;

        report "-----------------baud timer rates---------------------";
        report "clk rate: " & integer'image(clk_rate);
        report "baud rate: " & integer'image(n);
        report "increment: " & integer'image(p1);
        report "threshold: " & integer'image(q1);
        report "------------------------------------------------------";

        return res;

    end function;
    
    constant params : frac_result := find_params;
    signal counter : unsigned(g_counter_precision downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            o_pulse <= '0';
            counter <= counter + params.num;
            if counter + params.num > params.den then
                counter <= counter + params.num - params.den;
                o_pulse <= '1';
            end if;
        end if;
    end process;

end architecture rtl;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity tb_baud_timer is
end entity;

architecture sim of tb_baud_timer is

    -- DUT signals
    signal clk     : std_logic := '0';
    signal o_pulse : std_logic;

    -- Clock period for 27 MHz
    constant C_CLK_PERIOD : time := 37.037037 ns;

begin

    --------------------------------------------------------------------
    -- DUT INSTANTIATION
    --------------------------------------------------------------------
    dut : entity work.baud_timer
    generic map(
        g_frequency_mhz     => 27.0,
        g_baud_rate         => 2.0*115200.0,
        g_counter_precision => 12
    )
    port map(
        clk     => clk,
        o_pulse => o_pulse
    );

    --------------------------------------------------------------------
    -- CLOCK GENERATOR
    --------------------------------------------------------------------
    clk_process : process
    begin
        while now < 15 ms loop
            clk <= '0';
            wait for C_CLK_PERIOD/2;
            clk <= '1';
            wait for C_CLK_PERIOD/2;
        end loop;

        wait;
    end process;

    --------------------------------------------------------------------
    -- MONITOR PROCESS (average rate measurement)
    --------------------------------------------------------------------
    monitor : process
    variable pulse_count : integer := 0;
    variable first_time  : time := 0 ns;
    variable last_time   : time := 0 ns;
    variable avg_period  : time;
    variable avg_rate    : real;
    begin
        wait until rising_edge(clk);

        if o_pulse = '1' then
            pulse_count := pulse_count + 1;

            if pulse_count = 1 then
                first_time := now;
            end if;

            last_time := now;
        end if;

        if now >= 10 ms then

            avg_period := (last_time - first_time) / (pulse_count - 1);
            avg_rate := 1.0e9 / real(avg_period / 1 ns);

            report "--------------------------------------";
            report "Pulse count: " & integer'image(pulse_count);
            report "Average period: " & time'image(avg_period);
            report "Average rate (Hz): " & real'image(avg_rate);
            report "error rate (%): " & real'image(abs(avg_rate-2.0*115200.0)/(2.0*1152.0));
            report "--------------------------------------";
            
            wait;
        end if;
    end process;

end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;

entity tb_pid is
end tb_pid;

architecture tb of tb_pid is

    

signal clk      : std_logic;
signal rst      : std_logic;
signal enable   : boolean;
signal setpoint : sfixed(12 downto -12) := to_sfixed(0.0, 12,-12);
signal input    : sfixed(12 downto -12) := to_sfixed(0.0, 12,-12);
signal output_value : sfixed(12 downto -12);

constant TbPeriod : time := 1000 ns;
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

begin

    pid_inst : entity work.pid(rtl)
    generic map (
        frequency_mhz => 27.0,
        Kp => to_sfixed(1.0, 12,-12),
        Ki => to_sfixed(1.0, 12,-12),
        Kd => to_sfixed(1.0, 12,-12)
    )
    port map (
        clk      => clk,
        rst      => rst,
        enable   => enable,
        setpoint => setpoint,
        input    => input,
        output   => output_value
    );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- Connect main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- Initialization
        enable <= False;
        setpoint <= to_sfixed(500.0, 12,-12);

        -- Reset generation
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Add stimuli here
        wait for 100 ms;
        enable <= False;
        
        wait for 1000 ms;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;




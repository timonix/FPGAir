library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;

entity tb_pid is
end tb_pid;

architecture tb of tb_pid is

    

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal enable   : boolean;
    signal sample   : STD_LOGIC;
    signal setpoint : sfixed(11 downto -11) := to_sfixed(0.0, 11,-11);
    --signal input    : sfixed(12 downto -12) := to_sfixed(0.0, 12,-12);
    signal output_value : sfixed(11 downto -11);
    
    constant TbPeriod : time := 37 ns;
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    pid_inst : entity work.pid(rtl)
    generic map (
        frequency_mhz => 27.0,
        Kp => to_sfixed(0.3, 11,-11),
        Ki => to_sfixed(0.4, 11,-11),
        Kd => to_sfixed(0.0, 11,-11)
    )
    port map (
        clk      => clk,
        rst      => rst,
        enable   => enable,
        sample   => sample,
        setpoint => setpoint,
        input    => output_value,
        output   => output_value
    );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    --output_real <= to_real(output_value);
    
    -- Connect main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- Initialization
        enable <= False;
        setpoint <= to_sfixed(780.0, 11,-11);
        sample <= '0';

        -- Reset generation
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        -- Add stimuli here
        wait for 10 ns;
        enable <= True;
        sample <= '1';
        wait for TbPeriod;
        sample <= '0';
        wait for TbPeriod*10;
        for i in 0 to 3000 loop
            sample <= '1';
            wait for TbPeriod;
            sample <= '0';
            wait for TbPeriod*5;
        end loop;
            
        wait for 10 ns;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
        end process;

    end tb;




library ieee;
use ieee.std_logic_1164.all;


entity tb_mpu6050_redout_new is
end tb_mpu6050_redout_new;

architecture tb of tb_mpu6050_redout_new is

    component mpu6050_redout_new
    port (clk : in std_logic;
        rst : in std_logic;
        sda : inout std_logic;
        scl : inout std_logic;
        tx  : out std_logic;
        debug : out STD_LOGIC    );
end component;

signal clk : std_logic;
signal rst : std_logic;
signal sda : std_logic;
signal scl : std_logic;
signal tx  : std_logic;

constant TbPeriod : time := 37 ns; -- EDIT Put right period here
signal TbClock : std_logic := '0';
signal TbSimEnded : std_logic := '0';

signal rand : integer := 917;

begin
    
    
    sda <= 'H' when rand > 500 else '0';
    scl <= 'H';

    dut : mpu6050_redout_new
    port map (clk => clk,
        rst => rst,
        sda => sda,
        scl => scl,
        tx  => tx,
        debug => open    );

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    process(clk)
    begin
        if rising_edge(clk) then
            rand <= (rand*rand) mod 1000;
        end if;
    end process;

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed

        -- Reset generation
        -- EDIT: Check that rst is really your reset signal
        rst <= '1';
        wait for 1000 ns;
        rst <= '0';
        wait for 100 ns;

        -- EDIT Add stimuli here
        wait for 1000000 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

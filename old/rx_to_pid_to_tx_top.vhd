-----------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.fixed_pkg.all;

entity rx_to_pid_to_tx_top is
    port (
        -- Define the external ports for the uart_system
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        tx : out STD_LOGIC;
        rx : in STD_LOGIC
        -- other ports as required
    );
end entity rx_to_pid_to_tx_top;



architecture Behavioral of rx_to_pid_to_tx_top is
    
    signal data : STD_LOGIC_VECTOR(15 downto 0);
    signal ready : boolean;

    signal s_tx : std_logic;
    
    signal rx_valid : boolean;
    signal rx_data : STD_LOGIC_VECTOR(23 downto 0);
    signal header : STD_LOGIC_VECTOR(7 downto 0);
    signal data_to_pid : sfixed(11 downto -11) := (others => '0');
    signal setpoint : sfixed(11 downto -11) := (others => '0');
    signal pid_data_valid : boolean;
    signal pid_data : sfixed(11 downto -11);
    
    
    subtype result_type is std_logic_vector (22 downto 0);
    
    signal data_to_tx : STD_LOGIC_VECTOR(23 downto 0);

begin
    

    rx_inst: entity work.uart_multi_rx(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0,
        num_bytes => 3
    )
    port map (clk  => clk,
        rst        => rst,
        enable     => true,
        rx         => rx,
        data       => rx_data,
        data_valid => rx_valid);
    
    pid_inst : entity work.pid_meta(rtl)
    generic map (
        frequency_mhz => 27.0,
        Kp => to_sfixed(1.0, 11,-11),
        Ki => to_sfixed(0.0, 11,-11),
        Kd => to_sfixed(0.0, 11,-11)
    )
    port map (
        clk      => clk,
        rst      => rst,
        enable   => true,
        sample   => rx_valid and header = x"55",
        data_valid => pid_data_valid,
        setpoint => setpoint,
        input    => data_to_pid,
        output   => pid_data
    );

    DUT: entity work.data_unloader(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0,
        boot_message  => "FPGAir data unload test:",
        delimiter     => 'D',
        num_bytes     => 3
    )
    port map (
        clk     => clk,
        rst     => rst,
        o_ready => ready,
        i_valid => pid_data_valid,
        i_data  => data_to_tx,
        o_tx    => tx
    );

end Behavioral;
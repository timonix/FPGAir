library ieee;
use ieee.std_logic_1164.all;
use ieee.fixed_pkg.all;

use work.common_pkg.ALL;

entity rx_to_pid_meta_to_tx is
        port (
        -- Define the external ports for the uart_system
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        tx : out STD_LOGIC;
        rx : in STD_LOGIC
        -- other ports as required
    );
end rx_to_pid_meta_to_tx;

architecture rtl of rx_to_pid_meta_to_tx is

    signal update_pid   : boolean;

    signal pid_valid: BOOLEAN;
    signal setpoint : sfixed(10 downto -11) := to_sfixed(-500.0, 10,-11);
    signal pid_output : sfixed(10 downto -11);
    signal pid_input : sfixed(10 downto -11):= to_sfixed(0.0, 10,-11);
    
    signal rx_valid: boolean;
    signal rx_data : std_logic_vector(15 downto 0);

begin
    pid_input(-6 downto -11) <= (others => '0');
    pid_input(10 downto -5) <= sfixed(rx_data(15 downto 0));
    
    update_pid <= rx_valid;
    
    rx_inst: entity work.uart_multi_rx(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0,
        num_bytes => 2
    )
    port map (clk  => clk,
        rst        => rst,
        enable     => true,
        rx         => rx,
        data       => rx_data,
        data_valid => rx_valid);
    

    pid_inst : entity work.pid_meta(rtl)
    generic map (
        integer_bits => 11,
        fractional_bits => 11,
        Kp => 0.005,
        Ki => 0.001,
        Kd => 0.002
    )
    port map (
        clk  => clk,
        rst => rst,
        enable => true,
        update => update_pid,
        
        data_valid => pid_valid,
        
        A_setpoint => (others => '0'),
        A_measured => (others => '0'),
        A_output =>open,--output_value,
        
        B_setpoint =>setpoint,
        B_measured =>pid_input,
        B_output   =>pid_output
    );
    
    DUT: entity work.data_unloader(rtl)
    generic map (
        frequency_mhz => 27.0,
        baud_rate_mhz => 115200.0/1000000.0,
        boot_message  => "FPGAir data unload test:",
        delimiter     => 'D',
        num_bytes     => 2
    )
    port map (
        clk     => clk,
        rst     => rst,
        o_ready => open,
        i_valid => pid_valid,
        i_data  => std_logic_vector(pid_output(10 downto -5)),
        o_tx    => tx
    );



    end rtl;




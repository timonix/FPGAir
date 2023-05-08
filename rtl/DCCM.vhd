library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Drone Core Control Module

entity DCCM is
    generic (
        frequency_mhz : real := 27.0;
        number_of_channels : POSITIVE := 6;
        number_of_motors : POSITIVE := 4;
        number_of_PID_controllers : POSITIVE := 3
    );
    port(
        -- [I/Os]
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable_radio_channels : out STD_LOGIC_VECTOR(number_of_channels downto 0);
        enable_pwm_controllers : out STD_LOGIC_VECTOR(number_of_motors downto 0);
        enable_PID_controllers : out STD_LOGIC_VECTOR(number_of_PID_controllers downto 0)
        
        
    );
end entity DCCM;

architecture rtl of DCCM is
    
    -- [signals]
    
    type t_state is (
            Init_E,
            Debug_E
        );
        
    signal state : t_state;
        
    begin
        process(clk)
        begin
            if rising_edge(clk) then
                

                if state = Init_E then
                    
                    enable_pwm_controllers <= (others => '0');
                    enable_PID_controllers <= (others => '0');
                    enable_radio_channels <= (others => '1');

                end if;
                



                if rst = '1' then
                    state <= Init_E;
                end if;
                
            end if;
        end process;
    end architecture rtl;


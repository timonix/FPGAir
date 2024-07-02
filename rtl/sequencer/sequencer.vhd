library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sequencer is
    generic (
        frequency_mhz : real := 27.0
    );
    port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;
        enable              : in  boolean;
        update_pid          : out boolean;
        update_mpu          : out boolean;
        send_pulse          : out boolean;
        calculate_attitude  : out boolean
    );
end sequencer;

architecture Behavioral of sequencer is
    
    constant micro_second : real := 1.0;
    constant clock_divisor : positive := positive(frequency_mhz / micro_second);
    signal clock_divider_counter : integer range 0 to clock_divisor := 0;
    signal clock : STD_LOGIC := '0';
    
    signal counter : unsigned(10 downto 0) := (others => '0');
begin
    
    clock_proc : process (clk)
    begin
        if rising_edge(clk) then
            clock_divider_counter <= clock_divider_counter + 1;
            clock <= '0';
            if clock_divider_counter = clock_divisor - 1 then
                clock_divider_counter <= 0;
                clock <= '1';
            end if;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if enable then
                if clock = '1' then
                    if counter < 2000 then
                        counter <= counter + 1;
                        
                        update_pid <= FALSE;
                        update_mpu <= FALSE;
                        send_pulse <= FALSE;
                        calculate_attitude <= FALSE;
                        
                        if counter = 0 or counter = 500 or counter = 1000 or counter = 1500 then
                            update_mpu <= TRUE;
                        end if;
                        
                        if counter = 50 then
                            calculate_attitude <= TRUE;
                        end if;
                        
                        if counter = 100 then
                            update_pid <= TRUE;
                        end if;
                        
                        if counter = 101 then
                            send_pulse <= TRUE;
                        end if;
                        
                    else
                        counter <= (others => '0');
                    end if;
                end if;
            end if;

            if rst = '1' then
                counter <= (others => '0');
                update_pid <= FALSE;
                update_mpu <= FALSE;
                send_pulse <= FALSE;
            end if;
        end if;
    end process;

end Behavioral;

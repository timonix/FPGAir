library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sequencer is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        enable     : in  std_logic;
        update_pid : out std_logic;
        update_mpu : out std_logic;
        send_pulse : out std_logic
    );
end sequencer;

architecture Behavioral of sequencer is
    signal counter : unsigned(10 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                if counter < 2000 then
                    counter <= counter + 1;

                    update_pid <= '0';
                    update_mpu <= '0';
                    send_pulse <= '0';
                    
                    if counter = 0 or counter = 500 or counter = 1000 or counter = 1500 then
                        update_mpu <= '1';
                    end if;
                    
                    if counter = 1999 then
                        update_pid <= '1';
                    end if;
                    
                    if counter = 1999 then
                        send_pulse <= '1';
                    end if;
                    
                else
                    counter <= (others => '0');
                end if;
            end if;

            if rst = '1' then
                counter <= (others => '0');
                update_pid <= '0';
                update_mpu <= '0';
                send_pulse <= '0';
            end if;
        end if;
    end process;

end Behavioral;

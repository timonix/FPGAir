library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- CALIBRATES A SINGLE MOTOR USING BUTTON

entity top_bruse is
    port (
        clk : in std_logic;
        rst : in std_logic;
        pulse_out : out std_logic;
        led_out : out std_logic;
        start_btn : in std_logic
    );
end entity top_bruse;

architecture Behavioral of top_bruse is
    signal pulse_len_us : UNSIGNED(10 downto 0);
    signal input_valid : boolean := false;
    signal button_pressed : boolean := false;
    
    constant clock_divisor : positive := positive(27.0 / 0.0004);
    signal clock_divider_counter : natural range 0 to clock_divisor + 1 := 0;
    signal meta_clock : STD_LOGIC := '0';

    signal diiiv : std_logic_vector(29 downto 0) := "000000000100000000000000000000";

    
    
begin
    pulser_inst : entity work.pulser
    generic map (
        frequency_mhz => 27.0  -- Adjust the frequency according to your clock
    )
    port map (
        clk => clk,
        input_valid => input_valid,
        pulse_len_us => pulse_len_us,
        pulser_ready => open,
        output => pulse_out
    );

    process (clk)
    begin
        if rising_edge(clk) then
            meta_clock <= '0';
            input_valid <= false;
            if clock_divider_counter = 0 then
                meta_clock <= '1';
                diiiv(29 downto 1) <= diiiv(28 downto 0);
                diiiv(0) <= diiiv(29);
                input_valid <= true;
                clock_divider_counter <= clock_divisor;
            else
                clock_divider_counter <= clock_divider_counter - 1;
            end if;
        end if;
    end process;

    
    process (clk)
    begin
        if rising_edge(clk) then
            if start_btn = '0' then
                button_pressed <= true;
                led_out <= '0';
            end if;
            
            if button_pressed then
                if meta_clock = '1' and pulse_len_us < 1600 and diiiv(0) = '1' then
                    pulse_len_us <= pulse_len_us + 1;
                end if;
            end if;
            
            if rst = '0' then
                pulse_len_us <= to_unsigned(1000, 11);
                button_pressed <= false;
                led_out <= '1';
            end if;
        end if;
    end process;
    
end architecture Behavioral;
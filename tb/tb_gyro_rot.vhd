library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.fixed_pkg.all;

entity tb_gyro_rot is
end tb_gyro_rot;

architecture sim of tb_gyro_rot is
    signal clk              : STD_LOGIC := '0';
    signal rstn             : STD_LOGIC := '0';
    signal update           : boolean := false;
    signal done             : boolean;
    signal gyro_raw_X_in    : SFIXED(0 downto -16);
    signal gyro_raw_Y_in    : SFIXED(0 downto -16);
    signal gyro_raw_Z_in    : SFIXED(0 downto -16);
    signal angle_x          : SFIXED(0 downto -16) := to_sfixed(0.5,0,-16);
    signal angle_y          : SFIXED(0 downto -16) := to_sfixed(0.3,0,-16);
    signal gyro_offset_X    : SFIXED(0 downto -16) := to_sfixed(0.05,0,-16);
    signal gyro_offset_Y    : SFIXED(0 downto -16) := to_sfixed(0.05,0,-16);
    signal gyro_offset_Z    : SFIXED(0 downto -16) := to_sfixed(0.05,0,-16);
    signal c_X_scale        : SFIXED(8 downto -8) := to_sfixed(1.05,8,-8);
    signal c_Y_scale        : SFIXED(8 downto -8) := to_sfixed(1.05,8,-8);
    signal c_transfer_const : SFIXED(8 downto -8) := to_sfixed(1.05,8,-8);
    signal gyro_angle_X_out : SFIXED(0 downto -16);
    signal gyro_angle_Y_out : SFIXED(0 downto -16);
    
    constant TbPeriod : time := 37 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin
    UUT: entity work.gyro_rot
    port map (
        clk => clk,
        rstn => rstn,
        update => update,
        done => done,
        gyro_raw_X_in => gyro_raw_X_in,
        gyro_raw_Y_in => gyro_raw_Y_in,
        gyro_raw_Z_in => gyro_raw_Z_in,
        angle_x => angle_x,
        angle_y => angle_y,
        gyro_offset_X => gyro_offset_X,
        gyro_offset_Y => gyro_offset_Y,
        gyro_offset_Z => gyro_offset_Z,
        c_X_scale => c_X_scale,
        c_Y_scale => c_Y_scale,
        c_transfer_const => c_transfer_const,
        gyro_angle_X_out => gyro_angle_X_out,
        gyro_angle_Y_out => gyro_angle_Y_out
    );

    clk <= not clk after TbPeriod / 2 when not TbSimEnded else '0';

    stim_process: process
    begin
        wait for 10 ns;
        rstn <= '1';
        wait for 20 ns;

        -- Simulated gyro values
        gyro_raw_X_in <= to_sfixed(0.1,0,-16);
        gyro_raw_Y_in <= to_sfixed(0.2,0,-16);
        gyro_raw_Z_in <= to_sfixed(0.3,0,-16);

        update <= true;

        wait until done = true;
        wait for 30 ns;
        
        TbSimEnded <= '1';

        wait;
    end process;

end sim;








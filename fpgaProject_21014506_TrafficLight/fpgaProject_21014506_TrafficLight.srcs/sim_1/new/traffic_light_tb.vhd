library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.ALL;

entity traffic_light_tb is
end traffic_light_tb;

architecture Behavioral of traffic_light_tb is

    component traffic_light_top
        generic (
            G_GREEN_DURATION  : unsigned(3 downto 0) := "0101";  -- Default: 5
            G_YELLOW_DURATION : unsigned(3 downto 0) := "0010";  -- Default: 2
            G_RED_DURATION    : unsigned(3 downto 0) := "0110"   -- Default: 6
        );
        Port (
            CLK100MHZ   : in  std_logic;
            CPU_RESETN  : in  std_logic;
            BTNC        : in  std_logic;
            LED_R       : out std_logic;
            LED_Y       : out std_logic;
            LED_G       : out std_logic
        );
    end component;

    signal CLK100MHZ_tb   : std_logic := '0';
    signal CPU_RESETN_tb  : std_logic := '0';
    signal BTNC_tb        : std_logic := '0';
    signal LED_R_tb       : std_logic;
    signal LED_Y_tb       : std_logic;
    signal LED_G_tb       : std_logic;

begin

    UUT: traffic_light_top
        generic map (
            G_GREEN_DURATION  => "0101",  -- 5 cycles
            G_YELLOW_DURATION => "0010",  -- 2 cycles
            G_RED_DURATION    => "0110"   -- 6 cycles
        )
        Port map (
            CLK100MHZ  => CLK100MHZ_tb,
            CPU_RESETN => CPU_RESETN_tb,
            BTNC       => BTNC_tb,
            LED_R      => LED_R_tb,
            LED_Y      => LED_Y_tb,
            LED_G      => LED_G_tb
        );

    clock_process: process
    begin
        CLK100MHZ_tb <= '0';
        wait for 5 ns;
        CLK100MHZ_tb <= '1';
        wait for 5 ns;
    end process clock_process;

    reset_process: process
    begin
        CPU_RESETN_tb <= '0';
        wait for 20 ns;
        CPU_RESETN_tb <= '1';
        wait;
    end process reset_process;

    -- Read BTNC from input_vectors.txt
    input_process: process
        file input_file    : text open read_mode is "/home/acg/Desktop/Xilinx Projects/fpgaProject_21014506_TrafficLight/fpgaProject_21014506_TrafficLight.srcs/sim_1/new/input_vectors.txt";
        variable line_buffer : line;
        variable btnc_value  : integer;
    begin
        wait until CPU_RESETN_tb = '1';
        wait for 10 ns;

        while not endfile(input_file) loop
            readline(input_file, line_buffer);
            read(line_buffer, btnc_value);

            if (btnc_value = 1) then
                BTNC_tb <= '1';
            else
                BTNC_tb <= '0';
            end if;

            wait for 1 us; 
        end loop;

        BTNC_tb <= '0';
        wait for 10 us;

        assert false report "Simulation Finished Successfully." severity failure;
    end process input_process;

    monitor_process: process(CLK100MHZ_tb)
    begin
        if rising_edge(CLK100MHZ_tb) then
            report "Time: " & time'image(now) & 
                   " | LED_R: " & std_logic'image(LED_R_tb) & 
                   " | LED_Y: " & std_logic'image(LED_Y_tb) & 
                   " | LED_G: " & std_logic'image(LED_G_tb);
        end if;
    end process monitor_process;

end Behavioral;
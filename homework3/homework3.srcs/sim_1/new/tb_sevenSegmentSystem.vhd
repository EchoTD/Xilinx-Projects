library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_seven_seg_fsm is
end tb_seven_seg_fsm;

architecture testbench of tb_seven_seg_fsm is
    signal CLK100MHZ  : STD_LOGIC := '0';
    signal BTNC       : STD_LOGIC := '0';
    signal CPU_RESETN : STD_LOGIC := '1';
    signal CA, CB, CC, CD, CE, CF, CG, DP : STD_LOGIC;
    signal AN         : STD_LOGIC_VECTOR(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;  -- 100 MHz
begin
    DUT: entity work.seven_seg_fsm(RTL)
        port map(
            CLK100MHZ  => CLK100MHZ,
            BTNC       => BTNC,
            CPU_RESETN => CPU_RESETN,
            CA         => CA,
            CB         => CB,
            CC         => CC,
            CD         => CD,
            CE         => CE,
            CF         => CF,
            CG         => CG,
            DP         => DP,
            AN         => AN
        );

    -- Clock generation
    clk_process: process
    begin
        CLK100MHZ <= '0';
        wait for CLK_PERIOD/2;
        CLK100MHZ <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stimulus: process
    begin
        -- Wait initial few ms to see normal operation
        wait for 3 ms;

        -- Press CPU_RESETN (active low) for ~2 ms
        CPU_RESETN <= '0';
        wait for 2 ms;
        CPU_RESETN <= '1';
        wait for 3 ms;

        -- Press BTNC (make it '1' to return to sA)
        BTNC <= '1';
        wait for 2 ms;
        BTNC <= '0';
        wait for 3 ms;

        -- End simulation
        wait;
    end process;
end testbench;
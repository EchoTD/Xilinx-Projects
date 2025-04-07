library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_tb is
-- Testbench has no ports
end main_tb;

architecture Behavioral of main_tb is

    -- Component declaration of the Unit Under Test (UUT)
    component main
        Port (
            clk_IN  : in  STD_LOGIC;
            reset   : in  STD_LOGIC;
            -- Button input
            BTNC    : in  STD_LOGIC;
            -- 7-segment outputs
            CA, CB, CC, CD, CE, CF, CG : out STD_LOGIC;
            -- Anode control
            AN      : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Signals to connect to UUT
    signal clk_IN_tb  : STD_LOGIC := '0';
    signal reset_tb   : STD_LOGIC := '1';
    signal BTNC_tb    : STD_LOGIC := '1';
    signal CA_tb, CB_tb, CC_tb, CD_tb, CE_tb, CF_tb, CG_tb : STD_LOGIC;
    signal AN_tb      : STD_LOGIC_VECTOR(7 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: main
        Port map (
            clk_IN  => clk_IN_tb,
            reset   => reset_tb,
            BTNC    => BTNC_tb,
            CA      => CA_tb,
            CB      => CB_tb,
            CC      => CC_tb,
            CD      => CD_tb,
            CE      => CE_tb,
            CF      => CF_tb,
            CG      => CG_tb,
            AN      => AN_tb
        );

    -- Clock generation
    clk_process :process
    begin
        clk_IN_tb <= '0';
        wait for clk_period/2;
        clk_IN_tb <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stimulus_process: process
    begin
        reset_tb <= '1';
        wait for 10 ns;
        reset_tb <= '0';

        wait for 100 ns;

        for i in 0 to 11 loop
            BTNC_tb <= '0';
            wait for 20 ns;
            BTNC_tb <= '1';
            wait for 100 ns;
        end loop;

        wait for 100 ns;
    end process;

end Behavioral;
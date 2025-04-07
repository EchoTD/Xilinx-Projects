library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parkingGate_tb is
end parkingGate_tb;

architecture behavior of parkingGate_tb is

    component parkingGate
        Port(
            i_CLK        : in  STD_LOGIC;
            i_RESET      : in  STD_LOGIC;
            i_coinInsert : in  STD_LOGIC;
            r_N          : in  STD_LOGIC; -- 25 kuruş
            r_B          : in  STD_LOGIC; -- 10 kuruş
            r_A          : in  STD_LOGIC; -- 5 kuruş
            o_D          : out STD_LOGIC
        );
    end component;

    signal i_CLK        : STD_LOGIC := '0';
    signal i_RESET      : STD_LOGIC := '1';
    signal i_coinInsert : STD_LOGIC := '0';
    signal r_N          : STD_LOGIC := '0';
    signal r_B          : STD_LOGIC := '0';
    signal r_A          : STD_LOGIC := '0';
    signal o_D          : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: parkingGate Port Map (
        i_CLK        => i_CLK,
        i_RESET      => i_RESET,
        i_coinInsert => i_coinInsert,
        r_N          => r_N,
        r_B          => r_B,
        r_A          => r_A,
        o_D          => o_D
    );

    clk_process :process
    begin
        while now < 1000 ns loop
            i_CLK <= '0';
            wait for CLK_PERIOD/2;
            i_CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    stim_proc: process
    begin
    
        wait for 20 ns;
        i_RESET <= '0';
        wait for CLK_PERIOD * 2;
        
        --| Test Cases |--
        -- Test Case #1: 25+10
        -- add 25 kurus
        i_coinInsert <= '1';
        r_N <= '1';
        wait for CLK_PERIOD;
        i_coinInsert <= '0';
        r_N <= '0';
        wait for CLK_PERIOD * 2;

        -- add 10 kurus
        i_coinInsert <= '1';
        r_B <= '1';
        wait for CLK_PERIOD;
        i_coinInsert <= '0';
        r_B <= '0';
        wait for CLK_PERIOD * 2;
        
        -- reset
        i_RESET <= '1';
        wait for CLK_PERIOD * 2;
        i_RESET <= '0';
        wait for CLK_PERIOD * 2;
        
        -- Test Case #2: 3*10
        i_coinInsert <= '1';
        r_B <= '1';
        wait for CLK_PERIOD;
        i_coinInsert <= '0';
        r_B <= '0';
        wait for CLK_PERIOD * 2;
        i_coinInsert <= '1';
        r_B <= '1';
        wait for CLK_PERIOD;
        i_coinInsert <= '0';
        r_B <= '0';
        wait for CLK_PERIOD * 2;
        i_coinInsert <= '1';
        r_B <= '1';
        wait for CLK_PERIOD;
        i_coinInsert <= '0';
        r_B <= '0';
        wait for CLK_PERIOD * 2;
        
        -- reset
        i_RESET <= '1';
        wait for CLK_PERIOD * 2;
        i_RESET <= '0';
        wait for CLK_PERIOD * 2;
        
        -- Test Case #3: 6*5 kurus
        i_coinInsert <= '1';
        r_A <= '1';
        wait for CLK_PERIOD;
        i_coinInsert <= '0';
        r_A <= '0';
        wait for CLK_PERIOD * 2;
        i_coinInsert <= '1';
        r_A <= '1';
        wait for CLK_PERIOD;
        i_coinInsert <= '0';
        r_A <= '0';
        wait for CLK_PERIOD * 2;
        i_coinInsert <= '1';
        r_A <= '1';
        wait for CLK_PERIOD;
        i_coinInsert <= '0';
        r_A <= '0';
        wait for CLK_PERIOD * 2;
        i_coinInsert <= '1';
        r_A <= '1';
        wait for CLK_PERIOD;
        i_coinInsert <= '0';
        r_A <= '0';
        wait for CLK_PERIOD * 2;
        i_coinInsert <= '1';
        r_A <= '1';
        wait for CLK_PERIOD;
        i_coinInsert <= '0';
        r_A <= '0';
        wait for CLK_PERIOD * 2;
        i_coinInsert <= '1';
        r_A <= '1';
        wait for CLK_PERIOD;
        i_coinInsert <= '0';
        r_A <= '0';
        wait for CLK_PERIOD * 2;

        wait for 100 ns;
        wait;
    end process;

end behavior;

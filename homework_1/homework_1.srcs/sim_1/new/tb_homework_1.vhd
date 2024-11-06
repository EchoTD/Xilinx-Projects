library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity eightBitAdder_tb is

end eightBitAdder_tb;

architecture Behavioral of eightBitAdder_tb is
    component eightBitAdder
        Port(   
        A : in STD_LOGIC_VECTOR(7 downto 0);
        B : in STD_LOGIC_VECTOR(7 downto 0);
        SUM  : out STD_LOGIC_VECTOR(7 downto 0);
        OVERFLOW: out STD_LOGIC);
    end component;
    
    signal A_test: STD_LOGIC_VECTOR(7 downto 0);
    signal B_test: STD_LOGIC_VECTOR(7 downto 0);
    signal SUM_test: STD_LOGIC_VECTOR(7 downto 0);
    signal OVERFLOW_test: STD_LOGIC;
    
begin

    UUT: eightBitAdder
        Port map(
            A => A_test,
            B => B_test,
            SUM => SUM_test,
            OVERFLOW => OVERFLOW_test);
    process
    begin
        A_test <= "00000111"; -- 7 complement: 11111000 + '1' = 11111001
        B_test <= "00001000"; -- 8 complement: 11111000 + '1' = 11111000
        wait for 100 ns;
        
        A_test <= "11111001"; -- 7 complement: 11111000 + '1' = 11111001 -> -7
        B_test <= "11111000"; -- 8 complement: 00001000 + '1' = 11111000 -> -8
        wait for 100 ns;
        
        A_test <= "01111111"; -- 127 
        B_test <= "00011011"; -- 27 complement: 11100100 + '1' = 11100101 -> -27
        wait for 100 ns;
        wait;
    end process;
end Behavioral;

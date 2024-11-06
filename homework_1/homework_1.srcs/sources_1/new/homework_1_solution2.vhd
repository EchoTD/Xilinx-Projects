library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Defining one full adder in order to use it to create a 8 bit adder
entity fullAdder is
    Port(   
        A    : in STD_LOGIC;
        B    : in STD_LOGIC;
        C_in : in STD_LOGIC;
        SUM  : out STD_LOGIC;
        C_out: out STD_LOGIC);
end fullAdder;

architecture Behavioral of fullAdder is
begin
    SUM <= A XOR B XOR C_in;
    C_out <= (A AND B) OR ((A XOR B) AND C_in);
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity eightBitAdder is
    Port(   
        A : in STD_LOGIC_VECTOR(7 downto 0);
        B : in STD_LOGIC_VECTOR(7 downto 0);
        SUM  : out STD_LOGIC_VECTOR(7 downto 0);
        OVERFLOW: out STD_LOGIC);
end eightBitAdder;

architecture Behavioral of eightBitAdder is
    component fullAdder
        Port(
            A : in STD_LOGIC;
            B : in STD_LOGIC;
            C_in : in STD_LOGIC;
            C_out: out STD_LOGIC;
            SUM  : out STD_LOGIC);
     end component;
     
     signal carry: STD_LOGIC_VECTOR(8 downto 0);
begin
    carry(0) <= '0';
    
    A0: fullAdder port map(A(0), B(0), carry(0), SUM(0), carry(1));
    A1: fullAdder port map(A(1), B(1), carry(1), SUM(1), carry(2));
    A2: fullAdder port map(A(2), B(2), carry(2), SUM(2), carry(3));
    A3: fullAdder port map(A(3), B(3), carry(3), SUM(3), carry(4));
    A4: fullAdder port map(A(4), B(4), carry(4), SUM(4), carry(5));
    A5: fullAdder port map(A(5), B(5), carry(5), SUM(5), carry(6));
    A6: fullAdder port map(A(6), B(6), carry(6), SUM(6), carry(7));
    A7: fullAdder port map(A(7), B(7), carry(7), SUM(7), carry(8));
    
    OVERFLOW <= carry(8) XOR carry(7);
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 1-Bit Full Adder
entity fullAdder is
    Port(   
        A    : in STD_LOGIC;
        B    : in STD_LOGIC;
        C_in : in STD_LOGIC;
        SUM  : out STD_LOGIC;
        C_out: out STD_LOGIC
        );
end fullAdder;

architecture Behavioral of fullAdder is
begin
    SUM <= (A XOR B) XOR C_in;
    C_out <= (A AND B) OR ((A XOR B) AND C_in);
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity eightBitAdder is
    Port(   
        A : in STD_LOGIC_VECTOR(7 downto 0);
        B : in STD_LOGIC_VECTOR(7 downto 0);
        C_in : in STD_LOGIC;
        SUM  : out STD_LOGIC_VECTOR(7 downto 0);
        C_out: out STD_LOGIC
        );
end eightBitAdder;

architecture Behavioral of eightBitAdder is
    component fullAdder is
        Port(   
        A    : in STD_LOGIC;
        B    : in STD_LOGIC;
        C_in : in STD_LOGIC;
        SUM  : out STD_LOGIC;
        C_out: out STD_LOGIC
        );
    end component;
    
    signal OVERFLOW : STD_LOGIC_VECTOR (8 downto 0) := (others => '0');

begin
    OVERFLOW(0) <= C_in;
    C_out <= OVERFLOW(8);
    
    eightBitAdderGenerator: for i in 0 to 7 generate
        fulladder_i : fullAdder
        Port map(
                A => A(i),
                B => B(i),
                C_in => OVERFLOW(i),
                SUM => SUM(i),
                C_out => OVERFLOW(i + 1)
                );
    end generate;
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity full_adder_4bit is
    --Port ( );
end full_adder_4bit;

architecture Behavioral of full_adder_4bit is

begin

    stage 0: fulladder port map(C_in, X0, Y0, S0, C1);
    stage 1: fulladder port map(C1,   X1, Y1, S1, C2);
    stage 2: fulladder port map(C2,   X2, Y2, S2, C3);
    stage 1: fulladder port map(C3,   X3, Y3, S4, C_out);


end Behavioral;

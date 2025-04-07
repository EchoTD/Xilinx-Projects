library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity week6 is
    Port ( 
        x1: in STD_LOGIC;
        x2: in STD_LOGIC;
        xOut: out STD_LOGIC
        );
end week6;

architecture Behavioral of week6 is
    
begin
    xOut <= x1 AND x2;

end Behavioral;
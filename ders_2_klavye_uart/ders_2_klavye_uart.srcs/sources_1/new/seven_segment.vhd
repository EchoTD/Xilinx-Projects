library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_segment is
    port (
        clk          : in std_logic;                     
        scan_code    : in std_logic_vector(7 downto 0);  
        seg_out      : out std_logic_vector(6 downto 0); 
        an           : out std_logic_vector(7 downto 0)  
    );
end seven_segment;

architecture Behavioral of seven_segment is
    signal digit : std_logic_vector(6 downto 0);
begin
    process(scan_code)
    begin
        case scan_code is
            when x"45" => digit <= "1000000"; -- 0
            when x"16" => digit <= "1111001"; -- 1
            when x"1E" => digit <= "0100100"; -- 2
            when x"26" => digit <= "0110000"; -- 3
            when x"25" => digit <= "0011001"; -- 4
            when x"2E" => digit <= "0010010"; -- 5
            when x"36" => digit <= "0000010"; -- 6
            when x"3D" => digit <= "1111000"; -- 7
            when x"3E" => digit <= "0000000"; -- 8
            when x"46" => digit <= "0010000"; -- 9

            when x"1C" => digit <= "0001000"; -- A
            when x"32" => digit <= "0000011"; -- B
            when x"21" => digit <= "1000110"; -- C
            when x"23" => digit <= "0100001"; -- D
            when x"24" => digit <= "0000110"; -- E
            when x"2B" => digit <= "0001110"; -- F

            when others => digit <= "1111111"; -- Blank
        end case;
    end process;

    seg_out <= digit;

    an <= "11111110";
end Behavioral;
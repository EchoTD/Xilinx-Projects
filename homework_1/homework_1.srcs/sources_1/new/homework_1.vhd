----------------------------------------------------------------------------------
-- Company: Yıldız Teknik Üniversitesi
-- Engineer: Alaaddin Can Gürsoy
-- 
-- Create Date: 11/05/2024 07:01:11 PM
-- Design Name: 
-- Module Name: homework_1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- needed for signed function

-- A, B -> 8 bit inputs, SUM -> output from the adders

entity homework_1 is
    Port (  A, B : in STD_LOGIC_VECTOR(7 downto 0);
            C_in : in STD_LOGIC;
            SUM : out STD_LOGIC_VECTOR(7 downto 0);
            C_out : out STD_LOGIC);
end homework_1;

architecture Behavioral of homework_1 is
    signal  extendedSUM : signed(8 downto 0); -- extended sum signal with 9 bits in account of overflow
begin
    extendedSUM <= signed('0' & A) + signed('0' & B);  -- need to add a 0 bit to the MSB in order to make the design work (mismatch)
    SUM <= std_logic_vector(extendedSUM(7 downto 0));
    C_out <= extendedSUM(8) xor extendedSUM(7);

end Behavioral;

----------------------------------------------------------------------------------
-- Company: yettu
-- Engineer: acg
-- 
-- Create Date: 10/23/2024 11:06:51 AM
-- Design Name: 
-- Module Name: logic_ex - Behavioral
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

entity logic_ex is
    Port (  SW : in STD_LOGIC_VECTOR(1 downto 0);
            LED: out STD_LOGIC_VECTOR(3 downto 0));
end logic_ex;

architecture Behavioral of logic_ex is

begin
    
LED(0) <= NOT SW(0);
LED(1) <= SW(0) AND SW(1);
LED(2) <= SW(0) OR SW(1);
LED(3) <= SW(0) XOR SW(1);

end Behavioral;
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/23/2024 11:09:21 AM
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
    Port ( SW : in STD_LOGIC;
           LED : out STD_LOGIC);
end logic_ex;

architecture Behavioral of logic_ex is

begin
LED <= not SW;


end Behavioral;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/30/2024 10:55:50 AM
-- Design Name: 
-- Module Name: tb_logic_ex2 - Behavioral
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
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity logic_ex_tb is
end;

architecture bench of logic_ex_tb is

  component logic_ex
      Port (  SW : in STD_LOGIC_VECTOR(1 downto 0);
              LED: out STD_LOGIC_VECTOR(3 downto 0));
  end component;

  signal SW: STD_LOGIC_VECTOR(1 downto 0);
  signal LED: STD_LOGIC_VECTOR(3 downto 0);

begin

  uut: logic_ex port map ( SW  => SW,
                           LED => LED );

  stimulus: process
  begin
  
    for i in 0 to 3 loop
        SW <= STD_LOGIC_VECTOR(to_unsigned(i, SW'length));
        report "Setting SW to " & to_string(to_unsigned(i, SW'length));
        wait for 100ns;
    end loop;
  
--    SW <= "00" after 20ns, "01" after 40ns, "10" after 60ns, "11" after 80ns, "00" after 100ns;
        
--    SW <= "00"; wait for 50ns;
--    SW <= "01"; wait for 50ns;
--    SW <= "10"; wait for 50ns;
--    SW <= "11"; wait for 50ns;

    -- Put test bench stimulus code here

    wait;
  end process;


end;
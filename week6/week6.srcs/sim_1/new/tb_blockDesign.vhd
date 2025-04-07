-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity design_1_wrapper_tb is
end;

architecture bench of design_1_wrapper_tb is

  component design_1_wrapper
    port (
      x1_0 : in STD_LOGIC;
      x2_0 : in STD_LOGIC;
      xOut_0 : out STD_LOGIC
    );
  end component;

  signal x1_0: STD_LOGIC;
  signal x2_0: STD_LOGIC;
  signal xOut_0: STD_LOGIC ;

begin

  uut: design_1_wrapper port map ( x1_0   => x1_0,
                                   x2_0   => x2_0,
                                   xOut_0 => xOut_0 );

  stimulus: process
    begin
        
        x1_0 <= '0';
        x2_0 <= '0';
        wait for 100ns;
        x1_0 <= '1';
        x2_0 <= '0';
        wait for 100ns;
        x1_0 <= '0';
        x2_0 <= '1';
        wait for 100ns;
        x1_0 <= '1';
        x2_0 <= '1';
        wait for 100ns;

    wait;
  end process;


end;
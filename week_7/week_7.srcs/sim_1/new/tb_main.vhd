library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity main_tb is
end;

architecture bench of main_tb is

  component main
      Port( CLK, RESET, W:  IN STD_LOGIC;
            Z: OUT STD_LOGIC
          );
  end component;

  signal CLK, RESET, W: STD_LOGIC;
  signal Z: STD_LOGIC ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: main port map ( CLK   => CLK,
                       RESET => RESET,
                       W     => W,
                       Z     => Z );

  stimulus: process
  begin
  
    -- Put initialisation code here

    RESET <= '1';
    wait for 10 ns;
    RESET <= '0';
    wait for 10 ns;

    -- Put test bench stimulus code here
    W <= '1';
    wait for 10ns;
    W <= '0';
    wait for 40ns;
    
    W <= '1';
    wait for 10ns;
    W <= '1';
    
    
    
    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      CLK <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
  
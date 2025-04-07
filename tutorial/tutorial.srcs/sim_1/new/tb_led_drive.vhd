library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity led_blinker_tb is
end;

architecture bench of led_blinker_tb is

  component led_blinker
      Port(   i_clock     : in std_logic;
              i_enable    : in std_logic;
              i_switch_1  : in std_logic;
              i_switch_2  : in std_logic;
              o_led_drive : out std_logic
          );
  end component;

  signal i_clock    : std_logic := '0';
  signal i_enable   : std_logic := '0';
  signal i_switch_1 : std_logic := '0';
  signal i_switch_2 : std_logic := '0';
  signal o_led_drive: std_logic;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  uut: led_blinker port map ( i_clock     => i_clock,
                              i_enable    => i_enable,
                              i_switch_1  => i_switch_1,
                              i_switch_2  => i_switch_2,
                              o_led_drive => o_led_drive );

  stimulus: process
  begin
  
    i_enable <= '1';
    
    i_switch_1 <= '0';
    i_switch_1 <= '0';
    wait for 20ns;
    i_switch_1 <= '0';
    i_switch_1 <= '1';
    wait for 20ns;
    i_switch_1 <= '1';
    i_switch_1 <= '0';
    wait for 20ns;
    i_switch_1 <= '1';
    i_switch_1 <= '1';
    wait for 20ns;
    
    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      i_clock <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;
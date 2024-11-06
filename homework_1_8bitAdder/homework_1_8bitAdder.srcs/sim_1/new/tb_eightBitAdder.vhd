library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity eightBitAdder_tb is

end eightBitAdder_tb;

architecture Behavioral of eightBitAdder_tb is
    component eightBitAdder 
        Port(   
            A : in STD_LOGIC_VECTOR(7 downto 0);
            B : in STD_LOGIC_VECTOR(7 downto 0);
            C_in : in STD_LOGIC;
            SUM  : out STD_LOGIC_VECTOR(7 downto 0);
            C_out: out STD_LOGIC
            );
    end component;
    
    signal A: STD_LOGIC_VECTOR(7 downto 0);
    signal B: STD_LOGIC_VECTOR(7 downto 0);
    signal C_in: STD_LOGIC;
    signal SUM: STD_LOGIC_VECTOR(7 downto 0);
    signal C_out: STD_LOGIC;

begin

  uut: eightBitAdder port map ( A     => A,
                                B     => B,
                                C_in  => C_in,
                                SUM   => SUM,
                                C_out => C_out );
  stimulus: process
  begin
        C_in <= '0';
        A <= "00000111"; -- 7
        B <= "00001000"; -- 8
        wait for 100ns;
        
        A <= "11110001"; -- -15
        B <= "11111000"; -- -8
        wait for 100ns;
              
        A <= "01111111"; -- 127 
        B <= "11100101"; -- -27 00011011 11100101
        wait for 100ns;

  end process;
end;
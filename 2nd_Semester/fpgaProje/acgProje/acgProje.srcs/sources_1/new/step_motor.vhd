library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity step_motor is
    port (
        clk      : in  std_logic;                     
        rst      : in  std_logic;                     
        en_step  : in  std_logic;                     
        dir      : in  std_logic;                     
        o_signal : out std_logic_vector(3 downto 0)   
    );
end step_motor;

architecture simple of step_motor is
    type seq_t is array(0 to 3) of std_logic_vector(3 downto 0);
    constant seq : seq_t := ("1000","0100","0010","0001");

    signal idx : unsigned(1 downto 0) := (others=>'0');
begin
    o_signal <= seq(to_integer(idx));

    process(clk,rst)
    begin
        if rst='1' then
            idx <= (others=>'0');
        elsif rising_edge(clk) then
            if en_step = '1' then
               if dir = '1' then
                   idx <= idx + 1;
               else
                   idx <= idx - 1;
               end if;
            end if;
        end if;
    end process;
end simple;

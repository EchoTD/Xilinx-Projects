library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    Port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        button_in  : in  STD_LOGIC;
        button_out : out STD_LOGIC
    );
end debounce;

architecture Behavioral of debounce is
    constant debounce_limit  : integer := 20000000;
    signal   counter         : integer range 0 to debounce_limit := 0;
    signal   button_sync     : STD_LOGIC_VECTOR(1 downto 0) := (others => '1');

begin
    process(clk, reset)
    begin
        if reset = '1' then
            counter      <= 0;
            button_out   <= '1';
            button_sync  <= (others => '1');
        elsif rising_edge(clk) then
            button_sync(0) <= button_in;
            button_sync(1) <= button_sync(0);
            if button_sync(1) = '0' then
                if counter < debounce_limit then
                    counter <= counter + 1;
                else
                    button_out <= '0';
                end if;
            else
                counter    <= 0;
                button_out <= '1';
            end if;
        end if;
    end process;
end Behavioral;
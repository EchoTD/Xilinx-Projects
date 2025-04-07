library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity main is
  port (
    clk_IN                     : in std_logic;
    reset                      : in std_logic;
    BTNC                       : in std_logic;
    CA, CB, CC, CD, CE, CF, CG : out std_logic;
    AN                         : out std_logic_vector(7 downto 0)
  );
end main;

architecture Behavioral of main is
  signal debounced_button      : std_logic;
  signal debounced_button_last : std_logic            := '1';
  signal number                : unsigned(3 downto 0) := (others => '0');

begin
  debounce_inst : entity work.debounce
    port map
    (
      clk        => clk_IN,
      reset      => reset,
      button_in  => BTNC,
      button_out => debounced_button
    );

  -- Counter
  process (clk_IN, reset)
  begin
    if reset = '1' then
      number                <= (others => '0');
      debounced_button_last <= '1';
    elsif rising_edge(clk_IN) then
      if debounced_button = '0' and debounced_button_last = '1' then
        if number = "1001" then
          number <= (others => '0');
        else
          number <= number + 1;
        end if;
      end if;
      debounced_button_last <= debounced_button;
    end if;
  end process;

  process (number)
  begin
    case number is
      when "0000" => -- Display 0
        CA <= '0';
        CB <= '0';
        CC <= '0';
        CD <= '0';
        CE <= '0';
        CF <= '0';
        CG <= '1';
      when "0001" => -- Display 1
        CA <= '1';
        CB <= '0';
        CC <= '0';
        CD <= '1';
        CE <= '1';
        CF <= '1';
        CG <= '1';
      when "0010" => -- Display 2
        CA <= '0';
        CB <= '0';
        CC <= '1';
        CD <= '0';
        CE <= '0';
        CF <= '1';
        CG <= '0';
      when "0011" => -- Display 3
        CA <= '0';
        CB <= '0';
        CC <= '0';
        CD <= '0';
        CE <= '1';
        CF <= '1';
        CG <= '0';
      when "0100" => -- Display 4
        CA <= '1';
        CB <= '0';
        CC <= '0';
        CD <= '1';
        CE <= '1';
        CF <= '0';
        CG <= '0';
      when "0101" => -- Display 5
        CA <= '0';
        CB <= '1';
        CC <= '0';
        CD <= '0';
        CE <= '1';
        CF <= '0';
        CG <= '0';
      when "0110" => -- Display 6
        CA <= '0';
        CB <= '1';
        CC <= '0';
        CD <= '0';
        CE <= '0';
        CF <= '0';
        CG <= '0';
      when "0111" => -- Display 7
        CA <= '0';
        CB <= '0';
        CC <= '0';
        CD <= '1';
        CE <= '1';
        CF <= '1';
        CG <= '1';
      when "1000" => -- Display 8
        CA <= '0';
        CB <= '0';
        CC <= '0';
        CD <= '0';
        CE <= '0';
        CF <= '0';
        CG <= '0';
      when "1001" => -- Display 9
        CA <= '0';
        CB <= '0';
        CC <= '0';
        CD <= '0';
        CE <= '1';
        CF <= '0';
        CG <= '0';
      when others =>
        CA <= '1';
        CB <= '1';
        CC <= '1';
        CD <= '1';
        CE <= '1';
        CF <= '1';
        CG <= '1';
    end case;
  end process;

  AN <= "11111110";
end Behavioral;
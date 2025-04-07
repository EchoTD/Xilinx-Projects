library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ps2_rx is
    port (
        clk          : in std_logic;
        ps2_clk      : in std_logic;
        ps2_data     : in std_logic;
        scan_code    : out std_logic_vector(7 downto 0)
    );
end ps2_rx;

architecture Behavioral of ps2_rx is
    signal ps2_clk_sync : std_logic_vector(1 downto 0) := "00";
    signal ps2_data_sync : std_logic := '1';
    signal bit_cntr : integer range 0 to 10 := 0;
    signal shreg : std_logic_vector(7 downto 0) := (others => '0');
    signal parity_bit : std_logic := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            ps2_clk_sync <= ps2_clk_sync(0) & ps2_clk;
            ps2_data_sync <= ps2_data;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if ps2_clk_sync = "10" then
                case bit_cntr is
                    when 0 =>  -- Start bit
                        bit_cntr <= bit_cntr + 1;
                    when 1 to 8 =>  -- Data bits
                        shreg <= ps2_data_sync & shreg(7 downto 1);
                        bit_cntr <= bit_cntr + 1;
                    when 9 =>  -- Parity bit
                        parity_bit <= ps2_data_sync;
                        bit_cntr <= bit_cntr + 1;
                    when 10 =>  -- Stop bit
                        if parity_bit = not (shreg(0) xor shreg(1) xor shreg(2) xor shreg(3) xor shreg(4) xor shreg(5) xor shreg(6) xor shreg(7)) then
                            scan_code <= shreg;
                        end if;
                        bit_cntr <= 0;
                    when others =>
                        bit_cntr <= 0;
                end case;
            end if;
        end if;
    end process;

end Behavioral;
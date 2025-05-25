library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    generic(
        c_clkfreq : integer := 100_000_000;
        c_baud    : integer := 115200
    );
    port(
        clk      : in  std_logic;
        tx_start : in  std_logic;
        tx_data  : in  std_logic_vector(7 downto 0);
        tx_busy  : out std_logic;
        txd_o    : out std_logic
    );
end uart_tx;

architecture rtl of uart_tx is
    constant c_div : integer := c_clkfreq / c_baud;
    signal div_cnt : integer range 0 to c_div-1 := 0;
    signal shreg   : std_logic_vector(9 downto 0) := (others=>'1'); -- idle='1'
    signal bit_cnt : integer range 0 to 10 := 10;
begin
    txd_o  <= shreg(0);
    tx_busy <= '0' when bit_cnt = 10 else '1';

    process(clk)
    begin
        if rising_edge(clk) then
            if bit_cnt = 10 then
                if tx_start = '1' then
                    shreg   <= '1' & tx_data & '0';      -- stop-data-start
                    bit_cnt <= 0;
                    div_cnt <= 0;
                end if;
            else
                if div_cnt = c_div-1 then
                    div_cnt <= 0;
                    shreg   <= '1' & shreg(9 downto 1);  -- logical shift right
                    bit_cnt <= bit_cnt + 1;
                else
                    div_cnt <= div_cnt + 1;
                end if;
            end if;
        end if;
    end process;
end rtl;

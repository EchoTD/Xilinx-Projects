library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity step_motor is
    generic (
        c_clkfreq       : integer := 100_000_000;        -- Hz
        c_max_rpm       : integer := 15;                 -- safety limit
        c_steps_per_rev : integer := 2048                -- 28BYJ-48 in half-step
    );
    port (
        clk            : in  std_logic;
        start_i        : in  std_logic;                  -- pulse = execute
        dir_i          : in  std_logic;                  -- '1' = CW, '0' = CCW
        steps_i        : in  unsigned(15 downto 0);      -- how many half-steps
        busy_o         : out std_logic;
        coils_o        : out std_logic_vector(3 downto 0) -- map to JD[4:1]
    );
end step_motor;

architecture rtl of step_motor is
    type seq_t is array (0 to 7) of std_logic_vector(3 downto 0);
    constant c_seq : seq_t :=
        ("1000","1100","0100","0110","0010","0011","0001","1001");

    constant c_tick_lim : integer :=
        c_clkfreq / (c_max_rpm * c_steps_per_rev / 60);

    signal tick_cnt  : integer range 0 to c_tick_lim := 0;
    signal step_cnt  : unsigned(15 downto 0) := (others=>'0');
    signal idx       : unsigned(2 downto 0) := (others=>'0');
    signal active    : std_logic := '0';
begin
    coils_o <= c_seq(to_integer(idx));
    busy_o  <= active;

    process(clk)
    begin
        if rising_edge(clk) then
            if active = '0' then
                if start_i = '1' and steps_i /= 0 then
                    active   <= '1';
                    step_cnt <= steps_i;
                end if;
            else
                -- step-rate timer
                if tick_cnt = c_tick_lim-1 then
                    tick_cnt <= 0;
                    -- advance sequence
                    if dir_i = '1' then
                        idx <= idx + 1;
                    else
                        idx <= idx - 1;
                    end if;
                    -- step counter
                    if step_cnt = 1 then
                        active <= '0';
                    end if;
                    step_cnt <= step_cnt - 1;
                else
                    tick_cnt <= tick_cnt + 1;
                end if;
            end if;
        end if;
    end process;
end rtl;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity traffic_light_top is
    generic (
        G_GREEN_DURATION  : unsigned(3 downto 0) := "0101";  -- Default: 5
        G_YELLOW_DURATION : unsigned(3 downto 0) := "0010";  -- Default: 2
        G_RED_DURATION    : unsigned(3 downto 0) := "0110"   -- Default: 6
    );
    Port (
        CLK100MHZ   : in  std_logic;  -- 100 MHz clock
        CPU_RESETN  : in  std_logic;  -- Active-low reset
        BTNC        : in  std_logic;  -- Button
        LED_R       : out std_logic;  -- Red LED
        LED_Y       : out std_logic;  -- Yellow LED
        LED_G       : out std_logic   -- Green LED
    );
end traffic_light_top;

architecture Behavioral of traffic_light_top is
    signal counter_1s : unsigned(10 downto 0) := (others => '0');
    signal clk_1hz    : std_logic := '0';

    constant C_1SEC : unsigned(10 downto 0) := to_unsigned(19, 11);

    -- FSM States
    type state_type is (S0, S1, S2, S3);
    signal current_state : state_type := S0;
    signal timer_count   : unsigned(3 downto 0) := (others => '0');

    -- Durations
    constant T_GREEN  : unsigned(3 downto 0) := G_GREEN_DURATION;
    constant T_YELLOW : unsigned(3 downto 0) := G_YELLOW_DURATION;
    constant T_RED    : unsigned(3 downto 0) := G_RED_DURATION;

begin
    process(CLK100MHZ, CPU_RESETN)
    begin
        if (CPU_RESETN = '0') then
            counter_1s <= (others => '0');
            clk_1hz    <= '0';
        elsif rising_edge(CLK100MHZ) then
            if (counter_1s = C_1SEC) then
                clk_1hz    <= not clk_1hz;
                counter_1s <= (others => '0');
            else
                counter_1s <= counter_1s + 1;
            end if;
        end if;
    end process;

    -- FSM
    process(clk_1hz, CPU_RESETN)
    begin
        if (CPU_RESETN = '0') then
            current_state <= S0;
            timer_count   <= (others => '0');
        elsif rising_edge(clk_1hz) then
            if (BTNC = '1') then
                case current_state is
                    when S0 => current_state <= S1; -- green to yellow
                    when S1 => current_state <= S2; -- yellow to red
                    when S2 => current_state <= S2; -- red to red
                    when S3 => current_state <= S2; -- yellow to red
                end case;
                timer_count <= (others => '0');
            else
                timer_count <= timer_count + 1;
                case current_state is
                    when S0 => 
                        if (timer_count = T_GREEN) then
                            current_state <= S1; 
                            timer_count   <= (others => '0');
                        end if;
                    when S1 => 
                        if (timer_count = T_YELLOW) then
                            current_state <= S2; 
                            timer_count   <= (others => '0');
                        end if;
                    when S2 => 
                        if (timer_count = T_RED) then
                            current_state <= S3; 
                            timer_count   <= (others => '0');
                        end if;
                    when S3 => 
                        if (timer_count = T_YELLOW) then
                            current_state <= S0; 
                            timer_count   <= (others => '0');
                        end if;
                end case;
            end if;
        end if;
    end process;

    process(current_state)
    begin
        LED_R <= '0';
        LED_Y <= '0';
        LED_G <= '0';

        case current_state is
            when S0 =>  -- Green
                LED_G <= '1';
            when S1 =>  -- Yellow
                LED_Y <= '1';
            when S2 =>  -- Red
                LED_R <= '1';
            when S3 =>  -- Red and Yellow
                LED_R <= '1';
                LED_Y <= '1';
        end case;
    end process;

end Behavioral;
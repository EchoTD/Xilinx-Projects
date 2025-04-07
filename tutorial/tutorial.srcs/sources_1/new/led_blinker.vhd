library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity led_blinker is
    Port(   i_clock     : in std_logic;
            i_enable    : in std_logic;
            i_switch_1  : in std_logic;
            i_switch_2  : in std_logic;
            o_led_drive : out std_logic
        );
end led_blinker;

architecture rtl of led_blinker is
    
    -- Formula: 100MHz / 100Hz * 50% duty cycle
    -- For 100Hz: 100,000,000 / 100 * 0.5 = 125,000
    constant c_CNT_100HZ    : natural   := 500000;
    constant c_CNT_50HZ     : natural   := 1000000;
    constant c_CNT_10HZ     : natural   := 5000000;
    constant c_CNT_1HZ      : natural   := 50000000;
    
    signal r_CNT_100HZ      : natural range 0 to c_CNT_100HZ;
    signal r_CNT_50HZ       : natural range 0 to c_CNT_50HZ;
    signal r_CNT_10HZ       : natural range 0 to c_CNT_10HZ;
    signal r_CNT_1HZ        : natural range 0 to c_CNT_1HZ;
    
    signal r_TOGGLE_100HZ   : std_logic := '0';
    signal r_TOGGLE_50HZ    : std_logic := '0';
    signal r_TOGGLE_10HZ    : std_logic := '0';
    signal r_TOGGLE_1HZ     : std_logic := '0';
    
    signal w_LED_SELECT     : std_logic;

begin

    p_100_HZ : process (i_clock) is
    begin
        if rising_edge(i_clock) then
            if r_CNT_100HZ = c_CNT_100HZ - 1 then
                r_TOGGLE_100HZ <= NOT r_TOGGLE_100HZ;
                r_CNT_100HZ <= 0;
            else
                r_CNT_100HZ <= r_CNT_100HZ + 1;
            end if;
        end if;
    end process p_100_HZ;
    
    p_50_HZ : process (i_clock) is
    begin
        if rising_edge(i_clock) then
            if r_CNT_50HZ = c_CNT_50HZ - 1 then
                r_TOGGLE_50HZ <= NOT r_TOGGLE_50HZ;
                r_CNT_50HZ <= 0;
            else
                r_CNT_50HZ <= r_CNT_50HZ + 1;
            end if;
        end if;
    end process p_50_HZ;
    
    p_10_HZ : process (i_clock) is
    begin
        if rising_edge(i_clock) then
            if r_CNT_10HZ = c_CNT_10HZ - 1 then
                r_TOGGLE_10HZ <= NOT r_TOGGLE_10HZ;
                r_CNT_10HZ <= 0;
            else
                r_CNT_10HZ <= r_CNT_10HZ + 1;
            end if;
        end if;
    end process p_10_HZ;
    
    p_1_HZ : process (i_clock) is
    begin
        if rising_edge(i_clock) then
            if r_CNT_1HZ = c_CNT_1HZ - 1 then
                r_TOGGLE_1HZ <= NOT r_TOGGLE_1HZ;
                r_CNT_1HZ <= 0;
            else
                r_CNT_1HZ <= r_CNT_1HZ + 1;
            end if;
        end if;
    end process p_1_HZ;
    
    w_LED_SELECT <= r_TOGGLE_100HZ  when (i_switch_1 = '0' and i_switch_2 = '0') else
                    r_TOGGLE_50HZ   when (i_switch_1 = '0' and i_switch_2 = '1') else
                    r_TOGGLE_10HZ   when (i_switch_1 = '1' and i_switch_2 = '0') else
                    r_TOGGLE_1HZ;
    
    o_led_drive <= w_LED_SELECT and i_enable;

end rtl;
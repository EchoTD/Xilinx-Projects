----------------------------------------------------------------------------------
-- Alaaddin Can Gürsoy 21014506
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_fsm is
    Port (
        CLK100MHZ  : in  STD_LOGIC;
        BTNC       : in  STD_LOGIC;
        CPU_RESETN : in  STD_LOGIC;
        CA         : out STD_LOGIC;
        CB         : out STD_LOGIC;
        CC         : out STD_LOGIC;
        CD         : out STD_LOGIC;
        CE         : out STD_LOGIC;
        CF         : out STD_LOGIC;
        CG         : out STD_LOGIC;
        DP         : out STD_LOGIC;
        AN         : out STD_LOGIC_VECTOR(7 downto 0)
    );
end seven_seg_fsm;

architecture RTL of seven_seg_fsm is
    type state_type is (sA, sB, sC, sD, sE, sF);
    signal current_state, next_state : state_type := sA;

    constant DIV_FACTOR : integer := 1000000;  -- ~1 kHz from 100 MHz? 100000
    signal clk_div_counter : unsigned(31 downto 0) := (others => '0');
    signal slow_clk : STD_LOGIC := '0';

    constant DEBOUNCE_MAX : integer := 100000;
    signal debounce_count : unsigned(31 downto 0) := (others => '0');
    signal reset_n : STD_LOGIC := '1';

    -- Segment patterns (0 = segment on)
    constant SEG_A : STD_LOGIC_VECTOR(6 downto 0) := "1111110";
    constant SEG_B : STD_LOGIC_VECTOR(6 downto 0) := "1111101";
    constant SEG_C : STD_LOGIC_VECTOR(6 downto 0) := "1111011";
    constant SEG_D : STD_LOGIC_VECTOR(6 downto 0) := "1110111";
    constant SEG_E : STD_LOGIC_VECTOR(6 downto 0) := "1101111";
    constant SEG_F : STD_LOGIC_VECTOR(6 downto 0) := "1011111";

    signal seg_pattern : STD_LOGIC_VECTOR(6 downto 0); 
begin
    -- Debounce CPU_RESETN
    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if CPU_RESETN='0' and debounce_count < to_unsigned(DEBOUNCE_MAX,32) then
                debounce_count <= debounce_count + 1;
            elsif CPU_RESETN='1' and debounce_count > 0 then
                debounce_count <= debounce_count - 1;
            end if;

            if debounce_count = to_unsigned(DEBOUNCE_MAX,32) then
                reset_n <= '0';
            elsif debounce_count = 0 then
                reset_n <= '1';
            end if;
        end if;
    end process;

    -- Clock divider (100 MHz to ~1 kHz)
    process(CLK100MHZ, reset_n)
    begin
        if reset_n='0' then
            clk_div_counter <= (others => '0');
            slow_clk <= '0';
        elsif rising_edge(CLK100MHZ) then
            if clk_div_counter = to_unsigned(DIV_FACTOR-1,32) then
                clk_div_counter <= (others => '0');
                slow_clk <= not slow_clk;
            else
                clk_div_counter <= clk_div_counter + 1;
            end if;
        end if;
    end process;

    -- State register
    process(slow_clk, reset_n)
    begin
        if reset_n='0' then
            current_state <= sA;
        elsif rising_edge(slow_clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Next state logic
    process(current_state, BTNC)
    begin
        next_state <= current_state;
        if BTNC='1' then
            next_state <= sA;
        else
            case current_state is
                when sA => next_state <= sB;
                when sB => next_state <= sC;
                when sC => next_state <= sD;
                when sD => next_state <= sE;
                when sE => next_state <= sF;
                when sF => next_state <= sA;
            end case;
        end if;
    end process;

    -- Select segment pattern
    process(current_state)
    begin
        case current_state is
            when sA => seg_pattern <= SEG_A;
            when sB => seg_pattern <= SEG_B;
            when sC => seg_pattern <= SEG_C;
            when sD => seg_pattern <= SEG_D;
            when sE => seg_pattern <= SEG_E;
            when sF => seg_pattern <= SEG_F;
        end case;
    end process;

    CA <= seg_pattern(0);
    CB <= seg_pattern(1);
    CC <= seg_pattern(2);
    CD <= seg_pattern(3);
    CE <= seg_pattern(4);
    CF <= seg_pattern(5);
    CG <= seg_pattern(6);

    -- Keep DP off
    DP <= '1';

    -- Enable one digit (AN(0) = '0')
    AN <= "01111111";

end RTL;
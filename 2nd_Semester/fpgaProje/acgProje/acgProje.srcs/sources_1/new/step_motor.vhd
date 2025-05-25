library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity step_motor is
    Port (
        rst    : in  STD_LOGIC;
        dir    : in  STD_LOGIC;
        clk    : in  STD_LOGIC;
        en     : in  STD_LOGIC;
        o_signal : out std_logic_vector(3 downto 0) 
        );
end step_motor;

architecture Behavioral of step_motor is
    -- Durum tanımları
    type state_type is (sig0, sig1, sig2, sig3, sig4);
    signal present_state, next_state : state_type := sig0;
    
    -- UART'tan gelen yön bilgisini kaydetmek için register
    signal dir_reg : STD_LOGIC := '0';
begin

    -- Yön bilgisini kaydetme (clock ile senkronize)
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                dir_reg <= dir;
            end if;
        end if;
    end process;

    -- Durum geçiş mantığı
    process(present_state, dir_reg, en)
    begin
        case present_state is
            when sig4 =>
                if en = '1' then
                    if dir_reg = '0' then  -- Negatif yön (ters sıra)
                        next_state <= sig3;
                    else                  -- Pozitif yön (normal sıra)
                        next_state <= sig1;
                    end if;
                else
                    next_state <= sig0;
                end if;
                
            when sig3 =>
                if en = '1' then
                    if dir_reg = '0' then
                        next_state <= sig2;
                    else
                        next_state <= sig4;
                    end if;
                else
                    next_state <= sig0;
                end if;
                
            when sig2 =>
                if en = '1' then
                    if dir_reg = '0' then
                        next_state <= sig1;
                    else
                        next_state <= sig3;
                    end if;
                else
                    next_state <= sig0;
                end if;
                
            when sig1 =>
                if en = '1' then
                    if dir_reg = '0' then
                        next_state <= sig4;
                    else
                        next_state <= sig2;
                    end if;
                else
                    next_state <= sig0;
                end if;
                
            when sig0 =>
                if en = '1' then
                    next_state <= sig1;
                else
                    next_state <= sig0;
                end if;
                
            when others =>
                next_state <= sig0;
        end case;
    end process;

    -- Durum register'ı
    process(clk, rst)
    begin
        if rst = '1' then
            present_state <= sig0;
        elsif rising_edge(clk) then
            present_state <= next_state;
        end if;
    end process;

    -- Çıkış mantığı
    process(clk)
    begin
        if rising_edge(clk) then
            case present_state is
                when sig4 => o_signal <= "1000";
                when sig3 => o_signal <= "0100";
                when sig2 => o_signal <= "0010";
                when sig1 => o_signal <= "0001";
                when others => o_signal <= "0000";
            end case;
        end if;
    end process;

end Behavioral;
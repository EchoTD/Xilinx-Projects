library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parkingGate is
    Port(   i_CLK:          in STD_LOGIC;
            i_RESET:        in STD_LOGIC;
            i_coinInsert:   in STD_LOGIC;
            r_N:            in STD_LOGIC; -- 25 kurus
            r_B:            in STD_LOGIC; -- 10 kurus
            r_A:            in STD_LOGIC; --  5 kurus
            o_D:            out STD_LOGIC 
        );

end parkingGate;

architecture Behavioral of parkingGate is

    signal coinValue:   unsigned(5 downto 0);
    signal totalValue:  unsigned(5 downto 0);
    signal D_signal:    STD_LOGIC;

begin

    process(r_N, r_B, r_A)
        variable temp: unsigned(5 downto 0);
    begin
        temp := (others => '0');
        if r_N = '1' then
            temp := temp + TO_UNSIGNED(25, 6);
        end if;
        if r_B = '1' then
            temp := temp + TO_UNSIGNED(10, 6);
        end if;
        if r_A = '1' then
            temp := temp + TO_UNSIGNED(5, 6);
        end if;
        coinValue <= temp;
    end process;
    
    process(i_CLK, i_RESET)
        variable tempSum: unsigned(5 downto 0);
    begin
        if i_RESET = '1' then
            totalValue <= (others => '0');
        elsif rising_edge(i_CLK) then
            if i_coinInsert = '1' then
                tempSum := totalValue + coinValue;
                totalValue <= tempSum;
            end if;
        end if;
    end process;
    
    process(totalValue)
    begin
        if totalValue >= TO_UNSIGNED(30, 6) then
            D_signal <= '1';
        else
            D_signal <= '0';
        end if;
    end process;
    
    o_D <= D_signal;    
    
end Behavioral;
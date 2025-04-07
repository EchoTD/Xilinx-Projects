library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity main is
    Port( CLK, RESET, W:  IN STD_LOGIC;
          Z: OUT STD_LOGIC
        );

end main;

architecture RTL of main is
    TYPE moore_FSM is (A, B, C);
    signal state, nextState: moore_FSM;

    --signal output: STD_LOGIC;

begin

    SYNC_PROC: process (CLK)
    begin
        if RESET = '1' then
            state <= A;
          elsif (CLK'event and CLK = '1') then
            state <= nextState;
          end if;
    end process;

    NEXT_STATE_DECODE: process (state, W)
    begin
       nextState <= state;
       case (state) is
          when A =>
             if W = '1' then
                nextState <= B;
             end if;
          when B =>
             if W = '1' then
                nextState <= C;
             end if;
          when C =>
             if W = '0' then
                nextState <= A;
             end if;
          when others =>
             nextState <= state;
       end case;
    end process;

Z <= '1' WHEN state = C else '0';

end RTL;

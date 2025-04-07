library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    generic (
        c_clkfreq   : integer := 100_000_000;  -- Clock frequency in Hz
        c_baudrate  : integer := 115_200       -- Baud rate
    );
    port (
        clk             : in std_logic;        -- System clock
        rx_i            : in std_logic;        -- UART RX input
        rx_done_tick_o  : out std_logic;       -- Pulse when a byte is received
        dout_o          : out std_logic_vector(7 downto 0)  -- Received data byte
    );
end uart_rx;

architecture Behavioral of uart_rx is
    constant c_bittimerlim : integer := c_clkfreq / c_baudrate;  -- Clock cycles per bit
    signal bittimer : integer range 0 to c_bittimerlim - 1 := 0; -- Bit timer
    signal bitcntr  : integer range 0 to 7 := 0;                -- Bit counter
    type states is (S_IDLE, S_START, S_DATA, S_STOP);           -- State machine states
    signal state : states := S_IDLE;                            -- Current state
    signal shreg : std_logic_vector(7 downto 0) := (others => '0');  -- Shift register for received data
begin

    -- UART Receiver Process
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                when S_IDLE =>
                    rx_done_tick_o <= '0';  -- Reset done signal
                    if rx_i = '0' then      -- Start bit detected (active low)
                        state <= S_START;
                        bittimer <= 0;
                    end if;

                when S_START =>
                    if bittimer = c_bittimerlim / 2 - 1 then  -- Wait for half a bit period
                        state <= S_DATA;
                        bittimer <= 0;
                    else
                        bittimer <= bittimer + 1;
                    end if;

                when S_DATA =>
                    if bittimer = c_bittimerlim - 1 then  -- Wait for a full bit period
                        if bitcntr = 7 then               -- All 8 bits received
                            state <= S_STOP;
                            bitcntr <= 0;
                        else
                            bitcntr <= bitcntr + 1;
                        end if;
                        shreg <= rx_i & shreg(7 downto 1);  -- Shift in the received bit
                        bittimer <= 0;
                    else
                        bittimer <= bittimer + 1;
                    end if;

                when S_STOP =>
                    if bittimer = c_bittimerlim - 1 then  -- Wait for stop bit
                        state <= S_IDLE;
                        rx_done_tick_o <= '1';            -- Pulse to indicate byte received
                    else
                        bittimer <= bittimer + 1;
                    end if;
            end case;
        end if;
    end process;

    -- Output the received data
    dout_o <= shreg;

end Behavioral;
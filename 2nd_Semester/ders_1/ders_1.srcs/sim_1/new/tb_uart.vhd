library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uart_tb is
end uart_tb;

architecture Behavioral of uart_tb is
    -- Constants
    constant CLOCK_PERIOD : time := 10 ns; -- 100 MHz clock

    -- Signals
    signal clk          : STD_LOGIC := '0';
    signal reset        : STD_LOGIC := '0';
    signal UART_RXD_OUT : STD_LOGIC := '1'; -- UART RX line (idle high)
    signal UART_TXD_IN  : STD_LOGIC;
    signal tx_data      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal tx_start     : STD_LOGIC := '0';
    signal tx_busy      : STD_LOGIC;
    signal rx_data      : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_ready     : STD_LOGIC;

    -- UART component
    component uart
        Port (
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            UART_RXD_OUT : in  STD_LOGIC;
            UART_TXD_IN  : out STD_LOGIC;
            tx_data      : in  STD_LOGIC_VECTOR(7 downto 0);
            tx_start     : in  STD_LOGIC;
            tx_busy      : out STD_LOGIC;
            rx_data      : out STD_LOGIC_VECTOR(7 downto 0);
            rx_ready     : out STD_LOGIC
        );
    end component;

begin
    -- Clock generation
    clk <= not clk after CLOCK_PERIOD / 2;

    -- Instantiate the UART module
    uut: uart
        Port Map (
            clk          => clk,
            reset        => reset,
            UART_RXD_OUT => UART_RXD_OUT,
            UART_TXD_IN  => UART_TXD_IN,
            tx_data      => tx_data,
            tx_start     => tx_start,
            tx_busy      => tx_busy,
            rx_data      => rx_data,
            rx_ready     => rx_ready
        );

    -- Test process
    process
    begin
        -- Reset the system
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;

        -- Test 1: Transmit and receive a byte
        tx_data <= x"55"; -- Data to transmit (0x55 = 'U')
        tx_start <= '1';
        wait until tx_busy = '1';
        tx_start <= '0';

        -- Simulate UART RX line (receive the transmitted data)
        wait for 104160 ns; -- Wait for 1 start bit + 8 data bits + 1 stop bit at 9600 baud
        UART_RXD_OUT <= '0'; -- Start bit
        wait for 104160 ns; -- Bit time
        UART_RXD_OUT <= '1'; -- Bit 0
        wait for 104160 ns;
        UART_RXD_OUT <= '0'; -- Bit 1
        wait for 104160 ns;
        UART_RXD_OUT <= '1'; -- Bit 2
        wait for 104160 ns;
        UART_RXD_OUT <= '0'; -- Bit 3
        wait for 104160 ns;
        UART_RXD_OUT <= '1'; -- Bit 4
        wait for 104160 ns;
        UART_RXD_OUT <= '0'; -- Bit 5
        wait for 104160 ns;
        UART_RXD_OUT <= '1'; -- Bit 6
        wait for 104160 ns;
        UART_RXD_OUT <= '0'; -- Bit 7
        wait for 104160 ns;
        UART_RXD_OUT <= '1'; -- Stop bit
        wait for 104160 ns;

        -- Wait for RX_READY to go high
        wait until rx_ready = '1';
        assert rx_data = x"55" report "RX Data mismatch!" severity error;

        -- Test 2: Transmit and receive another byte
        tx_data <= x"AA"; -- Data to transmit (0xAA)
        tx_start <= '1';
        wait until tx_busy = '1';
        tx_start <= '0';

        -- Simulate UART RX line (receive the transmitted data)
        wait for 104160 ns; -- Wait for 1 start bit + 8 data bits + 1 stop bit at 9600 baud
        UART_RXD_OUT <= '0'; -- Start bit
        wait for 104160 ns; -- Bit time
        UART_RXD_OUT <= '0'; -- Bit 0
        wait for 104160 ns;
        UART_RXD_OUT <= '1'; -- Bit 1
        wait for 104160 ns;
        UART_RXD_OUT <= '0'; -- Bit 2
        wait for 104160 ns;
        UART_RXD_OUT <= '1'; -- Bit 3
        wait for 104160 ns;
        UART_RXD_OUT <= '0'; -- Bit 4
        wait for 104160 ns;
        UART_RXD_OUT <= '1'; -- Bit 5
        wait for 104160 ns;
        UART_RXD_OUT <= '0'; -- Bit 6
        wait for 104160 ns;
        UART_RXD_OUT <= '1'; -- Bit 7
        wait for 104160 ns;
        UART_RXD_OUT <= '1'; -- Stop bit
        wait for 104160 ns;

        -- Wait for RX_READY to go high
        wait until rx_ready = '1';
        assert rx_data = x"AA" report "RX Data mismatch!" severity error;

        -- End of simulation
        report "Simulation completed successfully!" severity note;
        wait;
    end process;
end Behavioral;
--  top.vhd  -  minimal top (no seven-segment, no LEDs)
--  Vivado 2022.2 • Nexys-A7-100T • 100 MHz system clock
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    generic (
        g_clkfreq : integer := 100_000_000      -- on-board 100 MHz
    );
    port (
        CLK100MHZ       : in  std_logic;
        JA              : inout std_logic_vector(10 downto 1);
        JD              : out   std_logic_vector(4 downto 1);
        SW              : in  std_logic_vector(5 downto 0);
        BTNC, BTNU, BTND: in  std_logic;
        UART_RXD_OUT    : out std_logic
    );
end top;

architecture rtl of top is
    signal spi_miso   : std_logic;
    signal spi_mosi   : std_logic;
    signal spi_sclk   : std_logic;
    signal spi_cs     : std_logic;

    signal ax, ay, az : std_logic_vector(15 downto 0);
    signal acc_ready  : std_logic;


    signal sm_start   : std_logic;
    signal sm_dir     : std_logic;
    signal sm_steps   : unsigned(15 downto 0);
    signal sm_busy    : std_logic;

    signal btnc_prev  : std_logic := '0';

    signal uart_start : std_logic;
    signal uart_busy  : std_logic;
    signal uart_byte  : std_logic_vector(7 downto 0);

    type buf_t is array(0 to 7) of std_logic_vector(7 downto 0);
    signal tx_buf     : buf_t;
    signal tx_index   : integer range 0 to 7 := 0;
    signal tx_active  : std_logic := '0';
    
begin

    JA(1) <= 'Z';                       -- MISO line is input only
    spi_miso <= JA(1);

    JA(2) <= spi_mosi;
    JA(3) <= spi_sclk;
    JA(4) <= spi_cs;
    
    acc_reader_i : entity work.acc_reader
        generic map (
            c_clkfreq  => g_clkfreq,
            c_sclkfreq => 1_000_000,
            c_readfreq => 100,
            c_cpol     => '0',
            c_cpha     => '0')
        port map (
            clk_i   => CLK100MHZ,
            miso_i  => spi_miso,
            mosi_o  => spi_mosi,
            sclk_o  => spi_sclk,
            cs_o    => spi_cs,
            ax_o    => ax,
            ay_o    => ay,
            az_o    => az,
            ready_o => acc_ready);

    process(CLK100MHZ)  -- one-clock pulse on btnc_rise
        variable btnc_rise : std_logic;
    begin
        if rising_edge(CLK100MHZ) then
            btnc_rise := BTNC and not btnc_prev;
            btnc_prev <= BTNC;

            if SW(5) = '0' then
                -- autopilot  - one burst every fresh sample
                sm_start <= acc_ready;
                sm_dir   <= ax(15);
                if ax(15) = '1' then
                    sm_steps <= unsigned(-signed(ax(15 downto 2)));
                else
                    sm_steps <= unsigned( signed(ax(15 downto 2)));
                end if;
            else

                sm_start <= btnc_rise;
                sm_dir   <= BTNU;               -- CW if BTNU, CCW if BTND
                sm_steps <= ("0000" & unsigned(SW(4 downto 0))); --  0-31 steps
            end if;
        end if;
    end process;

    step_motor_i : entity work.step_motor
        generic map (
            c_clkfreq => g_clkfreq)
        port map (
            clk      => CLK100MHZ,
            start_i  => sm_start,
            dir_i    => sm_dir,
            steps_i  => sm_steps,
            busy_o   => sm_busy,
            coils_o  => JD(4 downto 1));

    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            -- launch a fresh frame
            if (acc_ready = '1') and (tx_active = '0') then
                tx_buf(0) <= x"41";            -- 'A'
                tx_buf(1) <= ax(15 downto 8);
                tx_buf(2) <= ax(7 downto 0);
                tx_buf(3) <= ay(15 downto 8);
                tx_buf(4) <= ay(7 downto 0);
                tx_buf(5) <= az(15 downto 8);
                tx_buf(6) <= az(7 downto 0);
                tx_buf(7) <= x"0A";            -- LF
                tx_index  <= 0;
                tx_active <= '1';
            end if;

            -- feed the UART whenever it is idle
            if (tx_active = '1') and (uart_busy = '0') then
                uart_byte  <= tx_buf(tx_index);
                uart_start <= '1';
            else
                uart_start <= '0';
            end if;

            -- advance pointer once start pulse has been accepted
            if uart_start = '1' then
                if tx_index = 7 then
                    tx_active <= '0';
                else
                    tx_index  <= tx_index + 1;
                end if;
            end if;
        end if;
    end process;

    -- UART transmitter (8-N-1, 115 200 baud)
    uart_tx_i : entity work.uart_tx
        generic map (
            c_clkfreq => g_clkfreq,
            c_baud    => 115200)
        port map (
            clk      => CLK100MHZ,
            tx_start => uart_start,
            tx_data  => uart_byte,
            tx_busy  => uart_busy,
            txd_o    => UART_RXD_OUT);
end rtl;

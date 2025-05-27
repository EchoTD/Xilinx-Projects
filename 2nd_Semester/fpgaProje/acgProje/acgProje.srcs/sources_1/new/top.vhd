library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    generic ( CLK_FREQ : integer := 100_000_000 );
    port (
        CLK100MHZ     : in  std_logic;
        ACL_MISO      : in  std_logic;
        ACL_MOSI      : out std_logic;
        ACL_SCLK      : out std_logic;
        ACL_CSN       : out std_logic;
        JA            : out std_logic_vector(4 downto 1);
        SW            : in  std_logic_vector(5 downto 0);
        BTNC, BTNU, BTND : in  std_logic;
        UART_RXD_OUT  : out std_logic
    );
end top;

architecture rtl of top is

    signal ax, ay, az : std_logic_vector(15 downto 0);
    signal acc_ready  : std_logic;
    signal motor_en   : std_logic;
    signal motor_dir  : std_logic;
    constant STEP_DIV : integer := 500_000;  -- 100 MHz / 500 000 = 200 Hz → 5 ms
    signal burst_len  : unsigned(5 downto 0);
    signal remaining  : unsigned(5 downto 0) := (others=>'0');
    signal div_cnt    : integer range 0 to STEP_DIV := 0;
    signal btnc_prev  : std_logic := '0';
    constant BURST_STEPS  : unsigned(5 downto 0) := to_unsigned(32,6);
    signal tx_buf     : std_logic_vector(7 downto 0);
    signal tx_busy    : std_logic;
    type fsm_t is (idle, s2,s3,s4,s5,s6,s7, lf, wait_busy);
    signal fsm : fsm_t := idle;
    
    constant LEN : integer := 6;
    constant DEAD : integer := 20;
    signal tilt_active : std_logic := '0';
    constant FRAME_LEN : integer := 9;

    type frame_t is array(0 to FRAME_LEN-1) of std_logic_vector(7 downto 0);
    
    signal frame      : frame_t := (others => (others => '0'));
    signal ptr        : integer range 0 to FRAME_LEN := FRAME_LEN;
    signal tx_data    : std_logic_vector(7 downto 0);
    signal tx_start   : std_logic;
begin
    
    acc_reader_i : entity work.acc_reader
        generic map ( c_clkfreq => CLK_FREQ )
        port map (
            clk_i  => CLK100MHZ,
            miso_i => ACL_MISO,
            mosi_o => ACL_MOSI,
            sclk_o => ACL_SCLK,
            cs_o   => ACL_CSN,
            ax_o   => ax,
            ay_o   => ay,
            az_o   => az,
            ready_o=> acc_ready);

    process(CLK100MHZ)
    variable btnc_rise : std_logic;
    variable abs_y     : unsigned(15 downto 0);
    variable abs_y_int : integer;
    begin
        if rising_edge(CLK100MHZ) then
            btnc_rise := BTNC and not btnc_prev;
            btnc_prev <= BTNC;
            
            if SW(5) = '0' then                               -- AUTO
                motor_dir <= ay(15);
                burst_len <= BURST_STEPS;
                remaining <= BURST_STEPS;
            else                                              -- MANUAL
                burst_len <= ("00" & unsigned(SW(3 downto 0)));  -- 1-16
                motor_dir <= BTNU;
                if btnc_rise = '1' then
                    remaining <= burst_len;
                end if;
            end if;
    
            motor_en <= '0';
            if remaining /= 0 then
                if div_cnt = STEP_DIV-1 then
                    div_cnt   <= 0;
                    remaining <= remaining - 1;
                    motor_en  <= '1';
                else
                    div_cnt <= div_cnt + 1;
                end if;
            else
                div_cnt <= 0;
            end if;
        end if;
    end process;

    stepdrv : entity work.step_motor
        port map (
            rst      => '0',
            dir      => motor_dir,
            clk      => CLK100MHZ,
            en_step  => motor_en,
            o_signal => JA(4 downto 1));
    
    uart_proc : process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then

            if acc_ready = '1' then
                frame(0) <= x"58";                 -- 'X'
                frame(1) <= ax(15 downto 8);
                frame(2) <= ax(7  downto 0);
                frame(3) <= x"59";                 -- 'Y'
                frame(4) <= ay(15 downto 8);
                frame(5) <= ay(7  downto 0);
                frame(6) <= x"5A";                 -- 'Z'
                frame(7) <= az(15 downto 8);
                frame(8) <= az(7  downto 0);
                ptr      <= 0;                     -- arm transmitter
            end if;
            
            tx_start <= '0';
            if ptr < FRAME_LEN and tx_busy = '0' then
                tx_data  <= frame(ptr);
                tx_start <= '1';                   -- 1-clk start pulse
                ptr      <= ptr + 1;
            end if;
        end if;
    end process;

    uart_tx_i : entity work.uart_tx
        generic map ( c_clkfreq => CLK_FREQ, c_baud => 115200 )
        port map (
            clk      => CLK100MHZ,
            tx_start => tx_start,
            tx_data  => tx_data,
            tx_busy  => tx_busy,
            txd_o    => UART_RXD_OUT);
end rtl;
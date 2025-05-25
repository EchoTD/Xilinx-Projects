--  top.vhd  •  Vivado 2022.2  •  Nexys-A7-100T
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    generic ( CLK_FREQ : integer := 100_000_000 );
    port (
        CLK100MHZ     : in  std_logic;
        -- on-board ADXL345
        ACL_MISO      : in  std_logic;
        ACL_MOSI      : out std_logic;
        ACL_SCLK      : out std_logic;
        ACL_CSN       : out std_logic;
        -- stepper coils  JD[4:1]
        JD            : out std_logic_vector(4 downto 1);
        -- user I/O
        SW            : in  std_logic_vector(5 downto 0);
        BTNC, BTNU,
        BTND          : in  std_logic;
        -- UART TX → PC
        UART_RXD_OUT  : out std_logic
    );
end top;

architecture rtl of top is
    -- accelerometer interface
    signal ax, ay, az : std_logic_vector(15 downto 0);
    signal acc_ready  : std_logic;
    -- motor control
    signal motor_en   : std_logic;
    signal motor_dir  : std_logic;
    signal btnc_prev  : std_logic := '0';
    -- UART
    signal tx_buf     : std_logic_vector(7 downto 0);
    signal tx_start   : std_logic;
    signal tx_busy    : std_logic;
    type fsm_t is (idle, send2, send3, send4, send5, send6, send7, lf);
    signal fsm       : fsm_t := idle;
begin
    -------------------------------------------------------------------------
    -- accelerometer SPI reader
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

    -------------------------------------------------------------------------
    -- motor enable / direction
    process(CLK100MHZ)
        variable btnc_rise : std_logic;
    begin
        if rising_edge(CLK100MHZ) then
            btnc_rise := BTNC and not btnc_prev;
            btnc_prev <= BTNC;

            if SW(5) = '0' then
                motor_en  <= acc_ready;
                motor_dir <= ax(15);
            else
                motor_en  <= btnc_rise;
                motor_dir <= BTNU;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------------
    -- stepper driver
    stepdrv : entity work.pmod_step_driver
        port map (
            rst    => '0',
            dir    => motor_dir,
            clk    => CLK100MHZ,
            en     => motor_en,
            signal => JD(4 downto 1));

    -------------------------------------------------------------------------
    -- simple UART: A + raw XYZ + LF (8 bytes)
    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            tx_start <= '0';
            case fsm is
                when idle =>
                    if acc_ready = '1' then
                        tx_buf   <= x"41";  -- 'A'
                        tx_start <= '1';
                        fsm      <= send2;
                    end if;
                when send2  => if tx_busy='0' then tx_buf<=ax(15 downto 8); tx_start<='1'; fsm<=send3; end if;
                when send3  => if tx_busy='0' then tx_buf<=ax(7 downto 0);  tx_start<='1'; fsm<=send4; end if;
                when send4  => if tx_busy='0' then tx_buf<=ay(15 downto 8); tx_start<='1'; fsm<=send5; end if;
                when send5  => if tx_busy='0' then tx_buf<=ay(7 downto 0);  tx_start<='1'; fsm<=send6; end if;
                when send6  => if tx_busy='0' then tx_buf<=az(15 downto 8); tx_start<='1'; fsm<=send7; end if;
                when send7  => if tx_busy='0' then tx_buf<=az(7 downto 0);  tx_start<='1'; fsm<=lf;    end if;
                when lf     => if tx_busy='0' then tx_buf<=x"0A";          tx_start<='1'; fsm<=idle;  end if;
            end case;
        end if;
    end process;

    uart_tx_i : entity work.uart_tx
        generic map ( c_clkfreq => CLK_FREQ, c_baud => 115200 )
        port map (
            clk      => CLK100MHZ,
            tx_start => tx_start,
            tx_data  => tx_buf,
            tx_busy  => tx_busy,
            txd_o    => UART_RXD_OUT);
end rtl;
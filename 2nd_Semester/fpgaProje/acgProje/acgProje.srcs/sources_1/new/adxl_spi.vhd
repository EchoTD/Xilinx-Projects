-- acc_reader.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity acc_reader is
    generic (
        c_clkfreq  : integer := 100_000_000;
        c_sclkfreq : integer := 1_000_000;
        c_readfreq : integer := 100;
        c_cpol     : std_logic := '0';
        c_cpha     : std_logic := '0'
    );
    port (
        clk_i   : in  std_logic;
        miso_i  : in  std_logic;
        mosi_o  : out std_logic;
        sclk_o  : out std_logic;
        cs_o    : out std_logic;
        ax_o    : out std_logic_vector(15 downto 0);
        ay_o    : out std_logic_vector(15 downto 0);
        az_o    : out std_logic_vector(15 downto 0);
        ready_o : out std_logic
    );
end acc_reader;

architecture Behavioral of acc_reader is

    component spi_master is
        generic (
            c_clkfreq  : integer := 100_000_000;
            c_sclkfreq : integer := 1_000_000;
            c_cpol     : std_logic := '0';
            c_cpha     : std_logic := '0'
        );
        port (
            clk_i         : in  std_logic;
            en_i          : in  std_logic;
            mosi_data_i   : in  std_logic_vector(7 downto 0);
            miso_data_o   : out std_logic_vector(7 downto 0);
            data_ready_o  : out std_logic;
            cs_o          : out std_logic;
            sclk_o        : out std_logic;
            mosi_o        : out std_logic;
            miso_i        : in  std_logic
        );
    end component;

    constant c_timer_rd_lim : integer := c_clkfreq / c_readfreq;
    signal mosi_data        : std_logic_vector(7 downto 0) := (others => '0');
    signal miso_data        : std_logic_vector(7 downto 0) := (others => '0');
    signal en               : std_logic := '0';
    signal data_ready       : std_logic := '0';
    signal beginread        : std_logic := '0';
    signal cntr             : integer range 0 to 7 := 0;
    signal timer_rd         : integer range 0 to c_timer_rd_lim := 0;
    signal timer_rd_tick    : std_logic := '0';
    type states is (S_CONFIGURE, S_MEASURE);
    signal state : states := S_CONFIGURE;

begin

    spi_master_i : spi_master
        generic map (
            c_clkfreq  => c_clkfreq,
            c_sclkfreq => c_sclkfreq,
            c_cpol     => c_cpol,
            c_cpha     => c_cpha
        )
        port map (
            clk_i         => clk_i,
            en_i          => en,
            mosi_data_i   => mosi_data,
            miso_data_o   => miso_data,
            data_ready_o  => data_ready,
            cs_o          => cs_o,
            sclk_o        => sclk_o,
            mosi_o        => mosi_o,
            miso_i        => miso_i
        );

    P_MAIN : process(clk_i)
    begin
        if rising_edge(clk_i) then
            ready_o <= '0';
            case state is
                when S_CONFIGURE =>
                    if timer_rd_tick = '1' then
                        beginread <= '1';
                    end if;
                    if beginread = '1' then
                        if cntr = 0 then
                            en         <= '1';
                            mosi_data  <= x"0A";
                            if data_ready = '1' then
                                mosi_data <= x"2D";
                                cntr      <= cntr + 1;
                            end if;
                        elsif cntr = 1 then
                            if data_ready = '1' then
                                mosi_data <= x"02";
                                cntr      <= cntr + 1;
                            end if;
                        elsif cntr = 2 then
                            if data_ready = '1' then
                                cntr      <= 0;
                                en        <= '0';
                                state     <= S_MEASURE;
                                beginread <= '0';
                            end if;
                        end if;
                    end if;

                when S_MEASURE =>
                    if timer_rd_tick = '1' then
                        beginread <= '1';
                    end if;
                    if beginread = '1' then
                        case cntr is
                            when 0 =>
                                en        <= '1';
                                mosi_data <= x"0B";
                                if data_ready = '1' then
                                    mosi_data <= x"0E";
                                    cntr      <= cntr + 1;
                                end if;
                            when 1 =>
                                if data_ready = '1' then
                                    mosi_data <= x"00";
                                    cntr      <= cntr + 1;
                                end if;
                            when 2 =>
                                if data_ready = '1' then
                                    ax_o(7 downto 0) <= miso_data;
                                    cntr            <= cntr + 1;
                                end if;
                            when 3 =>
                                if data_ready = '1' then
                                    ax_o(15 downto 8) <= miso_data;
                                    cntr             <= cntr + 1;
                                end if;
                            when 4 =>
                                if data_ready = '1' then
                                    ay_o(7 downto 0) <= miso_data;
                                    cntr            <= cntr + 1;
                                end if;
                            when 5 =>
                                if data_ready = '1' then
                                    ay_o(15 downto 8) <= miso_data;
                                    cntr             <= cntr + 1;
                                end if;
                            when 6 =>
                                if data_ready = '1' then
                                    az_o(7 downto 0) <= miso_data;
                                    cntr            <= cntr + 1;
                                end if;
                            when 7 =>
                                if data_ready = '1' then
                                    az_o(15 downto 8) <= miso_data;
                                    ready_o          <= '1';
                                    en               <= '0';
                                    beginread        <= '0';
                                    cntr             <= 0;
                                end if;
                        end case;
                    end if;
            end case;
        end if;
    end process P_MAIN;

    P_TIMER_RD : process(clk_i)
    begin
        if rising_edge(clk_i) then
            if timer_rd = c_timer_rd_lim-1 then
                timer_rd      <= 0;
                timer_rd_tick <= '1';
            else
                timer_rd      <= timer_rd + 1;
                timer_rd_tick <= '0';
            end if;
        end if;
    end process P_TIMER_RD;

end Behavioral;
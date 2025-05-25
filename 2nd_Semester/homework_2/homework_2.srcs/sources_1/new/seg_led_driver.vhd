library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seg_led_driver is
    port(
        seg_in : in  std_logic_vector(6 downto 0);  -- Yedi segment sürücü çıkışı
        leds   : out std_logic_vector(6 downto 0)   -- Aynı veriyi gösterecek LED'ler
    );
end seg_led_driver;

architecture Behavioral of seg_led_driver is
begin
    leds <= seg_in;
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity main_top is
    generic (
        c_clkfreq  : integer := 100_000_000;
        c_sclkfreq : integer := 1_000_000;
        c_cpol     : std_logic := '0';
        c_cpha     : std_logic := '0';
        c_readfreq : integer := 2
    );
    port (
        clk       : in  std_logic;
        miso_i    : in  std_logic;
        mosi_o    : out std_logic;
        sclk_o    : out std_logic;
        cs_o      : out std_logic;
        seg_out   : out std_logic_vector(6 downto 0);
        leds      : out std_logic_vector(6 downto 0); 
        an        : out std_logic_vector(3 downto 0);
        sw        : in  std_logic_vector(2 downto 0)
    );
end main_top;

architecture Behavioral of main_top is

    -- Alt modül deklarasyonları
    component acc_reader is
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
    end component;

    component sevensegmentdecoder is
        port (
            bin_in  : in  std_logic_vector(3 downto 0);
            seg_out : out std_logic_vector(6 downto 0)
        );
    end component;

    component seg_led_driver is
        port(
            seg_in : in  std_logic_vector(6 downto 0);
            leds   : out std_logic_vector(6 downto 0)
        );
    end component;

    -- İç sinyal tanımlamaları
    signal ax, ay, az        : std_logic_vector(15 downto 0) := (others => '0');
    signal ready             : std_logic := '0';
    type digit_array_type is array (0 to 3) of std_logic_vector(3 downto 0);
    signal digit_values      : digit_array_type := (others => (others => '0'));
    signal active_digit      : integer range 0 to 3 := 0;
    signal timer1ms          : integer := 0;
    signal anodes            : std_logic_vector(3 downto 0) := "1111";
    signal current_digit     : std_logic_vector(3 downto 0);
    signal ax_scaled, ay_scaled, az_scaled : std_logic_vector(11 downto 0);
    signal axis_data         : std_logic_vector(15 downto 0);
    signal prev_sw           : std_logic_vector(2 downto 0) := "000";
    signal data_valid        : std_logic := '0';

begin

    -- ACC reader instantiation
    acc_reader_i : acc_reader
        generic map (
            c_clkfreq  => c_clkfreq,
            c_sclkfreq => c_sclkfreq,
            c_readfreq => c_readfreq,
            c_cpol     => c_cpol,
            c_cpha     => c_cpha
        )
        port map (
            clk_i   => clk,
            miso_i  => miso_i,
            mosi_o  => mosi_o,
            sclk_o  => sclk_o,
            cs_o    => cs_o,
            ax_o    => ax,
            ay_o    => ay,
            az_o    => az,
            ready_o => ready
        );

    -- Ölçeklendirme: 16-bit veriyi 12-bit'e indir (0-4095 arası)
    ax_scaled <= ax(15 downto 4);
    ay_scaled <= ay(15 downto 4);
    az_scaled <= az(15 downto 4);

    -- Veri güncelleme ve seçim
    process(clk)
    begin
        if rising_edge(clk) then
            if ready = '1' then
                data_valid <= '1';
                case sw is
                    when "001" => axis_data <= "0000" & ax_scaled; -- X ekseni
                    when "010" => axis_data <= "0000" & ay_scaled; -- Y ekseni
                    when "100" => axis_data <= "0000" & az_scaled; -- Z ekseni
                    when others => axis_data <= (others => '0');
                end case;
            end if;
            if sw /= prev_sw then
                prev_sw <= sw;
                data_valid <= '0';
            end if;
        end if;
    end process;

    -- BCD dönüşümü ve 7 segment güncelleme
    process(clk)
        variable temp : integer range 0 to 4095;
        variable hundreds, tens, ones : integer range 0 to 9;
    begin
        if rising_edge(clk) then
            if data_valid = '1' then
                temp := to_integer(unsigned(axis_data(11 downto 0)));
                hundreds := temp / 100;
                tens := (temp mod 100) / 10;
                ones := temp mod 10;

                digit_values(0) <= std_logic_vector(to_unsigned(ones, 4));
                digit_values(1) <= std_logic_vector(to_unsigned(tens, 4));
                digit_values(2) <= std_logic_vector(to_unsigned(hundreds, 4));
                digit_values(3) <= "0000";
            end if;
        end if;
    end process;

    -- Display refresh timer
    process(clk)
    begin
        if rising_edge(clk) then
            if timer1ms = c_clkfreq/1000 - 1 then
                timer1ms <= 0;
                active_digit <= (active_digit + 1) mod 4;
                anodes <= "1111";
                anodes(active_digit) <= '0';
                current_digit <= digit_values(active_digit);
            else
                timer1ms <= timer1ms + 1;
            end if;
        end if;
    end process;

    -- 7-segment decoder instantiation
    sevenseg_inst : sevensegmentdecoder
        port map (
            bin_in  => current_digit,
            seg_out => seg_out
        );
    -- Anot sinyalleri
    an <= anodes;

end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_module is
    port (
        CLK100MHZ    : in std_logic;
        UART_TXD_IN  : in std_logic;
        BTNC         : in std_logic;  -- Button to cycle through numbers
        SEG_OUT      : out std_logic_vector(6 downto 0);
        AN           : out std_logic_vector(7 downto 0)
    );
end top_module;

architecture Behavioral of top_module is
    type matrix_3x3 is array (0 to 2, 0 to 2) of integer range 0 to 99;
    signal rx_done_tick : std_logic;
    signal uart_dout    : std_logic_vector(7 downto 0);
    signal digit1_value : std_logic_vector(3 downto 0);
    signal digit2_value : std_logic_vector(3 downto 0);
    signal matrix       : matrix_3x3 := ((0, 0, 0), (0, 0, 0), (0, 0, 0));
    signal matrix_index : integer range 0 to 8 := 0;
    signal matrix_filled : std_logic := '0';
    signal current_number : integer range 0 to 99 := 0;
    signal number_ready  : std_logic := '0';
    signal anode_select  : std_logic := '0';
    signal display_digit : std_logic_vector(3 downto 0);
    signal digit_count   : integer range 0 to 1 := 0;
    signal display_index : integer range 0 to 8 := 0;
    signal display_number : integer range 0 to 99 := 0;
    signal btnc_debounced : std_logic := '0';
    signal btnc_prev      : std_logic := '0';
begin

    uart_rx_inst : entity work.uart_rx
        generic map (
            c_clkfreq  => 100_000_000,
            c_baudrate => 115_200
        )
        port map (
            clk            => CLK100MHZ,
            rx_i           => UART_TXD_IN,
            rx_done_tick_o => rx_done_tick,
            dout_o         => uart_dout
        );

    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            if rx_done_tick = '1' then
                if uart_dout >= x"30" and uart_dout <= x"39" then
                    if digit_count = 0 then
                        current_number <= (to_integer(unsigned(uart_dout)) - 48) * 10;
                        digit_count <= 1;
                    else
                        current_number <= current_number + (to_integer(unsigned(uart_dout)) - 48);
                        digit_count <= 0;
                        number_ready <= '1';
                    end if;
                elsif uart_dout = x"0D" or uart_dout = x"0A" then
                    if digit_count = 1 then
                        current_number <= current_number / 10;
                        digit_count <= 0;
                        number_ready <= '1';
                    end if;
                end if;
            end if;

            if number_ready = '1' then
                matrix(matrix_index / 3, matrix_index mod 3) <= current_number;
                if matrix_index < 8 then
                    matrix_index <= matrix_index + 1;
                else
                    matrix_filled <= '1';
                end if;
                current_number <= 0;
                number_ready <= '0';
            end if;
        end if;
    end process;

    process(CLK100MHZ)
        variable counter : integer := 0;
    begin
        if rising_edge(CLK100MHZ) then
            if counter = 50000 then
                counter := 0;
                anode_select <= not anode_select;
            else
                counter := counter + 1;
            end if;
        end if;
    end process;

    process(CLK100MHZ)
    begin
        if rising_edge(CLK100MHZ) then
            btnc_prev <= BTNC;
            if BTNC = '1' and btnc_prev = '0' then
                if display_index < 8 then
                    display_index <= display_index + 1;
                else
                    display_index <= 0;
                end if;
            end if;
        end if;
    end process;

    display_number <= matrix(display_index / 3, display_index mod 3);

    digit2_value <= std_logic_vector(to_unsigned(display_number / 10, 4));
    digit1_value <= std_logic_vector(to_unsigned(display_number mod 10, 4));

    display_digit <= digit1_value when anode_select = '0' else digit2_value;

    sevenseg_inst : entity work.sevensegmentdecoder
        port map (
            bin_in  => display_digit,
            seg_out => SEG_OUT
        );

    AN <= "11111110" when anode_select = '0' else "11111101";

end Behavioral;
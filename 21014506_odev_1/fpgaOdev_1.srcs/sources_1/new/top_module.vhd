library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_module is
    port (
        CLK100MHZ    : in std_logic;
        UART_TXD_IN  : in std_logic;
        BTNC         : in std_logic;
        BTNU         : in std_logic;
        BTND         : in std_logic;
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
    signal display_index : integer range 0 to 2 := 0;
    signal display_number : integer range 0 to 99 := 0;
    signal btnc_debounced : std_logic := '0';
    signal btnc_prev      : std_logic := '0';
    signal btnu_debounced : std_logic := '0';
    signal btnu_prev      : std_logic := '0';
    signal btnd_debounced : std_logic := '0';
    signal btnd_prev      : std_logic := '0';
    signal transpose_mode : std_logic := '0';
    signal current_row    : integer range 0 to 2 := 0;
    signal current_col    : integer range 0 to 2 := 0;
    signal display_matrix : matrix_3x3;
    signal digit_index : integer range 0 to 7 := 0;
    signal digit_values : std_logic_vector(31 downto 0);
begin

    -- UART Receiver
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

    -- UART Data
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
    begin
        if rising_edge(CLK100MHZ) then
            btnc_prev <= BTNC;
            btnu_prev <= BTNU;
            btnd_prev <= BTND;

            if BTNC = '1' and btnc_prev = '0' then
                transpose_mode <= not transpose_mode;
            end if;

            if BTNU = '1' and btnu_prev = '0' then
                if current_row > 0 then
                    current_row <= current_row - 1;
                else
                    current_row <= 2;
                end if;
            end if;

            if BTND = '1' and btnd_prev = '0' then
                if current_row < 2 then
                    current_row <= current_row + 1;
                else
                    current_row <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Transpose
    process(matrix, transpose_mode)
    begin
        if transpose_mode = '0' then
            display_matrix <= matrix;
        else
            for i in 0 to 2 loop
                for j in 0 to 2 loop
                    display_matrix(i, j) <= matrix(j, i);
                end loop;
            end loop;
        end if;
    end process;

    process(display_matrix, current_row)
    begin
        -- Leftmost number (displays 6 and 7)
        digit_values(31 downto 28) <= std_logic_vector(to_unsigned(display_matrix(current_row, 0) / 10, 4));  -- Tens place
        digit_values(27 downto 24) <= std_logic_vector(to_unsigned(display_matrix(current_row, 0) mod 10, 4));  -- Units place

        -- Blank display 5
        digit_values(23 downto 20) <= "1111";  -- Blank (all segments off)

        -- Center number (displays 3 and 4)
        digit_values(19 downto 16) <= std_logic_vector(to_unsigned(display_matrix(current_row, 1) / 10, 4));  -- Tens place
        digit_values(15 downto 12) <= std_logic_vector(to_unsigned(display_matrix(current_row, 1) mod 10, 4));  -- Units place

        -- Blank display 2
        digit_values(11 downto 8) <= "1111";  -- Blank (all segments off)

        -- Rightmost number (displays 0 and 1)
        digit_values(7 downto 4) <= std_logic_vector(to_unsigned(display_matrix(current_row, 2) / 10, 4));  -- Tens place
        digit_values(3 downto 0) <= std_logic_vector(to_unsigned(display_matrix(current_row, 2) mod 10, 4));  -- Units place
    end process;

    process(CLK100MHZ)
        variable counter : integer := 0;
    begin
        if rising_edge(CLK100MHZ) then
            if counter = 10000 then
                counter := 0;
                digit_index <= (digit_index + 1) mod 8;
            else
                counter := counter + 1;
            end if;
        end if;
    end process;

    display_digit <= digit_values(4*digit_index + 3 downto 4*digit_index);

    sevenseg_inst : entity work.sevensegmentdecoder
        port map (
            bin_in  => display_digit,
            seg_out => SEG_OUT
        );

    AN <= "01111111" when digit_index = 7 else  -- Display 7 (leftmost tens)
          "10111111" when digit_index = 6 else  -- Display 6 (leftmost units)
          "11011111" when digit_index = 5 else  -- Display 5 (blank)
          "11101111" when digit_index = 4 else  -- Display 4 (center tens)
          "11110111" when digit_index = 3 else  -- Display 3 (center units)
          "11111011" when digit_index = 2 else  -- Display 2 (blank)
          "11111101" when digit_index = 1 else  -- Display 1 (rightmost tens)
          "11111110";                           -- Display 0 (rightmost units)

end Behavioral;
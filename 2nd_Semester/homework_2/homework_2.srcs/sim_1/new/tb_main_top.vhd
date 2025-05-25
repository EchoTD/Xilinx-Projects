library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_main_top is
end tb_main_top;

architecture sim of tb_main_top is
    --------------------------------------------------------------------------
    --  constants you may tweak
    --------------------------------------------------------------------------
    constant CLK_FREQ   : integer := 100_000_000; -- Hz
    constant SCLK_FREQ  : integer :=   1_000_000; -- Hz  (must match generics)
    constant READ_FREQ  : integer :=         100; -- Hz  (driver generic)

    -- sample values to be returned by the "sensor"  (signed 12-bit left-just.)
    constant X_SAMPLE : signed(11 downto 0) := to_signed( +123, 12); -- 0x007B
    constant Y_SAMPLE : signed(11 downto 0) := to_signed( -456, 12); -- 0xE408
    constant Z_SAMPLE : signed(11 downto 0) := to_signed( +789, 12); -- 0x0315
    --------------------------------------------------------------------------

    signal clk      : std_logic := '0';
    signal miso_i   : std_logic := '1';     -- pulled-up when idle
    signal mosi_o   : std_logic;
    signal sclk_o   : std_logic;
    signal cs_o     : std_logic;
    signal seg_out  : std_logic_vector(6 downto 0);
    signal leds     : std_logic_vector(6 downto 0);
    signal an       : std_logic_vector(3 downto 0);
    signal sw       : std_logic_vector(2 downto 0) := "001";

    --------------------------------------------------------------------------
    --  procedure : wait_clocks  (helper)
    --------------------------------------------------------------------------
    procedure wait_clocks (constant n : natural) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clk);
        end loop;
    end procedure;

begin
    --------------------------------------------------------------------------
    --  clock generation
    --------------------------------------------------------------------------
    clk <= not clk after 5 ns;   -- 100 MHz

    --------------------------------------------------------------------------
    --  DUT  :  your top level ------------------------------------------------
    --------------------------------------------------------------------------
    dut : entity work.main_top
        generic map (
            c_clkfreq  => CLK_FREQ,
            c_sclkfreq => SCLK_FREQ,
            c_readfreq => READ_FREQ,
            c_cpol     => '0',
            c_cpha     => '0'
        )
        port map (
            clk     => clk,
            miso_i  => miso_i,
            mosi_o  => mosi_o,
            sclk_o  => sclk_o,
            cs_o    => cs_o,
            seg_out => seg_out,
            leds    => leds,
            an      => an,
            sw      => sw
        );

    --------------------------------------------------------------------------
    --  very small behavioural ADXL362 model (enough for this homework)
    --------------------------------------------------------------------------
    sensor : process
        type byte_array is array(natural range <>) of std_logic_vector(7 downto 0);
        -- helper : shove 16-bit words (MSB first) into an array
        impure function burst_from_xyz return byte_array is
            variable b : byte_array(0 to 7);
            variable xs,ys,zs : std_logic_vector(15 downto 0);
        begin
            xs := std_logic_vector(shift_left(resize(X_SAMPLE,16),4));
            ys := std_logic_vector(shift_left(resize(Y_SAMPLE,16),4));
            zs := std_logic_vector(shift_left(resize(Z_SAMPLE,16),4));
            b(0) := xs(7 downto 0);  b(1) := xs(15 downto 8);
            b(2) := ys(7 downto 0);  b(3) := ys(15 downto 8);
            b(4) := zs(7 downto 0);  b(5) := zs(15 downto 8);
            b(6) := x"00";           b(7) := x"00";        -- TEMP dummy
            return b;
        end;
        constant data_burst : byte_array := burst_from_xyz;

        variable bit_cntr   : integer := 0;
        variable byte_cntr  : integer := 0;
        variable shift_reg  : std_logic_vector(7 downto 0) := (others=>'0');
        variable cmd_buf    : byte_array(0 to 1);  -- command + address
        variable cmd_idx    : integer := 0;
        variable reading    : boolean := false;
    begin
        wait until cs_o = '0';             -- start of SPI frame
        bit_cntr  := 7;
        byte_cntr := 0;
        cmd_idx   := 0;
        reading   := false;
        ------------------------------------------------------------------
        -- consume / emit until CS goes high
        ------------------------------------------------------------------
        while cs_o = '0' loop
            -- wait for sampling edge (CPOL=0, CPHA=0  ==>  rising edge)
            wait until rising_edge(sclk_o);
            -- shift-in MOSI
            shift_reg(bit_cntr) := mosi_o;
            -- shift-out MISO
            if reading then
                miso_i <= data_burst(byte_cntr)(bit_cntr);
            else
                miso_i <= '0';
            end if;

            if bit_cntr = 0 then       -- byte finished
                -- capture command bytes
                if byte_cntr < 2 then
                    cmd_buf(byte_cntr) := shift_reg;
                end if;

                byte_cntr := byte_cntr + 1;
                bit_cntr  := 7;
                -- decide whether next byte should be read-data
                if byte_cntr = 2 then
                    if cmd_buf(0) = x"0B" and cmd_buf(1) = x"0E" then
                        reading := true;       -- subsequent bytes come from burst
                    end if;
                end if;
            else
                bit_cntr := bit_cntr - 1;
            end if;
        end loop;
        miso_i <= '1';                            -- idle high
    end process sensor;

    --------------------------------------------------------------------------
    --  stimulus : move the DIP-switch every 40 ms
    --------------------------------------------------------------------------
    stim : process
    begin
        wait_clocks( READ_FREQ * 2 );  -- wait a couple of read periods
        sw <= "010";                   -- show Y
        wait_clocks( READ_FREQ * 2 );
        sw <= "100";                   -- show Z
        wait_clocks( READ_FREQ * 2 );
        sw <= "001";                   -- back to X
        wait_clocks( READ_FREQ * 2 );
        std.env.stop;                  -- finish sim
    end process;

    --------------------------------------------------------------------------
    --  checker : look at the decoded digit when an(0) = '0'
    --------------------------------------------------------------------------
    check : process
        -- seg pattern for decimal 0-9 (same table you used)
        type lut is array(0 to 9) of std_logic_vector(6 downto 0);
        constant pat : lut := ( "1000000","1111001","0100100","0110000",
                                "0011001","0010010","0000010","1111000",
                                "0000000","0010000");
        function decode(b : std_logic_vector(6 downto 0)) return integer is
        begin
            for i in pat'range loop
                if b = pat(i) then return i; end if;
            end loop;
            return -1;
        end;
        variable value : integer;
    begin
        wait until an(0) = '0';                -- right-most digit is active
        value := decode(seg_out);
        report "digit = " & integer'image(value);
        if value /= abs(to_integer(X_SAMPLE) mod 10) then
            assert false report "FAIL - wrong digit shown" severity failure;
        end if;
        wait;   -- stop this process
    end process;
end sim;

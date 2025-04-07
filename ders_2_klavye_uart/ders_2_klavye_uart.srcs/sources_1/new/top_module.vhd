library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_module is
    port (
        CLK100MHZ    : in std_logic;                     -- System clock
        PS2_CLK      : in std_logic;                     -- PS/2 clock signal
        PS2_DATA     : in std_logic;                     -- PS/2 data signal
        SEG_OUT      : out std_logic_vector(6 downto 0); -- Seven-segment output (a-g)
        AN           : out std_logic_vector(7 downto 0)  -- Anode control for 7-segment display
    );
end top_module;

architecture Behavioral of top_module is
    signal scan_code   : std_logic_vector(7 downto 0);
begin

    ps2_rx_inst : entity work.ps2_rx
        port map (
            clk         => CLK100MHZ,
            ps2_clk     => PS2_CLK,
            ps2_data    => PS2_DATA,
            scan_code   => scan_code
        );


    seven_segment_inst : entity work.seven_segment
        port map (
            clk       => CLK100MHZ,
            scan_code => scan_code,
            seg_out   => SEG_OUT,
            an        => AN
        );

end Behavioral;
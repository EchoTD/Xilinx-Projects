--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
--Date        : Wed Nov  6 09:52:43 2024
--Host        : echo-x250 running 64-bit Arch Linux
--Command     : generate_target design_1.bd
--Design      : design_1
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1 is
  port (
    x1_0 : in STD_LOGIC;
    x2_0 : in STD_LOGIC;
    xOut_0 : out STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of design_1 : entity is "design_1,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_1,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=4,numReposBlks=4,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=3,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of design_1 : entity is "design_1.hwdef";
end design_1;

architecture STRUCTURE of design_1 is
  component design_1_xlconstant_0_0 is
  port (
    dout : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_1_xlconstant_0_0;
  component design_1_week6_0_0 is
  port (
    x1 : in STD_LOGIC;
    x2 : in STD_LOGIC;
    xOut : out STD_LOGIC
  );
  end component design_1_week6_0_0;
  component design_1_week6_0_1 is
  port (
    x1 : in STD_LOGIC;
    x2 : in STD_LOGIC;
    xOut : out STD_LOGIC
  );
  end component design_1_week6_0_1;
  component design_1_week6_0_2 is
  port (
    x1 : in STD_LOGIC;
    x2 : in STD_LOGIC;
    xOut : out STD_LOGIC
  );
  end component design_1_week6_0_2;
  signal week6_0_xOut : STD_LOGIC;
  signal week6_1_xOut : STD_LOGIC;
  signal week6_2_xOut : STD_LOGIC;
  signal x1_0_1 : STD_LOGIC;
  signal x2_0_1 : STD_LOGIC;
  signal xlconstant_0_dout : STD_LOGIC_VECTOR ( 0 to 0 );
begin
  x1_0_1 <= x1_0;
  x2_0_1 <= x2_0;
  xOut_0 <= week6_2_xOut;
week6_0: component design_1_week6_0_0
     port map (
      x1 => x1_0_1,
      x2 => xlconstant_0_dout(0),
      xOut => week6_0_xOut
    );
week6_1: component design_1_week6_0_1
     port map (
      x1 => xlconstant_0_dout(0),
      x2 => x2_0_1,
      xOut => week6_1_xOut
    );
week6_2: component design_1_week6_0_2
     port map (
      x1 => week6_0_xOut,
      x2 => week6_1_xOut,
      xOut => week6_2_xOut
    );
xlconstant_0: component design_1_xlconstant_0_0
     port map (
      dout(0) => xlconstant_0_dout(0)
    );
end STRUCTURE;

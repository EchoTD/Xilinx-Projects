--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
--Date        : Wed Nov  6 09:52:43 2024
--Host        : echo-x250 running 64-bit Arch Linux
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_wrapper is
  port (
    x1_0 : in STD_LOGIC;
    x2_0 : in STD_LOGIC;
    xOut_0 : out STD_LOGIC
  );
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  port (
    xOut_0 : out STD_LOGIC;
    x1_0 : in STD_LOGIC;
    x2_0 : in STD_LOGIC
  );
  end component design_1;
begin
design_1_i: component design_1
     port map (
      x1_0 => x1_0,
      x2_0 => x2_0,
      xOut_0 => xOut_0
    );
end STRUCTURE;

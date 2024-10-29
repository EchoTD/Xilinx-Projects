-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
-- Date        : Tue Oct 29 19:48:35 2024
-- Host        : echo-x250 running 64-bit Arch Linux
-- Command     : write_vhdl -mode funcsim -nolib -force -file {/home/acg/Desktop/Xilinx
--               Projects/firstProject/firstProject.sim/sim_1/synth/func/xsim/logic_ex_func_synth.vhd}
-- Design      : logic_ex
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7a100tcsg324-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity logic_ex is
  port (
    SW : in STD_LOGIC;
    LED : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of logic_ex : entity is true;
end logic_ex;

architecture STRUCTURE of logic_ex is
  signal LED_OBUF : STD_LOGIC;
  signal SW_IBUF : STD_LOGIC;
begin
LED_OBUF_inst: unisim.vcomponents.OBUF
     port map (
      I => LED_OBUF,
      O => LED
    );
LED_OBUF_inst_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => SW_IBUF,
      O => LED_OBUF
    );
SW_IBUF_inst: unisim.vcomponents.IBUF
    generic map(
      CCIO_EN => "TRUE"
    )
        port map (
      I => SW,
      O => SW_IBUF
    );
end STRUCTURE;

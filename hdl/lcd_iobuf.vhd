-------------------------------------------------------------------------------
-- Title      : IOBUF - because Vivado does not know how
-- Project    : 
-------------------------------------------------------------------------------
-- File       : lcd_iobuf.vhd
-- Author     : Gary Helbig  <ghelbig@designedtowork.com>
-- Company    : 
-- Created    : 2023-08-13
-- Last update: 2023-08-14
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Build a bus-wide io buffer
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-08-13  1.0      ghelbig Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity lcd_iobuf is
  generic (WIDTH : integer := 8);
  port (
    lcd_io : inout std_logic_vector(WIDTH-1 downto 0);  -- The FPGA pin
    lcd_di : in    std_logic_vector(WIDTH-1 downto 0);  -- Data to the TFT
    lcd_do : out   std_logic_vector(WIDTH-1 downto 0);  -- Data from the TFT
    lcd_dt : in    std_logic            -- Transmit (to the tft)
    );
end lcd_iobuf;

architecture gen of lcd_iobuf is

  component IOBUF is
    port(
      O  : out   std_ulogic;
      IO : inout std_ulogic;
      I  : in    std_ulogic;
      T  : in    std_ulogic
      );
  end component IOBUF;

begin
  iobufs : for I in 0 to WIDTH-1 generate
    IOBUF_inst : IOBUF
      -- generic map (
      --   DRIVE      => 12,
      --   IOSTANDARD => 'DEFAULT',
      --   SLEW       => 'SLOW')
      port map (
        O  => lcd_do(I),
        I  => lcd_di(I),
        IO => lcd_io(I),
        T  => lcd_dt);
  end generate iobufs;
end architecture gen;




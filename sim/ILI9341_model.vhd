-------------------------------------------------------------------------------
-- Title      : ILI3941 Model
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ILI9341_model.vhd
-- Author     : Gary Helbig  <ghelbig@designedtowork.com>
-- Company    : 
-- Created    : 2023-08-06
-- Last update: 2023-08-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Try to look like the chip on the board
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-08-06  1.0      ghelbig Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;        -- @suppress "Deprecated package"
--use ieee.std_logic_textio.all;
use std.textio.all;
use work.text_pack.all;

entity ILI9341 is
  port (
    lcd_d   : inout std_logic_vector(7 downto 0);
    lcd_rd  : in    std_logic;
    lcd_wr  : in    std_logic;
    lcd_rs  : in    std_logic;
    lcd_cs  : in    std_logic;
    lcd_rst : in    std_logic
    );
end ILI9341;

architecture behave of ILI9341 is

  type read_state_t is (IDLE, READ_ID4);
  signal read_state : read_state_t := IDLE;
  signal read_data  : std_logic_vector(7 downto 0);
  signal param_num  : unsigned(3 downto 0);

  constant T_WRL : time := 15 ns; -- Write Low Time
  constant T_WRH : time := 15 ns; -- Write High Time
  constant T_RDL : time := 45 ns;
  constant T_WCS : time := 15 ns;
  constant T_RCS : time := 45 ns;
  constant T_WRC : time := 66 ns; -- Twc - Write Cycle

begin

  assert false report "ILI9341 Model active" severity note;

  lcd_d <= read_data when lcd_rd = '0' else "ZZZZZZZZ";

  -- purpose: Read Cycle
  -- type   : sequential
  -- inputs : lcd_rd, lcd_rst, lcd_rs, lcd_cs
  -- outputs: open
  ili_read : process (lcd_rd, lcd_rst) is
  begin  -- process ili_read
    if lcd_rst = '0' then

    elsif falling_edge(lcd_rd) then
      if lcd_rs = '1' then
--        report "ILI9341 Data Read";
        case (READ_STATE) is
          when READ_ID4 =>
            case (param_num) is
              when "0000" => read_data <= "XXXXXXXX"; --report "word 0";
              when "0001" => read_data <= "XXXXXXXX", "00000000" after 40 ns; --report "word 1";
              when "0010" => read_data <= "XXXXXXXX", "10010011" after 40 ns; --report "word 2";
              when "0011" => read_data <= "XXXXXXXX", "01000001" after 40 ns; --report "word 3";
              when others => read_data <= "XXXXXXXX";
            end case;
          when others => read_data <= "XXXXXXXX";
        end case;

      else
        report "ILI9341 Command Read";
      end if;
    end if;

  end process ili_read;

  -- purpose: Write Cycle
  -- type   : sequential
  -- inputs : lcd_rd, lcd_rst, lcd_rs, lcd_cs
  -- outputs: open
  ili_write : process (lcd_wr, lcd_rd, lcd_rst) is
  begin  -- process ili_write
    if lcd_rst = '0' then
      read_state <= IDLE;
    else
      if rising_edge(lcd_wr) then
        if lcd_rs = '1' then
          report "ILI9341 Data Write 0x" & to_hex_string(lcd_d);
        else
          report "ILI9341 Command Write 0x" & to_hex_string(lcd_d);
          case (lcd_d) is
            when X"D3" =>
              READ_STATE <= READ_ID4; -- report "hi there";
              param_num  <= (others => '0');
            when others =>
              READ_STATE <= IDLE;
              param_num  <= (others => '0');
          end case;
        end if;
      end if;

      if rising_edge(lcd_rd) then
        if lcd_rs = '1' then
          case (READ_STATE) is
            when READ_ID4 =>
              READ_STATE <= READ_ID4;
              param_num  <= param_num + 1; -- report "bump";
            when others =>
              null;
          end case;
        end if;
      end if;

    end if;
  end process ili_write;

  --  Be a good boy and check the pulse widths.
  --    Because the chip is SLOW.
  rd_width : process (lcd_rd) is
    variable f_time : time := 0 ns;
    variable l_time : time := 0 ns;
  begin
    if falling_edge(lcd_rd) then
      f_time := now;
    end if;
    if rising_edge(lcd_rd) then
      l_time       := now - f_time;
      assert
        T_RDL <= l_time
        report "RD low time = " & time'image(l_time)
        severity error;

    end if;
  end process rd_width;

  --  Be a good boy and check the pulse widths.
  --    Because the chip is SLOW.
  wr_width : process (lcd_wr) is
    variable f_time : time := 0 ns;
    variable r_time : time := 0 ns;
    variable l_time : time := 0 ns;
    variable h_time : time := 0 ns;
    variable c_time : time := 0 ns;
  begin
    if falling_edge(lcd_wr) then
      -- report "WR    falling edge @ " & time'image(now);
      -- report "prior falling edge @ " & time'image(f_time);
      c_time       := now - f_time;
      -- report "cycle time is          " & time'image(c_time);
      h_time := now - r_time;
      assert
        T_WRC <= c_time
        report "WR cycle time = " & time'image(c_time)
        severity error;
      assert
        T_WRH <= h_time
        report "WR high time = " & time'image(h_time)
        severity error;
      f_time := now;
    end if;
    if rising_edge(lcd_wr) then
      l_time       := now - f_time;
      assert
        T_WRL <= l_time
        report "WR low time = " & time'image(l_time)
        severity error;
      r_time := now;
    end if;
  end process wr_width;

  --  Be a good boy and check the pulse widths.
  --    Because the chip is SLOW.
  cswr_check : process (lcd_cs, lcd_wr) is
    variable f_time : time := 0 ns;
    variable l_time : time := 0 ns;
  begin
    if falling_edge(lcd_cs) then
      f_time := now;
    end if;
    if rising_edge(lcd_wr) then
      l_time       := now - f_time;
      assert
        T_WCS <= l_time
        report "Chip Select setup time (WR) = " & time'image(l_time)
        severity error;
    end if;
  end process cswr_check;

  --  Be a good boy and check the pulse widths.
  --    Because the chip is SLOW.
  csrd_check : process (lcd_cs, lcd_rd) is
    variable f_time : time := 0 ns;
    variable l_time : time := 0 ns;
  begin
    if falling_edge(lcd_cs) then
      f_time := now;
    end if;
    if rising_edge(lcd_rd) then
      l_time       := now - f_time;
      assert
        T_RCS <= l_time
        report "Chip Select setup time (RD) = " & time'image(l_time)
        severity error;
    end if;
  end process csrd_check;

end behave;

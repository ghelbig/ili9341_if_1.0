-------------------------------------------------------------------------------
-- Title      : Pretty Printout Routines
-- Project    : 
-------------------------------------------------------------------------------
-- File       : text_pack.vhd
-- Author     : Gary Helbig  <ghelbig@designedtowork.com>
-- Company    : 
-- Created    : 2019-11-04
-- Last update: 2023-08-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Text Printout Helpers
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-11-04  1.0      ghelbig Created
-------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.std_logic_textio.all;
use std.textio.all;

package text_pack is

  function to_bstring(sl : std_logic)
    return string;
  function to_bstring(slv : std_logic_vector)
    return string;

  function to_hex_string(s : in std_logic_vector)
    return string;

  procedure time_stamp (constant s : in string);

  procedure time_stamp (
    constant s : in string;
    signal   b : in std_logic
    );
  
  procedure time_stamp (
    constant s : in string;
    signal   v : in std_logic_vector
    );
  
end package text_pack;

package body text_pack is

  function to_bstring(sl : std_logic) return string is
    variable sl_str_v : string(1 to 3);  -- std_logic image with quotes around
  begin
    sl_str_v := std_logic'image(sl);
    return "" & sl_str_v(2);             -- "" & character to get string
  end function;

  function to_bstring(slv : std_logic_vector) return string is
    alias slv_norm    : std_logic_vector(1 to slv'length) is slv;
    variable sl_str_v : string(1 to 1);  -- String of std_logic
    variable res_v    : string(1 to slv'length);
  begin
    for idx in slv_norm'range loop
      sl_str_v   := to_bstring(slv_norm(idx));
      res_v(idx) := sl_str_v(1);
    end loop;
    return res_v;
  end function;

  function to_hex_string(s : in std_logic_vector)
    return string
  is
    --- Locals to make the indexing easier
    variable t, b   : integer;
    variable result : string (1 to s'length/4);
    --- A subtype to keep the VHDL compiler happy
    --- (the rules about data types in a CASE are quite strict)
    subtype slv4 is std_logic_vector(4 downto 1);
  begin

    assert (s'length mod 4) = 0
      report "SLV must be a multiple of 4 bits"
      severity failure;

    for i in result'range loop

      t := s'length-((i-1)*4)-1;
      b := s'length-((i-1)*4+3)-1;

      case slv4'(s(t downto b)) is
        when "0000" => result(i) := '0';
        when "0001" => result(i) := '1';
        when "0010" => result(i) := '2';
        when "0011" => result(i) := '3';
        when "0100" => result(i) := '4';
        when "0101" => result(i) := '5';
        when "0110" => result(i) := '6';
        when "0111" => result(i) := '7';
        when "1000" => result(i) := '8';
        when "1001" => result(i) := '9';
        when "1010" => result(i) := 'A';
        when "1011" => result(i) := 'B';
        when "1100" => result(i) := 'C';
        when "1101" => result(i) := 'D';
        when "1110" => result(i) := 'E';
        when "1111" => result(i) := 'F';
        when others => result(i) := 'U';
      end case;

    end loop;

    return result;

  end;

  procedure time_stamp(constant s : in string) is
    variable l : line;
  begin
    write (l, now, UNIT => ns);
    write (l, string'("> "));
    write (l, s);
    writeline (output, l);
  end procedure time_stamp;

  procedure time_stamp (
    constant s : in string;
    signal   b : in std_logic
    ) is
    variable l : line;
  begin
    write (l, now, UNIT => ns);
    write (l, string'("> "));
    write (l, s);
    write (l, string'(" 0b"));
    write (l, b);
    writeline (output, l);
  end procedure time_stamp;
    
  procedure time_stamp (
    constant s : in string;
    signal v   : in std_logic_vector
    ) is
    variable l : line;
  begin
    write (l, now, UNIT => ns);
    write (l, string'("> "));
    write (l, s);
    if (v'length mod 4) = 0 and
       (v(v'length-1) = '0' or v(v'length-1) = '1') and
       (v(v'length-2) = '0' or v(v'length-2) = '1') then
      write (l, string'(" 0x"));
      write (l, to_hex_string(v));
    else
      write (l, string'(" 0b"));
      write (l, to_bstring(v));
    end if;
    writeline (output, l);
  end procedure time_stamp;
    


  
end package body text_pack;

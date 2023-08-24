-------------------------------------------------------------------------------
-- Title      : ili9341_if Test Bench
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ili9341_if_v1_0_tb.vhd
-- Author     : Gary Helbig  <ghelbig@designedtowork.com>
-- Company    : 
-- Created    : 2023-08-05
-- Last update: 2023-08-21
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Gotta test it, eh?
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-08-05  1.0      ghelbig Created
-------------------------------------------------------------------------------

-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

use work.axi4_pack.all;
use work.text_pack.all;

entity ili9341_if_v1_0_tb is
end;

architecture bench of ili9341_if_v1_0_tb is

  component ili9341_if_v1_0
    generic (
      RD_CLOCKS            : integer := 5;  -- 100 MHz
      WR_CLOCKS            : integer := 2;  -- 100 MHz
      WR_CYCLE  : integer := 3;
      C_S00_AXI_DATA_WIDTH : integer := 32;
      C_S00_AXI_ADDR_WIDTH : integer := 4
      );
    port (
      lcd_d           : inout std_logic_vector(7 downto 0);
      lcd_rd          : out   std_logic;
      lcd_wr          : out   std_logic;
      lcd_rs          : out   std_logic;
      lcd_cs          : out   std_logic;
      lcd_rst         : out   std_logic;
    -- debug pins
    lcd_ddo  : out   std_logic_vector(7 downto 0);
    lcd_ddi  : out   std_logic_vector(7 downto 0);
    lcd_ddt  : out   std_logic;
      s00_axi_aclk    : in    std_logic;
      s00_axi_aresetn : in    std_logic;
      s00_axi_awaddr  : in    std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
      s00_axi_awprot  : in    std_logic_vector(2 downto 0);
      s00_axi_awvalid : in    std_logic;
      s00_axi_awready : out   std_logic;
      s00_axi_wdata   : in    std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
      s00_axi_wstrb   : in    std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
      s00_axi_wvalid  : in    std_logic;
      s00_axi_wready  : out   std_logic;
      s00_axi_bresp   : out   std_logic_vector(1 downto 0);
      s00_axi_bvalid  : out   std_logic;
      s00_axi_bready  : in    std_logic;
      s00_axi_araddr  : in    std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
      s00_axi_arprot  : in    std_logic_vector(2 downto 0);
      s00_axi_arvalid : in    std_logic;
      s00_axi_arready : out   std_logic;
      s00_axi_rdata   : out   std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
      s00_axi_rresp   : out   std_logic_vector(1 downto 0);
      s00_axi_rvalid  : out   std_logic;
      s00_axi_rready  : in    std_logic
      );
  end component ili9341_if_v1_0;

  component ILI9341
    port (
      lcd_d   : inout std_logic_vector(7 downto 0);
      lcd_rd  : in    std_logic;
      lcd_wr  : in    std_logic;
      lcd_rs  : in    std_logic;
      lcd_cs  : in    std_logic;
      lcd_rst : in    std_logic
      );
  end component ILI9341;

  constant S00_AXI_DATA_WIDTH : integer := 32;
  constant S00_AXI_ADDR_WIDTH : integer := 4;

  signal lcd_d           : std_logic_vector(7 downto 0);
  signal lcd_rd          : std_logic;
  signal lcd_wr          : std_logic;
  signal lcd_rs          : std_logic;
  signal lcd_cs          : std_logic;
  signal lcd_rst         : std_logic;
signal      lcd_dd          : std_logic_vector(7 downto 0); -- data debug
  signal s00_axi_aclk    : std_logic := '0';
  signal s00_axi_aresetn : std_logic := '0';
  signal s00_axi_awaddr  : std_logic_vector(S00_AXI_ADDR_WIDTH-1 downto 0);
  signal s00_axi_awprot  : std_logic_vector(2 downto 0);
  signal s00_axi_awvalid : std_logic;
  signal s00_axi_awready : std_logic;
  signal s00_axi_wdata   : std_logic_vector(S00_AXI_DATA_WIDTH-1 downto 0);
  signal s00_axi_wstrb   : std_logic_vector((S00_AXI_DATA_WIDTH/8)-1 downto 0);
  signal s00_axi_wvalid  : std_logic;
  signal s00_axi_wready  : std_logic;
  signal s00_axi_bresp   : std_logic_vector(1 downto 0);
  signal s00_axi_bvalid  : std_logic;
  signal s00_axi_bready  : std_logic;
  signal s00_axi_araddr  : std_logic_vector(S00_AXI_ADDR_WIDTH-1 downto 0);
  signal s00_axi_arprot  : std_logic_vector(2 downto 0);
  signal s00_axi_arvalid : std_logic;
  signal s00_axi_arready : std_logic;
  signal s00_axi_rdata   : std_logic_vector(S00_AXI_DATA_WIDTH-1 downto 0);
  signal s00_axi_rresp   : std_logic_vector(1 downto 0);
  signal s00_axi_rvalid  : std_logic;
  signal s00_axi_rready  : std_logic;

  signal sim_active : boolean := true;

  constant ACLK_PERIOD : time := 10.000 ns;  -- 100Mhz
--  constant ACLK_PERIOD : time := 7.500000 ns;  -- 133Mhz
--  constant ACLK_PERIOD : time := 6.666667 ns;  -- 150Mhz

  signal tb_addr  : std_logic_vector(S00_AXI_ADDR_WIDTH-1 downto 0);
  signal tb_rdata : std_logic_vector(S00_AXI_DATA_WIDTH-1 downto 0);
  signal tb_wdata : std_logic_vector(S00_AXI_DATA_WIDTH-1 downto 0);
  -- signal tb_awaddr  : std_logic_vector(S00_AXI_ADDR_WIDTH-1 downto 0);

  -- debug pins
  signal  lcd_ddo  :    std_logic_vector(7 downto 0);
  signal  lcd_ddi  :    std_logic_vector(7 downto 0);
  signal  lcd_ddt  :    std_logic;

begin

  s00_axi_aclk    <= not s00_axi_aclk after ACLK_PERIOD/2 when sim_active else '0';
  s00_axi_aresetn <= '0', '1'         after 125 ns;

  -- Insert values for generic parameters !!
  uut : ili9341_if_v1_0
    generic map (
      RD_CLOCKS            => 5,        -- 100 MHz
      WR_CLOCKS            => 4,        -- 100 MHz
      WR_CYCLE             => 3,
      C_S00_AXI_DATA_WIDTH => S00_AXI_DATA_WIDTH,
      C_S00_AXI_ADDR_WIDTH => S00_AXI_ADDR_WIDTH)
    port map (lcd_d           => lcd_d,
              lcd_rd          => lcd_rd,
              lcd_wr          => lcd_wr,
              lcd_rs          => lcd_rs,
              lcd_cs          => lcd_cs,
              lcd_rst         => lcd_rst,
    -- debug pins
    lcd_ddo  => lcd_ddo,
    lcd_ddi  => lcd_ddi,
    lcd_ddt  => lcd_ddt,
              s00_axi_aclk    => s00_axi_aclk,
              s00_axi_aresetn => s00_axi_aresetn,
              s00_axi_awaddr  => s00_axi_awaddr,
              s00_axi_awprot  => s00_axi_awprot,
              s00_axi_awvalid => s00_axi_awvalid,
              s00_axi_awready => s00_axi_awready,
              s00_axi_wdata   => s00_axi_wdata,
              s00_axi_wstrb   => s00_axi_wstrb,
              s00_axi_wvalid  => s00_axi_wvalid,
              s00_axi_wready  => s00_axi_wready,
              s00_axi_bresp   => s00_axi_bresp,
              s00_axi_bvalid  => s00_axi_bvalid,
              s00_axi_bready  => s00_axi_bready,
              s00_axi_araddr  => s00_axi_araddr,
              s00_axi_arprot  => s00_axi_arprot,
              s00_axi_arvalid => s00_axi_arvalid,
              s00_axi_arready => s00_axi_arready,
              s00_axi_rdata   => s00_axi_rdata,
              s00_axi_rresp   => s00_axi_rresp,
              s00_axi_rvalid  => s00_axi_rvalid,
              s00_axi_rready  => s00_axi_rready);

  lcd : ILI9341
    port map (
      lcd_d   => lcd_d,
      lcd_rd  => lcd_rd,
      lcd_wr  => lcd_wr,
      lcd_rs  => lcd_rs,
      lcd_cs  => lcd_cs,
      lcd_rst => lcd_rst);


  stimulus : process
    variable i : integer;
  begin
    wait until rising_edge(s00_axi_aresetn);
    wait until falling_edge(s00_axi_aclk);

    -- Put initialisation code here

    s00_axi_awprot  <= (others => '0');
    s00_axi_arprot  <= (others => '0');
    s00_axi_wstrb   <= (others => '0');
    s00_axi_bready  <= '1';
    s00_axi_arvalid <= '0';
    s00_axi_rready  <= '1';

    wait for 1 us;

    -- Put test bench stimulus code here

    --  Assert reset
    axi4_write (
      addr      => (3 => '1', others => '0'),
      data      => X"00000001",
      wstrobe   => "0001",
      a_clock   => s00_axi_aclk,
      a_addr    => s00_axi_awaddr,
      a_data    => s00_axi_wdata,
      a_wstrobe => s00_axi_wstrb,
      a_awvalid => s00_axi_awvalid,
      a_wvalid  => s00_axi_wvalid,
      a_wready  => s00_axi_wready,
      a_bvalid  => s00_axi_bvalid,
      a_awready => s00_axi_awready
      );
    
    --  Remove reset
    axi4_write (
      addr      => (3 => '1', others => '0'),
      data      => X"00000000",
      wstrobe   => "0001",
      a_clock   => s00_axi_aclk,
      a_addr    => s00_axi_awaddr,
      a_data    => s00_axi_wdata,
      a_wstrobe => s00_axi_wstrb,
      a_awvalid => s00_axi_awvalid,
      a_wvalid  => s00_axi_wvalid,
      a_wready  => s00_axi_wready,
      a_bvalid  => s00_axi_bvalid,
      a_awready => s00_axi_awready
      );

    --  Exercise word register
    axi4_write (
      addr      => (3 => '1', 2 => '1', others => '0'),
      data      => X"deadbeef",
      wstrobe   => "0011",
      a_clock   => s00_axi_aclk,
      a_addr    => s00_axi_awaddr,
      a_data    => s00_axi_wdata,
      a_wstrobe => s00_axi_wstrb,
      a_awvalid => s00_axi_awvalid,
      a_wvalid  => s00_axi_wvalid,
      a_wready  => s00_axi_wready,
      a_bvalid  => s00_axi_bvalid,
      a_awready => s00_axi_awready
      );
    axi4_read (
      addr      => (3 => '1', 2 => '1', others => '0'),
      data      => tb_rdata,
      a_clock   => s00_axi_aclk,
      a_addr    => s00_axi_araddr,
      a_data    => s00_axi_rdata,
      a_rresp   => s00_axi_rresp,
      a_arvalid => s00_axi_arvalid,
      a_rvalid  => s00_axi_rvalid,
      a_arready => s00_axi_arready
      );
    report "ILI9341 Read:  0x" & to_hex_string(tb_rdata);
    

    --  Exercise word register
    axi4_write (
      addr      => (3 => '1', 2 => '1', others => '0'),
      data      => X"c001babe",
      wstrobe   => "1111",
      a_clock   => s00_axi_aclk,
      a_addr    => s00_axi_awaddr,
      a_data    => s00_axi_wdata,
      a_wstrobe => s00_axi_wstrb,
      a_awvalid => s00_axi_awvalid,
      a_wvalid  => s00_axi_wvalid,
      a_wready  => s00_axi_wready,
      a_bvalid  => s00_axi_bvalid,
      a_awready => s00_axi_awready
      );
    axi4_read (
      addr      => (3 => '1', 2 => '1', others => '0'),
      data      => tb_rdata,
      a_clock   => s00_axi_aclk,
      a_addr    => s00_axi_araddr,
      a_data    => s00_axi_rdata,
      a_rresp   => s00_axi_rresp,
      a_arvalid => s00_axi_arvalid,
      a_rvalid  => s00_axi_rvalid,
      a_arready => s00_axi_arready
      );
    report "ILI9341 Read:  0x" & to_hex_string(tb_rdata);



    
    tb_addr <= (others => '0'); wait for 0 ns;
    -- 8.3.23. Read ID4 (D3h)
    axi4_write (
      addr      => tb_addr, -- (2 => '0', others => '0'),
      data      => X"000000D3",
      wstrobe   => "0001",
      a_clock   => s00_axi_aclk,
      a_addr    => s00_axi_awaddr,
      a_data    => s00_axi_wdata,
      a_wstrobe => s00_axi_wstrb,
      a_awvalid => s00_axi_awvalid,
      a_wvalid  => s00_axi_wvalid,
      a_wready  => s00_axi_wready,
      a_bvalid  => s00_axi_bvalid,
      a_awready => s00_axi_awready
      );
    -- tb_addr <= (2 => '1', others => '0'); wait for 0 ns;
    -- report "tb_addr: 0b" & to_bstring(tb_addr);
    for i in 0 to 3 loop
      axi4_read (
        addr      => (2 => '1', others => '0'),
        data      => tb_rdata,
        a_clock   => s00_axi_aclk,
        a_addr    => s00_axi_araddr,
        a_data    => s00_axi_rdata,
        a_rresp   => s00_axi_rresp,
        a_arvalid => s00_axi_arvalid,
        a_rvalid  => s00_axi_rvalid,
        a_arready => s00_axi_arready
        );
      report "ILI9341 Read:  0x" & to_hex_string(tb_rdata);
    end loop;
      
    -- tb_addr <= (others => '0');
    -- axi4_read (
    --   addr      => tb_addr,
    --   data      => tb_rdata,
    --   a_clock   => s00_axi_aclk,
    --   a_addr    => s00_axi_araddr,
    --   a_data    => s00_axi_rdata,
    --   a_rresp   => s00_axi_rresp,
    --   a_arvalid => s00_axi_arvalid,
    --   a_rvalid  => s00_axi_rvalid,
    --   a_arready => s00_axi_arready
    --   );

    -- axi4_write (
    --   addr      => tb_addr,
    --   data      => tb_wdata,
    --   a_clock   => s00_axi_aclk,
    --   a_addr    => s00_axi_awaddr,
    --   a_data    => s00_axi_wdata,
    --   a_wstrobe => s00_axi_wstrb,
    --   a_awvalid => s00_axi_awvalid,
    --   a_wvalid  => s00_axi_wvalid,
    --   a_awready => s00_axi_awready
    --   );

    wait for 1 us;


    sim_active <= false;
    wait;
  end process;


end;
-- Test bench configuration created online at:
--    https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

configuration cfg_ili9341_if_v1_0_tb of ili9341_if_v1_0_tb is
  for bench
    for uut : ili9341_if_v1_0
    -- Default configuration
    end for;
  end for;
end cfg_ili9341_if_v1_0_tb;

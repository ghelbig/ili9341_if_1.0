-------------------------------------------------------------------------------
-- Title      : ili9341 interface
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ili9341_if_v1_0.vhd
-- Author     : Gary Helbig  <ghelbig@designedtowork.com>
-- Company    : 
-- Created    : 2023-08-05
-- Last update: 2023-08-19
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Interface for ILI9341 TFT Driver
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  - Description
-- 2023-08-05  1.0      ghelbig - Created
-- 2023-08-11  1.1      ghelbig - New Core
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ili9341_if_v1_0 is
  generic (
    -- Users to add parameters here
    RD_CLOCKS : integer := 5;           -- 100 MHz
    WR_CLOCKS : integer := 2;           -- 100 MHz
    WR_CYCLE  : integer := 3;
    -- User parameters ends
    -- Do not modify the parameters beyond this line


    -- Parameters of Axi Slave Bus Interface S00_AXI
    C_S00_AXI_DATA_WIDTH : integer := 32;
    C_S00_AXI_ADDR_WIDTH : integer := 4
    );
  port (
    -- Users to add ports here
    lcd_d   : inout std_logic_vector(7 downto 0);
    lcd_rd  : out   std_logic;
    lcd_wr  : out   std_logic;
    lcd_rs  : out   std_logic;
    lcd_cs  : out   std_logic;
    lcd_rst : out   std_logic;
    -- debug pins
    lcd_ddo : out   std_logic_vector(7 downto 0);
    lcd_ddi : out   std_logic_vector(7 downto 0);
    lcd_ddt : out   std_logic;
    -- User ports ends
    -- Do not modify the ports beyond this line

    -- Ports of Axi Slave Bus Interface S00_AXI
    s00_axi_aclk    : in  std_logic;
    s00_axi_aresetn : in  std_logic;
    s00_axi_awaddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_awprot  : in  std_logic_vector(2 downto 0);
    s00_axi_awvalid : in  std_logic;
    s00_axi_awready : out std_logic;
    s00_axi_wdata   : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_wstrb   : in  std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
    s00_axi_wvalid  : in  std_logic;
    s00_axi_wready  : out std_logic;
    s00_axi_bresp   : out std_logic_vector(1 downto 0);
    s00_axi_bvalid  : out std_logic;
    s00_axi_bready  : in  std_logic;
    s00_axi_araddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_arprot  : in  std_logic_vector(2 downto 0);
    s00_axi_arvalid : in  std_logic;
    s00_axi_arready : out std_logic;
    s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_rresp   : out std_logic_vector(1 downto 0);
    s00_axi_rvalid  : out std_logic;
    s00_axi_rready  : in  std_logic
    );
end ili9341_if_v1_0;

architecture arch_imp of ili9341_if_v1_0 is

  -- component declaration
  component ili9341_if_core is
    generic (
      RD_CLOCKS          : integer := 7;                 -- 150 MHz
      WR_CLOCKS          : integer := 3;                 -- 150 MHz
      WR_CYCLE           : integer := 3;
      C_S_AXI_DATA_WIDTH : integer := 32;
      C_S_AXI_ADDR_WIDTH : integer := 4
      );
    port (
      -- lcd_d         : inout std_logic_vector(7 downto 0);
      lcd_rd        : out std_logic;
      lcd_wr        : out std_logic;
      lcd_rs        : out std_logic;
      lcd_cs        : out std_logic;
      lcd_rst       : out std_logic;
      lcd_di        : out std_logic_vector(7 downto 0);  -- Data to the TFT
      lcd_do        : in  std_logic_vector(7 downto 0);  -- Data from the TFT
      lcd_dt        : out std_logic;    -- Transmit (to the tft)
      S_AXI_ACLK    : in  std_logic;
      S_AXI_ARESETN : in  std_logic;
      S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in  std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID  : in  std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in  std_logic;
      S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in  std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in  std_logic
      );
  end component ili9341_if_core;

  component lcd_iobuf is
    generic (WIDTH : integer := 8);
    port (
      lcd_io : inout std_logic_vector(WIDTH-1 downto 0);  -- The FPGA pin
      lcd_di : in    std_logic_vector(WIDTH-1 downto 0);  -- Data to the TFT
      lcd_do : out   std_logic_vector(WIDTH-1 downto 0);  -- Data from the TFT
      lcd_dt : in    std_logic          -- Transmit (to the tft)
      );
  end component lcd_iobuf;

  signal lcd_do : std_logic_vector(7 downto 0);
  signal lcd_di : std_logic_vector(7 downto 0);
  signal lcd_dt : std_logic;

begin

-- Instantiation of Axi Bus Interface S00_AXI
  ili9341_if_core_inst : ili9341_if_core
    generic map (
      RD_CLOCKS          => RD_CLOCKS,
      WR_CLOCKS          => WR_CLOCKS,
      WR_CYCLE           => WR_CYCLE,
      C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
      )
    port map (
      lcd_rd  => lcd_rd,
      lcd_wr  => lcd_wr,
      lcd_rs  => lcd_rs,
      lcd_cs  => lcd_cs,
      lcd_rst => lcd_rst,
      lcd_di  => lcd_di,                -- Data to the TFT
      lcd_do  => lcd_do,                -- Data from the TFT
      lcd_dt  => lcd_dt,                -- Transmit (to the tft)

      S_AXI_ACLK    => s00_axi_aclk,
      S_AXI_ARESETN => s00_axi_aresetn,
      S_AXI_AWADDR  => s00_axi_awaddr,
      S_AXI_AWPROT  => s00_axi_awprot,
      S_AXI_AWVALID => s00_axi_awvalid,
      S_AXI_AWREADY => s00_axi_awready,
      S_AXI_WDATA   => s00_axi_wdata,
      S_AXI_WSTRB   => s00_axi_wstrb,
      S_AXI_WVALID  => s00_axi_wvalid,
      S_AXI_WREADY  => s00_axi_wready,
      S_AXI_BRESP   => s00_axi_bresp,
      S_AXI_BVALID  => s00_axi_bvalid,
      S_AXI_BREADY  => s00_axi_bready,
      S_AXI_ARADDR  => s00_axi_araddr,
      S_AXI_ARPROT  => s00_axi_arprot,
      S_AXI_ARVALID => s00_axi_arvalid,
      S_AXI_ARREADY => s00_axi_arready,
      S_AXI_RDATA   => s00_axi_rdata,
      S_AXI_RRESP   => s00_axi_rresp,
      S_AXI_RVALID  => s00_axi_rvalid,
      S_AXI_RREADY  => s00_axi_rready
      );

  iobuf_inst : lcd_iobuf
    generic map (WIDTH => lcd_d'length)
    port map (
      lcd_io => lcd_d,                  -- The FPGA pin
      lcd_di => lcd_di,                 -- Data to the TFT
      lcd_do => lcd_do,                 -- Data from the TFT
      lcd_dt => lcd_dt                  -- '0' => Transmit (to the tft)
      );

  debug_data : process (s00_axi_aclk, s00_axi_aresetn)
  begin
    if s00_axi_aresetn = '0' then
      lcd_ddo <= (others => '0');
      lcd_ddi <= (others => '0');
      lcd_ddt <= '1';
    elsif rising_edge(s00_axi_aclk) then
      lcd_ddo <= lcd_do;
      lcd_ddi <= lcd_di;
      lcd_ddt <= lcd_dt;
    end if;
  end process debug_data;

end arch_imp;

-------------------------------------------------------------------------------
-- Title      : ili9341 interface
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ili9341_if_core.vhd
-- Author     : Gary Helbig  <ghelbig@designedtowork.com>
-- Company    : 
-- Created    : 2023-08-05
-- Last update: 2023-08-19
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Interface for ILI9341 TFT Driver IC
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-08-05  1.0      ghelbig Created
-- 2023-08-13  1.0      ghelbig Two additional Registers
-- 2023-08-19  1.1      ghelbig Reg3 -> Wide Write Register
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity ili9341_if_core is
  generic (
    -- Users to add parameters here
    RD_CLOCKS : integer := 9;
    WR_CLOCKS : integer := 3;
    WR_CYCLE  : integer := 3;
    -- User parameters ends
    -- Do not modify the parameters beyond this line

    -- Width of S_AXI data bus
    C_S_AXI_DATA_WIDTH : integer := 32;
    -- Width of S_AXI address bus
    C_S_AXI_ADDR_WIDTH : integer := 4
    );
  port (
    -- Users to add ports here
    -- lcd_d   : inout std_logic_vector(7 downto 0);
    lcd_rd  : out std_logic;
    lcd_wr  : out std_logic;
    lcd_rs  : out std_logic;
    lcd_cs  : out std_logic;
    lcd_rst : out std_logic;
    lcd_di  : out std_logic_vector(7 downto 0);  -- Data to the TFT
    lcd_do  : in  std_logic_vector(7 downto 0);  -- Data from the TFT
    lcd_dt  : out std_logic;                     -- Transmit (to the tft)
    -- User ports ends
    -- Do not modify the ports beyond this line

    -- Global Clock Signal
    S_AXI_ACLK    : in std_logic;
    -- Global Reset Signal. This Signal is Active LOW
    S_AXI_ARESETN : in std_logic;

    -- Write address (issued by master, acceped by Slave)
    S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    -- Write channel Protection type. Indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
    S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    -- Write address valid. Indicates that the master signaling valid write address and control information.
    S_AXI_AWVALID : in  std_logic;
    -- Write address ready. Indicates that the slave is ready to accept an address and associated control signals.
    S_AXI_AWREADY : out std_logic;
    -- Write data (issued by master, acceped by Slave) 
    S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    -- Write strobes. Indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
    S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    -- Write valid. Indicates that valid write data and strobes are available.
    S_AXI_WVALID  : in  std_logic;
    -- Write ready. Indicates that the slave can accept the write data.
    S_AXI_WREADY  : out std_logic;
    -- Write response. Indicates the status of the write transaction.
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    -- Write response valid. Indicates that the channel is signaling a valid write response.
    S_AXI_BVALID  : out std_logic;
    -- Response ready. Indicates that the master can accept a write response.
    S_AXI_BREADY  : in  std_logic;

    -- Read address (issued by master, acceped by Slave)
    S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    -- Protection type. Indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
    S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    -- Read address valid. Indicates that the channel is signaling valid read address and control information.
    S_AXI_ARVALID : in  std_logic;
    -- Read address ready. Indicates that the slave is ready to accept an address and associated control signals.
    S_AXI_ARREADY : out std_logic;
    -- Read data (issued by slave)
    S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    -- Read response. Indicates the status of the read transfer.
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    -- Read valid. Indicates that the channel is signaling the required read data.
    S_AXI_RVALID  : out std_logic;
    -- Read ready. Indicates that the master can accept the read data and response information.
    S_AXI_RREADY  : in  std_logic
    );
end ili9341_if_core;

architecture rtl of ili9341_if_core is

  -- AXI4 Lite signals - so we can read the outputs

  -- Write address ready.  Indicates that the slave is ready to accept an address and associated control signals.
  signal axi_awready : std_logic;

  -- Write ready.          Indicates that the slave can accept the write data.
  signal axi_wready : std_logic;

  -- Write response.       Indicates the status of the write transaction.
  signal axi_bresp : std_logic_vector(1 downto 0) := (others => '0');

  -- Write response valid. Indicates that the channel is signaling a valid write response.
  signal axi_bvalid : std_logic;

  -- Read address ready.   Indicates that the slave is ready to accept an address and associated control signals.
  signal axi_arready : std_logic;

  -- Read data (issued by slave)
  signal axi_rdata : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

  -- Read response.        Indicates the status of the read transfer.
  signal axi_rresp : std_logic_vector(1 downto 0);

  -- Read valid.           Indicates that the channel is signaling the required read data.
  signal axi_rvalid : std_logic;

  constant RESP_OKAY   : std_logic_vector(1 downto 0) := "00";
  constant RESP_EXOKAY : std_logic_vector(1 downto 0) := "01";
  constant RESP_SLVERR : std_logic_vector(1 downto 0) := "10";
  constant RESP_DECERR : std_logic_vector(1 downto 0) := "11";



  -- Example-specific design signals
  -- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
  -- ADDR_LSB is used for addressing 32/64 bit registers/memories
  -- ADDR_LSB = 2 for 32 bits (n downto 2)
  -- ADDR_LSB = 3 for 64 bits (n downto 3)
  constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32) +1;
  constant ADDR_REGS : integer := (C_S_AXI_DATA_WIDTH/32) +2;

  -- Build an enumerated type for the state machine
  type state_t is (IDLE, WR_ADDR, RD_ADDR,
                   WR_BYTE3, WR_BYTE2, WR_BYTE1, WR_BYTE0,
                   WR_BYTE3_GAP, WR_BYTE2_GAP, WR_BYTE1_GAP, WR_BYTE0_END,
                   WR_HOLD, RD_WAIT, CS_GAP);
  -- Register to hold the current state
  signal state                      : state_t := IDLE;
  attribute syn_encoding            : string;
  attribute syn_encoding of state_t : type is "safe";

  signal lcd_wroe : std_logic;                     -- output enable
  signal lcd_wrdd : std_logic_vector(7 downto 0);  -- drive data

  function MAX (A : integer; B : integer) return integer is
  begin
    if (A > B) then return A;
               else return B;
    end if;
  end function;

  constant S_WIDTH   : integer := integer(CEIL(LOG2(real(MAX(RD_CLOCKS, WR_CLOCKS)+1))));
  signal strobe_cntr : unsigned(S_WIDTH-1 downto 0);

  signal reset_reg : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (0      => '1', others => '0');
  signal spare_reg : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others => '0');

  constant zero_vec : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others => '0');

begin
  -- I/O Connections assignments
  -- AXI4 Lite signals - so we can read the outputs

  S_AXI_AWREADY <= axi_awready;
  S_AXI_WREADY  <= axi_wready;
  S_AXI_BRESP   <= axi_bresp;
  S_AXI_ARREADY <= axi_arready;
  S_AXI_RDATA   <= axi_rdata;
  S_AXI_RRESP   <= axi_rresp;
  S_AXI_RVALID  <= axi_rvalid;
  S_AXI_BVALID  <= axi_bvalid;

  --  Move the rest of the signals out to the TFT
  --
--  lcd_d   <= lcd_wrdd when lcd_wroe = '1' else (others => 'Z');
  lcd_di  <= lcd_wrdd;
  lcd_dt  <= not lcd_wroe;
  lcd_rst <= reset_reg(0);

  --  Try it as (just one) state machine
  --
  axi_core : process (S_AXI_ACLK, S_AXI_ARESETN)
  begin
    if S_AXI_ARESETN = '0' then
--      lcd_rst     <= '0';
      lcd_wroe    <= '0';
      lcd_wrdd    <= (others => '0');
      lcd_rd      <= '1';
      lcd_wr      <= '1';
      lcd_rs      <= '0';
      lcd_cs      <= '1';
      reset_reg   <= (0      => '1', others => '0');  -- start with lcd_rst high
      spare_reg   <= (others => '0');
      axi_awready <= '0';
      axi_wready  <= '0';
      axi_bresp   <= (others => '0');
      axi_rresp   <= (others => '0');
      axi_arready <= '0';
      axi_bvalid  <= '0';
      axi_rvalid  <= '0';
      axi_rdata   <= (others => '0');
      strobe_cntr <= (others => '0');
      state       <= IDLE;
    elsif rising_edge(S_AXI_ACLK) then

      -- lcd_rst     <= '1';
      lcd_wroe    <= '0';
      lcd_cs      <= '1';
      axi_awready <= '0';
      axi_wready  <= '0';
      axi_arready <= '0';
      axi_bvalid  <= '0';
      axi_rvalid  <= '0';
      lcd_wr      <= '1';
      lcd_rd      <= '1';

      case state is

        when IDLE =>
          if S_AXI_AWVALID = '1' then
            lcd_rs <= S_AXI_AWADDR(ADDR_LSB);
            if (S_AXI_AWADDR(ADDR_REGS downto ADDR_LSB) /= "10") then
              lcd_cs <= '0';
            else
              lcd_cs <= '1';
            end if;
            axi_awready <= '1';
            axi_wready  <= '1';
            state       <= WR_ADDR;
          elsif S_AXI_ARVALID = '1' then
            lcd_rs <= S_AXI_ARADDR(ADDR_LSB);
            if (S_AXI_AWADDR(ADDR_REGS downto ADDR_LSB) /= "10") then
              lcd_cs <= '0';
            else
              lcd_cs <= '1';
            end if;
            axi_arready <= '1';
            state       <= RD_ADDR;
          end if;

        when RD_ADDR =>
          if (S_AXI_AWADDR(ADDR_REGS) = '0') then
            lcd_cs      <= '0';
            lcd_rd      <= '0';
            strobe_cntr <= to_unsigned(RD_CLOCKS-1, strobe_cntr'length);
          else
            lcd_cs      <= '1';
            lcd_rd      <= '1';
            strobe_cntr <= (others => '0');
          end if;
          state <= RD_WAIT;

        when RD_WAIT =>
          if (S_AXI_AWADDR(ADDR_REGS) = '0') then
            lcd_cs <= '0';
          else
            lcd_cs <= '1';
          end if;
          if (strobe_cntr = 0) then
            if (S_AXI_AWADDR(ADDR_REGS) = '0') then
              axi_rdata <= zero_vec(C_S_AXI_DATA_WIDTH-1 downto 8) & lcd_do(7 downto 0);
            else
              if (S_AXI_AWADDR(ADDR_LSB) = '0') then
                axi_rdata <= reset_reg;
              else
                axi_rdata <= spare_reg;
              end if;
            end if;
            if S_AXI_RREADY = '1' then
              axi_rresp  <= RESP_OKAY;
              axi_rvalid <= '1';
              state      <= CS_GAP;
            end if;
          else
            if (S_AXI_AWADDR(ADDR_REGS) = '0') then
              lcd_rd <= '0';
            else
              lcd_rd <= '1';
            end if;
            strobe_cntr <= strobe_cntr - 1;
          end if;

        when WR_ADDR =>
          if (S_AXI_AWADDR(ADDR_REGS downto ADDR_LSB) /= "10") then
            lcd_cs <= '0';
          else
            lcd_cs <= '1';
          end if;

          if S_AXI_WVALID = '1' then
            if (S_AXI_AWADDR(ADDR_REGS) = '0') then   -- Single byte registers
              lcd_wrdd    <= S_AXI_WDATA(7 downto 0);
              strobe_cntr <= to_unsigned(WR_CLOCKS-1, strobe_cntr'length);
              lcd_wroe    <= '1';
              lcd_wr      <= '0';
              state       <= WR_HOLD;
            else
              if (S_AXI_AWADDR(ADDR_LSB) = '0') then  -- Reset register
                reset_reg   <= S_AXI_WDATA;
                strobe_cntr <= (others => '0');
                state       <= WR_HOLD;
              else                                    -- Multi-byte register
                spare_reg <= S_AXI_WDATA;

                if S_AXI_WSTRB(3) = '1' then
                  lcd_wrdd    <= S_AXI_WDATA(31 downto 24);
                  strobe_cntr <= to_unsigned(WR_CLOCKS-1, strobe_cntr'length);
                  lcd_wroe    <= '1';
                  lcd_wr      <= '0';
                  state       <= WR_BYTE3;

                elsif S_AXI_WSTRB(2) = '1' then
                  lcd_wrdd    <= S_AXI_WDATA(23 downto 16);
                  strobe_cntr <= to_unsigned(WR_CLOCKS-1, strobe_cntr'length);
                  lcd_wroe    <= '1';
                  lcd_wr      <= '0';
                  state       <= WR_BYTE2;

                elsif S_AXI_WSTRB(1) = '1' then
                  lcd_wrdd    <= S_AXI_WDATA(15 downto 8);
                  strobe_cntr <= to_unsigned(WR_CLOCKS-1, strobe_cntr'length);
                  lcd_wroe    <= '1';
                  lcd_wr      <= '0';
                  state       <= WR_BYTE1;

                elsif S_AXI_WSTRB(0) = '1' then
                  lcd_wrdd    <= S_AXI_WDATA(7 downto 0);
                  strobe_cntr <= to_unsigned(WR_CLOCKS-1, strobe_cntr'length);
                  lcd_wroe    <= '1';
                  lcd_wr      <= '0';
                  state       <= WR_HOLD;

                else
                  strobe_cntr <= (others => '0');
                  lcd_wroe    <= '0';
                  lcd_wr      <= '1';
                  state       <= WR_HOLD;
                end if;

              end if;
            end if;
          end if;

        when WR_BYTE3 =>
          lcd_cs   <= '0';
          lcd_wroe <= '1';
          if (strobe_cntr = 0) then
            strobe_cntr <= to_unsigned(WR_CYCLE-1, strobe_cntr'length);
            state       <= WR_BYTE3_GAP;
          else
            lcd_wr      <= '0';
            strobe_cntr <= strobe_cntr - 1;
          end if;

        when WR_BYTE3_GAP =>
          lcd_cs   <= '0';
          lcd_wroe <= '0';
          if (strobe_cntr = 0) then
            lcd_wrdd    <= S_AXI_WDATA(23 downto 16);
            strobe_cntr <= to_unsigned(WR_CLOCKS-1, strobe_cntr'length);
            lcd_wroe    <= '1';
            lcd_wr      <= '0';
            state       <= WR_BYTE2;
          else
            strobe_cntr <= strobe_cntr - 1;
            lcd_wr      <= '1';
          end if;

        when WR_BYTE2 =>
          lcd_cs   <= '0';
          lcd_wroe <= '1';
          if (strobe_cntr = 0) then
            strobe_cntr <= to_unsigned(WR_CYCLE-1, strobe_cntr'length);
            state       <= WR_BYTE2_GAP;
          else
            lcd_wr      <= '0';
            strobe_cntr <= strobe_cntr - 1;
          end if;

        when WR_BYTE2_GAP =>
          lcd_cs   <= '0';
          lcd_wroe <= '0';
          if (strobe_cntr = 0) then
            lcd_wrdd    <= S_AXI_WDATA(15 downto 8);
            strobe_cntr <= to_unsigned(WR_CLOCKS-1, strobe_cntr'length);
            lcd_wroe    <= '1';
            lcd_wr      <= '0';
            state       <= WR_BYTE1;
          else
            strobe_cntr <= strobe_cntr - 1;
            lcd_wr      <= '1';
          end if;


        when WR_BYTE1 =>
          lcd_cs   <= '0';
          lcd_wroe <= '1';
          if (strobe_cntr = 0) then
            strobe_cntr <= to_unsigned(WR_CYCLE-1, strobe_cntr'length);
            state       <= WR_BYTE1_GAP;
          else
            lcd_wr      <= '0';
            strobe_cntr <= strobe_cntr - 1;
          end if;

        when WR_BYTE1_GAP =>
          lcd_cs   <= '0';
          lcd_wroe <= '0';
          if (strobe_cntr = 0) then
            lcd_wrdd    <= S_AXI_WDATA(7 downto 0);
            strobe_cntr <= to_unsigned(WR_CLOCKS-1, strobe_cntr'length);
            lcd_wroe    <= '1';
            lcd_wr      <= '0';
            state       <= WR_BYTE0;
          else
            strobe_cntr <= strobe_cntr - 1;
            lcd_wr      <= '1';
          end if;

        when WR_BYTE0 =>
          lcd_cs   <= '0';
          lcd_wroe <= '1';
          if (strobe_cntr = 0) then
            strobe_cntr <= to_unsigned(WR_CYCLE-1, strobe_cntr'length);
            -- lcd_cs      <= '1';
            -- lcd_wroe    <= '0';
            state       <= WR_BYTE0_END;
          else
            lcd_wr      <= '0';
            strobe_cntr <= strobe_cntr - 1;
          end if;

        when WR_BYTE0_END =>
          lcd_cs   <= '0';
          lcd_wroe <= '0';
          if (strobe_cntr = 0) then
            -- strobe_cntr <= to_unsigned(WR_CYCLE-1, strobe_cntr'length);
            lcd_cs   <= '1';
            lcd_wroe <= '0';
            if S_AXI_BREADY = '1' then
              axi_bresp  <= RESP_OKAY;
              axi_bvalid <= '1';
              state      <= CS_GAP;
            end if;
          else
            strobe_cntr <= strobe_cntr - 1;
          end if;

        when WR_HOLD =>
          if (S_AXI_AWADDR(ADDR_REGS downto ADDR_LSB) /= "10") then
            lcd_cs   <= '0';
            lcd_wr   <= '0';
            lcd_wroe <= '1';
          else
            lcd_cs   <= '1';
            lcd_wr   <= '1';
            lcd_wroe <= '0';
          end if;
          if (strobe_cntr = 0) then
            lcd_wr <= '1';
            if S_AXI_BREADY = '1' then
              axi_bresp  <= RESP_OKAY;
              axi_bvalid <= '1';
              state      <= CS_GAP;
            end if;
          else
            -- if (S_AXI_AWADDR(ADDR_REGS) = '0') then
            --   lcd_wr <= '0';
            -- else
            --   lcd_wr <= '1';
            -- end if;
            strobe_cntr <= strobe_cntr - 1;
          end if;

        when CS_GAP =>
          state <= IDLE;

        when others => null;
      end case;
    end if;

  end process axi_core;

end rtl;

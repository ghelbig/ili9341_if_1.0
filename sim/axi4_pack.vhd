library ieee;
use ieee.std_logic_1164.all;
-- use work.text_pack.all;

package axi4_pack is

  procedure axi4_read (
    constant addr    : in  std_logic_vector(3 downto 0);
    signal data      : out std_logic_vector(31 downto 0);
    signal a_clock   : in  std_logic;
    signal a_addr    : out std_logic_vector(3 downto 0);
    signal a_data    : in  std_logic_vector(31 downto 0);
    signal a_rresp   : in  std_logic_vector(1 downto 0);
    signal a_arvalid : out std_logic;
    signal a_rvalid  : in  std_logic;
    signal a_arready : in  std_logic
    );

  procedure axi4_write (
    constant addr    : in  std_logic_vector(3 downto 0);
    constant data    : in  std_logic_vector(31 downto 0);
    constant wstrobe : in  std_logic_vector(3 downto 0);
    signal a_clock   : in  std_logic;
    signal a_addr    : out std_logic_vector(3 downto 0);
    signal a_data    : out std_logic_vector(31 downto 0);
    signal a_wstrobe : out std_logic_vector(3 downto 0);
    signal a_awvalid : out std_logic;
    signal a_wvalid  : out std_logic;
    signal a_awready : in  std_logic;
    signal a_bvalid  : in  std_logic;
    signal a_wready : in  std_logic
    );

end package axi4_pack;

package body axi4_pack is

  procedure axi4_read (
    constant addr    : in  std_logic_vector(3 downto 0);
    signal data      : out std_logic_vector(31 downto 0);
    signal a_clock   : in  std_logic;
    signal a_addr    : out std_logic_vector(3 downto 0);
    signal a_data    : in  std_logic_vector(31 downto 0);
    signal a_rresp   : in  std_logic_vector(1 downto 0);
    signal a_arvalid : out std_logic;
    signal a_rvalid  : in  std_logic;
    signal a_arready : in  std_logic
    ) is
  begin
    wait until rising_edge(a_clock);
    a_addr    <= addr;
    a_arvalid <= '1';
    wait until a_arready = '1';
    wait until a_rvalid = '1';
    wait until rising_edge(a_clock);
    data      <= a_data;
    a_arvalid <= '0';
    wait until rising_edge(a_clock);
  end procedure axi4_read;

  procedure axi4_write (
    constant addr    : in  std_logic_vector(3 downto 0);
    constant data    : in  std_logic_vector(31 downto 0);
    constant wstrobe : in  std_logic_vector(3 downto 0);
    signal a_clock   : in  std_logic;
    signal a_addr    : out std_logic_vector(3 downto 0);
    signal a_data    : out std_logic_vector(31 downto 0);
    signal a_wstrobe : out std_logic_vector(3 downto 0);
    signal a_awvalid : out std_logic;
    signal a_wvalid  : out std_logic;
    signal a_awready : in  std_logic;
    signal a_bvalid  : in  std_logic;
    signal a_wready  : in  std_logic
    ) is
  begin
    wait until rising_edge(a_clock);
    -- report "sending address 0b" & to_bstring(addr);
    a_addr    <= addr;
    a_awvalid <= '1';
    a_wstrobe <= wstrobe;
    wait until rising_edge(a_clock);
    a_data    <= data;
    a_wvalid  <= '1';
    --a_wstrobe <= (others => '1');
    wait until a_awready = '1';
    wait until a_bvalid = '1';
    wait until rising_edge(a_clock);
    a_wstrobe <= (others => '0');
    a_wvalid  <= '0';
    a_awvalid <= '0';
  end procedure axi4_write;

end package body axi4_pack;

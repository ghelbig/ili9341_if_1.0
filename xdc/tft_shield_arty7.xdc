#
#  These are the pins for the ILI9341 shield on an Arty-A7
#
#		-- Users to add ports here
#          lcd_d   : inout std_logic_vector(7 downto 0);
#          lcd_rd  : out std_logic;
#          lcd_wr  : out std_logic;
#          lcd_rs  : out std_logic;
#          lcd_cs  : out std_logic;
#          lcd_rst : out std_logic;
#		-- User ports ends

set_property PACKAGE_PIN F5     [get_ports lcd_rd]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_rd]

set_property PACKAGE_PIN D8     [get_ports lcd_wr]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_wr]

set_property PACKAGE_PIN C7     [get_ports lcd_rs]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_rs]

set_property PACKAGE_PIN E7     [get_ports lcd_cs]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_cs]

set_property PACKAGE_PIN D7     [get_ports lcd_rst]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_rst]

set_property PULLTYPE KEEPER [get_ports lcd_d[*]]

set_property PACKAGE_PIN N15     [get_ports lcd_d[0]]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_d[0]]

set_property PACKAGE_PIN M16     [get_ports lcd_d[1]]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_d[1]]

set_property PACKAGE_PIN P14     [get_ports lcd_d[2]]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_d[2]]

set_property PACKAGE_PIN T11     [get_ports lcd_d[3]]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_d[3]]

set_property PACKAGE_PIN R12     [get_ports lcd_d[4]]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_d[4]]

set_property PACKAGE_PIN T14     [get_ports lcd_d[5]]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_d[5]]

set_property PACKAGE_PIN T15     [get_ports lcd_d[6]]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_d[6]]

set_property PACKAGE_PIN T16     [get_ports lcd_d[7]]
set_property IOSTANDARD LVCMOS33 [get_ports lcd_d[7]]

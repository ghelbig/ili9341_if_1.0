# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  set RD_CLOCKS [ipgui::add_param $IPINST -name "RD_CLOCKS"]
  set_property tooltip {Width of RD Strobe} ${RD_CLOCKS}
  set WR_CLOCKS [ipgui::add_param $IPINST -name "WR_CLOCKS"]
  set_property tooltip {Width of WR Strobe} ${WR_CLOCKS}
  ipgui::add_param $IPINST -name "WR_CYCLE"

}

proc update_PARAM_VALUE.RD_CLOCKS { PARAM_VALUE.RD_CLOCKS } {
	# Procedure called to update RD_CLOCKS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RD_CLOCKS { PARAM_VALUE.RD_CLOCKS } {
	# Procedure called to validate RD_CLOCKS
	return true
}

proc update_PARAM_VALUE.WR_CLOCKS { PARAM_VALUE.WR_CLOCKS } {
	# Procedure called to update WR_CLOCKS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WR_CLOCKS { PARAM_VALUE.WR_CLOCKS } {
	# Procedure called to validate WR_CLOCKS
	return true
}

proc update_PARAM_VALUE.WR_CYCLE { PARAM_VALUE.WR_CYCLE } {
	# Procedure called to update WR_CYCLE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WR_CYCLE { PARAM_VALUE.WR_CYCLE } {
	# Procedure called to validate WR_CYCLE
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to update C_S00_AXI_BASEADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_BASEADDR { PARAM_VALUE.C_S00_AXI_BASEADDR } {
	# Procedure called to validate C_S00_AXI_BASEADDR
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to update C_S00_AXI_HIGHADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_HIGHADDR { PARAM_VALUE.C_S00_AXI_HIGHADDR } {
	# Procedure called to validate C_S00_AXI_HIGHADDR
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.RD_CLOCKS { MODELPARAM_VALUE.RD_CLOCKS PARAM_VALUE.RD_CLOCKS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RD_CLOCKS}] ${MODELPARAM_VALUE.RD_CLOCKS}
}

proc update_MODELPARAM_VALUE.WR_CLOCKS { MODELPARAM_VALUE.WR_CLOCKS PARAM_VALUE.WR_CLOCKS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WR_CLOCKS}] ${MODELPARAM_VALUE.WR_CLOCKS}
}

proc update_MODELPARAM_VALUE.WR_CYCLE { MODELPARAM_VALUE.WR_CYCLE PARAM_VALUE.WR_CYCLE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WR_CYCLE}] ${MODELPARAM_VALUE.WR_CYCLE}
}


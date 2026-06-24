# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FND_DIV_COUNT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FND_DOT_THRESHOLD" -parent ${Page_0}


}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.FND_DIV_COUNT { PARAM_VALUE.FND_DIV_COUNT } {
	# Procedure called to update FND_DIV_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FND_DIV_COUNT { PARAM_VALUE.FND_DIV_COUNT } {
	# Procedure called to validate FND_DIV_COUNT
	return true
}

proc update_PARAM_VALUE.FND_DOT_THRESHOLD { PARAM_VALUE.FND_DOT_THRESHOLD } {
	# Procedure called to update FND_DOT_THRESHOLD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FND_DOT_THRESHOLD { PARAM_VALUE.FND_DOT_THRESHOLD } {
	# Procedure called to validate FND_DOT_THRESHOLD
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

proc update_MODELPARAM_VALUE.FND_DIV_COUNT { MODELPARAM_VALUE.FND_DIV_COUNT PARAM_VALUE.FND_DIV_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FND_DIV_COUNT}] ${MODELPARAM_VALUE.FND_DIV_COUNT}
}

proc update_MODELPARAM_VALUE.FND_DOT_THRESHOLD { MODELPARAM_VALUE.FND_DOT_THRESHOLD PARAM_VALUE.FND_DOT_THRESHOLD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FND_DOT_THRESHOLD}] ${MODELPARAM_VALUE.FND_DOT_THRESHOLD}
}


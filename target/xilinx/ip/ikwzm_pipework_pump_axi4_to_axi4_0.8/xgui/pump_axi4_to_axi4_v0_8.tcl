#Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
	set Page0           [ ipgui::add_page  $IPINST -name "GENERIC" -layout vertical]
	set Component_Name  [ ipgui::add_param $IPINST -parent $Page0     -name Component_Name ]
	set tabgroup0       [ ipgui::add_group $IPINST -parent $Page0     -name {BUFFER} -layout vertical]
	set BUF_DEPTH       [ ipgui::add_param $IPINST -parent $tabgroup0 -name BUF_DEPTH]
	set tabgroup1       [ ipgui::add_group $IPINST -parent $Page0     -name {Control Status Register AXI I/F} -layout vertical]
	set C_ADDR_WIDTH    [ ipgui::add_param $IPINST -parent $tabgroup1 -name C_ADDR_WIDTH]
	set C_DATA_WIDTH    [ ipgui::add_param $IPINST -parent $tabgroup1 -name C_DATA_WIDTH]
	set C_ID_WIDTH      [ ipgui::add_param $IPINST -parent $tabgroup1 -name C_ID_WIDTH]

	set Page1           [ ipgui::add_page  $IPINST -name "INTAKE I/F" -layout vertical]
	set tabgroup2       [ ipgui::add_group $IPINST -parent $Page1     -name {INTAKE AXI I/F} -layout vertical]
	set I_MAX_XFER_SIZE [ ipgui::add_param $IPINST -parent $tabgroup2 -name I_MAX_XFER_SIZE]
	set I_ADDR_WIDTH    [ ipgui::add_param $IPINST -parent $tabgroup2 -name I_ADDR_WIDTH]
	set I_DATA_WIDTH    [ ipgui::add_param $IPINST -parent $tabgroup2 -name I_DATA_WIDTH]
	set I_AXI_ID        [ ipgui::add_param $IPINST -parent $tabgroup2 -name I_AXI_ID]
	set I_ID_WIDTH      [ ipgui::add_param $IPINST -parent $tabgroup2 -name I_ID_WIDTH]
	set I_AUSER_WIDTH   [ ipgui::add_param $IPINST -parent $tabgroup2 -name I_AUSER_WIDTH]

	set Page2           [ ipgui::add_page  $IPINST -name "OUTLET I/F" -layout vertical]
	set tabgroup3       [ ipgui::add_group $IPINST -parent $Page2     -name {OUTLET AXI I/F} -layout vertical]
	set O_MAX_XFER_SIZE [ ipgui::add_param $IPINST -parent $tabgroup3 -name O_MAX_XFER_SIZE]
	set O_ADDR_WIDTH    [ ipgui::add_param $IPINST -parent $tabgroup3 -name O_ADDR_WIDTH]
	set O_DATA_WIDTH    [ ipgui::add_param $IPINST -parent $tabgroup3 -name O_DATA_WIDTH]
	set O_AXI_ID        [ ipgui::add_param $IPINST -parent $tabgroup3 -name O_AXI_ID]
	set O_ID_WIDTH      [ ipgui::add_param $IPINST -parent $tabgroup3 -name O_ID_WIDTH]
	set O_AUSER_WIDTH   [ ipgui::add_param $IPINST -parent $tabgroup3 -name O_AUSER_WIDTH]

	set Page3           [ ipgui::add_page  $IPINST  -name "PROC" -layout vertical]
	set tabgroup4       [ ipgui::add_group $IPINST -parent $Page3 -name {USE PROC} -layout vertical]
	set O_PROC_VALID    [ ipgui::add_param $IPINST -parent $tabgroup4 -name O_PROC_VALID]
	set I_PROC_VALID    [ ipgui::add_param $IPINST -parent $tabgroup4 -name I_PROC_VALID]
	set tabgroup5       [ ipgui::add_group $IPINST -parent $Page3 -name {PROC AXI I/F} -layout vertical]
	set M_ADDR_WIDTH    [ ipgui::add_param $IPINST -parent $tabgroup5 -name M_ADDR_WIDTH]
	set M_DATA_WIDTH    [ ipgui::add_param $IPINST -parent $tabgroup5 -name M_DATA_WIDTH]
	set M_AXI_ID        [ ipgui::add_param $IPINST -parent $tabgroup5 -name M_AXI_ID]
	set M_ID_WIDTH      [ ipgui::add_param $IPINST -parent $tabgroup5 -name M_ID_WIDTH]
	set M_AUSER_WIDTH   [ ipgui::add_param $IPINST -parent $tabgroup5 -name M_AUSER_WIDTH]
}

proc update_PARAM_VALUE.BUF_DEPTH { PARAM_VALUE.BUF_DEPTH } {
	# Procedure called to update BUF_DEPTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BUF_DEPTH { PARAM_VALUE.BUF_DEPTH } {
	# Procedure called to validate BUF_DEPTH
	return true
}

proc update_PARAM_VALUE.O_PROC_VALID { PARAM_VALUE.O_PROC_VALID } {
	# Procedure called to update O_PROC_VALID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.O_PROC_VALID { PARAM_VALUE.O_PROC_VALID } {
	# Procedure called to validate O_PROC_VALID
	return true
}

proc update_PARAM_VALUE.O_MAX_XFER_SIZE { PARAM_VALUE.O_MAX_XFER_SIZE } {
	# Procedure called to update O_MAX_XFER_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.O_MAX_XFER_SIZE { PARAM_VALUE.O_MAX_XFER_SIZE } {
	# Procedure called to validate O_MAX_XFER_SIZE
	return true
}

proc update_PARAM_VALUE.O_AUSER_WIDTH { PARAM_VALUE.O_AUSER_WIDTH } {
	# Procedure called to update O_AUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.O_AUSER_WIDTH { PARAM_VALUE.O_AUSER_WIDTH } {
	# Procedure called to validate O_AUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.O_ID_WIDTH { PARAM_VALUE.O_ID_WIDTH } {
	# Procedure called to update O_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.O_ID_WIDTH { PARAM_VALUE.O_ID_WIDTH } {
	# Procedure called to validate O_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.O_DATA_WIDTH { PARAM_VALUE.O_DATA_WIDTH } {
	# Procedure called to update O_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.O_DATA_WIDTH { PARAM_VALUE.O_DATA_WIDTH } {
	# Procedure called to validate O_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.O_ADDR_WIDTH { PARAM_VALUE.O_ADDR_WIDTH } {
	# Procedure called to update O_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.O_ADDR_WIDTH { PARAM_VALUE.O_ADDR_WIDTH } {
	# Procedure called to validate O_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.O_AXI_ID { PARAM_VALUE.O_AXI_ID } {
	# Procedure called to update O_AXI_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.O_AXI_ID { PARAM_VALUE.O_AXI_ID } {
	# Procedure called to validate O_AXI_ID
	return true
}

proc update_PARAM_VALUE.I_PROC_VALID { PARAM_VALUE.I_PROC_VALID } {
	# Procedure called to update I_PROC_VALID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I_PROC_VALID { PARAM_VALUE.I_PROC_VALID } {
	# Procedure called to validate I_PROC_VALID
	return true
}

proc update_PARAM_VALUE.I_MAX_XFER_SIZE { PARAM_VALUE.I_MAX_XFER_SIZE } {
	# Procedure called to update I_MAX_XFER_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I_MAX_XFER_SIZE { PARAM_VALUE.I_MAX_XFER_SIZE } {
	# Procedure called to validate I_MAX_XFER_SIZE
	return true
}

proc update_PARAM_VALUE.I_AUSER_WIDTH { PARAM_VALUE.I_AUSER_WIDTH } {
	# Procedure called to update I_AUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I_AUSER_WIDTH { PARAM_VALUE.I_AUSER_WIDTH } {
	# Procedure called to validate I_AUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.I_ID_WIDTH { PARAM_VALUE.I_ID_WIDTH } {
	# Procedure called to update I_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I_ID_WIDTH { PARAM_VALUE.I_ID_WIDTH } {
	# Procedure called to validate I_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.I_DATA_WIDTH { PARAM_VALUE.I_DATA_WIDTH } {
	# Procedure called to update I_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I_DATA_WIDTH { PARAM_VALUE.I_DATA_WIDTH } {
	# Procedure called to validate I_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.I_ADDR_WIDTH { PARAM_VALUE.I_ADDR_WIDTH } {
	# Procedure called to update I_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I_ADDR_WIDTH { PARAM_VALUE.I_ADDR_WIDTH } {
	# Procedure called to validate I_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.I_AXI_ID { PARAM_VALUE.I_AXI_ID } {
	# Procedure called to update I_AXI_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I_AXI_ID { PARAM_VALUE.I_AXI_ID } {
	# Procedure called to validate I_AXI_ID
	return true
}

proc update_PARAM_VALUE.M_AXI_ID { PARAM_VALUE.M_AXI_ID } {
	# Procedure called to update M_AXI_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_AXI_ID { PARAM_VALUE.M_AXI_ID } {
	# Procedure called to validate M_AXI_ID
	return true
}

proc update_PARAM_VALUE.M_AUSER_WIDTH { PARAM_VALUE.M_AUSER_WIDTH } {
	# Procedure called to update M_AUSER_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_AUSER_WIDTH { PARAM_VALUE.M_AUSER_WIDTH } {
	# Procedure called to validate M_AUSER_WIDTH
	return true
}

proc update_PARAM_VALUE.M_ID_WIDTH { PARAM_VALUE.M_ID_WIDTH } {
	# Procedure called to update M_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_ID_WIDTH { PARAM_VALUE.M_ID_WIDTH } {
	# Procedure called to validate M_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.M_DATA_WIDTH { PARAM_VALUE.M_DATA_WIDTH } {
	# Procedure called to update M_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_DATA_WIDTH { PARAM_VALUE.M_DATA_WIDTH } {
	# Procedure called to validate M_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.M_ADDR_WIDTH { PARAM_VALUE.M_ADDR_WIDTH } {
	# Procedure called to update M_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_ADDR_WIDTH { PARAM_VALUE.M_ADDR_WIDTH } {
	# Procedure called to validate M_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_ID_WIDTH { PARAM_VALUE.C_ID_WIDTH } {
	# Procedure called to update C_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ID_WIDTH { PARAM_VALUE.C_ID_WIDTH } {
	# Procedure called to validate C_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_DATA_WIDTH { PARAM_VALUE.C_DATA_WIDTH } {
	# Procedure called to update C_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_DATA_WIDTH { PARAM_VALUE.C_DATA_WIDTH } {
	# Procedure called to validate C_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to update C_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_WIDTH { PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to validate C_ADDR_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_ADDR_WIDTH { MODELPARAM_VALUE.C_ADDR_WIDTH PARAM_VALUE.C_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_DATA_WIDTH { MODELPARAM_VALUE.C_DATA_WIDTH PARAM_VALUE.C_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_DATA_WIDTH}] ${MODELPARAM_VALUE.C_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_ID_WIDTH { MODELPARAM_VALUE.C_ID_WIDTH PARAM_VALUE.C_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ID_WIDTH}] ${MODELPARAM_VALUE.C_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.M_ADDR_WIDTH { MODELPARAM_VALUE.M_ADDR_WIDTH PARAM_VALUE.M_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_ADDR_WIDTH}] ${MODELPARAM_VALUE.M_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.M_DATA_WIDTH { MODELPARAM_VALUE.M_DATA_WIDTH PARAM_VALUE.M_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_DATA_WIDTH}] ${MODELPARAM_VALUE.M_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.M_ID_WIDTH { MODELPARAM_VALUE.M_ID_WIDTH PARAM_VALUE.M_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_ID_WIDTH}] ${MODELPARAM_VALUE.M_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.M_AUSER_WIDTH { MODELPARAM_VALUE.M_AUSER_WIDTH PARAM_VALUE.M_AUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_AUSER_WIDTH}] ${MODELPARAM_VALUE.M_AUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.M_AXI_ID { MODELPARAM_VALUE.M_AXI_ID PARAM_VALUE.M_AXI_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_AXI_ID}] ${MODELPARAM_VALUE.M_AXI_ID}
}

proc update_MODELPARAM_VALUE.I_AXI_ID { MODELPARAM_VALUE.I_AXI_ID PARAM_VALUE.I_AXI_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I_AXI_ID}] ${MODELPARAM_VALUE.I_AXI_ID}
}

proc update_MODELPARAM_VALUE.I_ADDR_WIDTH { MODELPARAM_VALUE.I_ADDR_WIDTH PARAM_VALUE.I_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I_ADDR_WIDTH}] ${MODELPARAM_VALUE.I_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.I_DATA_WIDTH { MODELPARAM_VALUE.I_DATA_WIDTH PARAM_VALUE.I_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I_DATA_WIDTH}] ${MODELPARAM_VALUE.I_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.I_ID_WIDTH { MODELPARAM_VALUE.I_ID_WIDTH PARAM_VALUE.I_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I_ID_WIDTH}] ${MODELPARAM_VALUE.I_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.I_AUSER_WIDTH { MODELPARAM_VALUE.I_AUSER_WIDTH PARAM_VALUE.I_AUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I_AUSER_WIDTH}] ${MODELPARAM_VALUE.I_AUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.I_MAX_XFER_SIZE { MODELPARAM_VALUE.I_MAX_XFER_SIZE PARAM_VALUE.I_MAX_XFER_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I_MAX_XFER_SIZE}] ${MODELPARAM_VALUE.I_MAX_XFER_SIZE}
}

proc update_MODELPARAM_VALUE.I_PROC_VALID { MODELPARAM_VALUE.I_PROC_VALID PARAM_VALUE.I_PROC_VALID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I_PROC_VALID}] ${MODELPARAM_VALUE.I_PROC_VALID}
}

proc update_MODELPARAM_VALUE.O_AXI_ID { MODELPARAM_VALUE.O_AXI_ID PARAM_VALUE.O_AXI_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.O_AXI_ID}] ${MODELPARAM_VALUE.O_AXI_ID}
}

proc update_MODELPARAM_VALUE.O_ADDR_WIDTH { MODELPARAM_VALUE.O_ADDR_WIDTH PARAM_VALUE.O_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.O_ADDR_WIDTH}] ${MODELPARAM_VALUE.O_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.O_DATA_WIDTH { MODELPARAM_VALUE.O_DATA_WIDTH PARAM_VALUE.O_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.O_DATA_WIDTH}] ${MODELPARAM_VALUE.O_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.O_ID_WIDTH { MODELPARAM_VALUE.O_ID_WIDTH PARAM_VALUE.O_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.O_ID_WIDTH}] ${MODELPARAM_VALUE.O_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.O_AUSER_WIDTH { MODELPARAM_VALUE.O_AUSER_WIDTH PARAM_VALUE.O_AUSER_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.O_AUSER_WIDTH}] ${MODELPARAM_VALUE.O_AUSER_WIDTH}
}

proc update_MODELPARAM_VALUE.O_MAX_XFER_SIZE { MODELPARAM_VALUE.O_MAX_XFER_SIZE PARAM_VALUE.O_MAX_XFER_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.O_MAX_XFER_SIZE}] ${MODELPARAM_VALUE.O_MAX_XFER_SIZE}
}

proc update_MODELPARAM_VALUE.O_PROC_VALID { MODELPARAM_VALUE.O_PROC_VALID PARAM_VALUE.O_PROC_VALID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.O_PROC_VALID}] ${MODELPARAM_VALUE.O_PROC_VALID}
}

proc update_MODELPARAM_VALUE.BUF_DEPTH { MODELPARAM_VALUE.BUF_DEPTH PARAM_VALUE.BUF_DEPTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BUF_DEPTH}] ${MODELPARAM_VALUE.BUF_DEPTH}
}


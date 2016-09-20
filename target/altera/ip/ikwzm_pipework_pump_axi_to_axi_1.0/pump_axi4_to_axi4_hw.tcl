package require -exact qsys 12.1

# +-----------------------------------
# | module axi_sample
# | 
set_module_property DESCRIPTION          "PUMP AXI4 to AXI4."
set_module_property NAME                 pump_axi4_to_axi4
set_module_property VERSION              1.0
set_module_property INTERNAL             false
set_module_property OPAQUE_ADDRESS_MAP   true
set_module_property AUTHOR               "ikwm"
set_module_property DISPLAY_NAME         "pump_axi4_to_axi4"
set_module_property EDITABLE             true
set_module_property ANALYZE_HDL          AUTO
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property ALLOW_GREYBOX_GENERATION     false
set_module_property ELABORATION_CALLBACK elaborate
# | 
# +-----------------------------------

# +-----------------------------------
# | file sets
# | 
add_fileset          QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH TOP_LEVEL    PUMP_AXI4_TO_AXI4
add_fileset_file     pump_axi4_to_axi4.vhd      VHDL PATH src/vhdl/pump_axi4_to_axi4.vhd
add_fileset_file     pump_axi4_to_axi4_core.vhd VHDL PATH src/vhdl/pump_axi4_to_axi4_core.vhd

add_fileset          SIM_VHDL SIM_VHDL "" ""
set_fileset_property SIM_VHDL ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VHDL TOP_LEVEL         PUMP_AXI4_TO_AXI4
add_fileset_file     pump_axi4_to_axi4.vhd      VHDL PATH src/vhdl/pump_axi4_to_axi4.vhd
add_fileset_file     pump_axi4_to_axi4_core.vhd VHDL PATH src/vhdl/pump_axi4_to_axi4_core.vhd

# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter          AXI_VERSION            STRING              "AXI4"
set_parameter_property AXI_VERSION            DISPLAY_NAME        "AXI Version"
set_parameter_property AXI_VERSION            TYPE                STRING
set_parameter_property AXI_VERSION            UNITS               None
set_parameter_property AXI_VERSION            DESCRIPTION         "Indicate this is AXI4 master"
set_parameter_property AXI_VERSION            AFFECTS_ELABORATION true
set_parameter_property AXI_VERSION            ALLOWED_RANGES      "AXI4"
set_parameter_property AXI_VERSION            DISPLAY_HINT        "boolean"
set_parameter_property AXI_VERSION            HDL_PARAMETER       false

add_parameter          C_DATA_WIDTH           INTEGER             32
set_parameter_property C_DATA_WIDTH           DEFAULT_VALUE       32
set_parameter_property C_DATA_WIDTH           DISPLAY_NAME        "Control Status Register I/F Data Width"
set_parameter_property C_DATA_WIDTH           UNITS               "bits"
set_parameter_property C_DATA_WIDTH           HDL_PARAMETER       true
set_parameter_property C_DATA_WIDTH           ALLOWED_RANGES      "32,64,128,256"

add_parameter          C_ADDR_WIDTH           INTEGER             12
set_parameter_property C_ADDR_WIDTH           DEFAULT_VALUE       12
set_parameter_property C_ADDR_WIDTH           DISPLAY_NAME        "Control Status Register I/F Byte Address Width"
set_parameter_property C_ADDR_WIDTH           UNITS               "bits"
set_parameter_property C_ADDR_WIDTH           HDL_PARAMETER       true
set_parameter_property C_ADDR_WIDTH           AFFECTS_ELABORATION true
set_parameter_property C_ADDR_WIDTH           ALLOWED_RANGES      1:64

add_parameter          C_ID_WIDTH             INTEGER             12
set_parameter_property C_ID_WIDTH             DEFAULT_VALUE       12
set_parameter_property C_ID_WIDTH             DISPLAY_NAME        "Control Status Register I/F AXI ID Width"
set_parameter_property C_ID_WIDTH             TYPE                INTEGER
set_parameter_property C_ID_WIDTH             UNITS               None
set_parameter_property C_ID_WIDTH             DESCRIPTION         "Control Status Register I/F AXI ID Width"
set_parameter_property C_ID_WIDTH             AFFECTS_ELABORATION true
set_parameter_property C_ID_WIDTH             HDL_PARAMETER       true

add_parameter          M_AXI_ID               INTEGER             2
set_parameter_property M_AXI_ID               DEFAULT_VALUE       2
set_parameter_property M_AXI_ID               DISPLAY_NAME        "Operation Code Fetch I/F AXI ID"
set_parameter_property M_AXI_ID               TYPE                INTEGER
set_parameter_property M_AXI_ID               UNITS               None
set_parameter_property M_AXI_ID               DESCRIPTION         "Operation Code Fetch I/F AXI ID"
set_parameter_property M_AXI_ID               AFFECTS_ELABORATION true
set_parameter_property M_AXI_ID               HDL_PARAMETER       true

add_parameter          M_DATA_WIDTH           INTEGER             32
set_parameter_property M_DATA_WIDTH           DEFAULT_VALUE       32
set_parameter_property M_DATA_WIDTH           DISPLAY_NAME        "Operation Code Fetch I/F Data Width"
set_parameter_property M_DATA_WIDTH           UNITS               "bits"
set_parameter_property M_DATA_WIDTH           HDL_PARAMETER       true
set_parameter_property M_DATA_WIDTH           ALLOWED_RANGES      "32,64,128,256,512,1024"

add_parameter          M_ADDR_WIDTH           INTEGER             32
set_parameter_property M_ADDR_WIDTH           DEFAULT_VALUE       32
set_parameter_property M_ADDR_WIDTH           DISPLAY_NAME        "Operation Code Fetch I/F Byte Address Width"
set_parameter_property M_ADDR_WIDTH           UNITS               "bits"
set_parameter_property M_ADDR_WIDTH           HDL_PARAMETER       true
set_parameter_property M_ADDR_WIDTH           AFFECTS_ELABORATION true
set_parameter_property M_ADDR_WIDTH           ALLOWED_RANGES      1:64

add_parameter          M_ID_WIDTH             INTEGER             2
set_parameter_property M_ID_WIDTH             DEFAULT_VALUE       2
set_parameter_property M_ID_WIDTH             DISPLAY_NAME        "Operation Code Fetch I/F AXI ID width"
set_parameter_property M_ID_WIDTH             TYPE                INTEGER
set_parameter_property M_ID_WIDTH             UNITS               None
set_parameter_property M_ID_WIDTH             DESCRIPTION         "Operation Code Fetch I/F AXI ID width"
set_parameter_property M_ID_WIDTH             AFFECTS_ELABORATION true
set_parameter_property M_ID_WIDTH             HDL_PARAMETER       true

add_parameter          M_USE_ADDR_USER        INTEGER             1
set_parameter_property M_USE_ADDR_USER        DISPLAY_NAME        "Use Operation Code Fetch I/F Address Sideband Signals"
set_parameter_property M_USE_ADDR_USER        TYPE                INTEGER
set_parameter_property M_USE_ADDR_USER        UNITS               None
set_parameter_property M_USE_ADDR_USER        DESCRIPTION         "Use Operation Code Fetch I/F Address Sideband Signals"
set_parameter_property M_USE_ADDR_USER        AFFECTS_ELABORATION true
set_parameter_property M_USE_ADDR_USER        ALLOWED_RANGES      0:1
set_parameter_property M_USE_ADDR_USER        DISPLAY_HINT        "boolean"

add_parameter          M_AUSER_WIDTH          INTEGER             2
set_parameter_property M_AUSER_WIDTH          DEFAULT_VALUE       2
set_parameter_property M_AUSER_WIDTH          DISPLAY_NAME        "Operation Code Fetch I/F AXI AWUSER/ARUSER width"
set_parameter_property M_AUSER_WIDTH          TYPE                INTEGER
set_parameter_property M_AUSER_WIDTH          UNITS               None
set_parameter_property M_AUSER_WIDTH          DESCRIPTION         "Operation Code Fetch I/F AXI AWUSER/ARUSER width"
set_parameter_property M_AUSER_WIDTH          AFFECTS_ELABORATION true
set_parameter_property M_AUSER_WIDTH          HDL_PARAMETER       true

add_parameter          I_AXI_ID               INTEGER             0
set_parameter_property I_AXI_ID               DEFAULT_VALUE       0
set_parameter_property I_AXI_ID               DISPLAY_NAME        "Intake I/F AXI ID"
set_parameter_property I_AXI_ID               TYPE                INTEGER
set_parameter_property I_AXI_ID               UNITS               None
set_parameter_property I_AXI_ID               DESCRIPTION         "Intake I/F AXI ID"
set_parameter_property I_AXI_ID               AFFECTS_ELABORATION true
set_parameter_property I_AXI_ID               HDL_PARAMETER       true

add_parameter          I_ID_WIDTH             INTEGER             2
set_parameter_property I_ID_WIDTH             DEFAULT_VALUE       2
set_parameter_property I_ID_WIDTH             DISPLAY_NAME        "Intake I/F AXI ID width"
set_parameter_property I_ID_WIDTH             TYPE                INTEGER
set_parameter_property I_ID_WIDTH             UNITS               None
set_parameter_property I_ID_WIDTH             DESCRIPTION         "Intake I/F AXI ID width"
set_parameter_property I_ID_WIDTH             AFFECTS_ELABORATION true
set_parameter_property I_ID_WIDTH             HDL_PARAMETER       true

add_parameter          I_DATA_WIDTH           INTEGER             32
set_parameter_property I_DATA_WIDTH           DEFAULT_VALUE       32
set_parameter_property I_DATA_WIDTH           DISPLAY_NAME        "Intake I/F Data Width"
set_parameter_property I_DATA_WIDTH           UNITS               "bits"
set_parameter_property I_DATA_WIDTH           HDL_PARAMETER       true
set_parameter_property I_DATA_WIDTH           ALLOWED_RANGES      "32,64,128,256,512,1024"

add_parameter          I_ADDR_WIDTH           INTEGER             32
set_parameter_property I_ADDR_WIDTH           DEFAULT_VALUE       32
set_parameter_property I_ADDR_WIDTH           DISPLAY_NAME        "Intake I/F Byte Address Width"
set_parameter_property I_ADDR_WIDTH           UNITS               "bits"
set_parameter_property I_ADDR_WIDTH           HDL_PARAMETER       true
set_parameter_property I_ADDR_WIDTH           AFFECTS_ELABORATION true
set_parameter_property I_ADDR_WIDTH           ALLOWED_RANGES      1:64

add_parameter          I_USE_ADDR_USER        INTEGER             1
set_parameter_property I_USE_ADDR_USER        DISPLAY_NAME        "Use Intake I/F Address Sideband Signals"
set_parameter_property I_USE_ADDR_USER        TYPE                INTEGER
set_parameter_property I_USE_ADDR_USER        UNITS               None
set_parameter_property I_USE_ADDR_USER        DESCRIPTION         "Use Intake I/F Address Sideband Signals"
set_parameter_property I_USE_ADDR_USER        AFFECTS_ELABORATION true
set_parameter_property I_USE_ADDR_USER        ALLOWED_RANGES      0:1
set_parameter_property I_USE_ADDR_USER        DISPLAY_HINT        "boolean"

add_parameter          I_AUSER_WIDTH          INTEGER             2
set_parameter_property I_AUSER_WIDTH          DEFAULT_VALUE       2
set_parameter_property I_AUSER_WIDTH          DISPLAY_NAME        "Intake I/F AXI AWUSER/ARUSER width"
set_parameter_property I_AUSER_WIDTH          TYPE                INTEGER
set_parameter_property I_AUSER_WIDTH          UNITS               None
set_parameter_property I_AUSER_WIDTH          DESCRIPTION         "Intake I/F AXI AWUSER/ARUSER width"
set_parameter_property I_AUSER_WIDTH          AFFECTS_ELABORATION true
set_parameter_property I_AUSER_WIDTH          HDL_PARAMETER       true

add_parameter          O_AXI_ID               INTEGER             1
set_parameter_property O_AXI_ID               DEFAULT_VALUE       1
set_parameter_property O_AXI_ID               DISPLAY_NAME        "Outlet I/F AXI ID"
set_parameter_property O_AXI_ID               TYPE                INTEGER
set_parameter_property O_AXI_ID               UNITS               None
set_parameter_property O_AXI_ID               DESCRIPTION         "Outlet I/F AXI ID"
set_parameter_property O_AXI_ID               AFFECTS_ELABORATION true
set_parameter_property O_AXI_ID               HDL_PARAMETER       true

add_parameter          O_ID_WIDTH             INTEGER             2
set_parameter_property O_ID_WIDTH             DEFAULT_VALUE       2
set_parameter_property O_ID_WIDTH             DISPLAY_NAME        "Outlet I/F AXI ID width"
set_parameter_property O_ID_WIDTH             TYPE                INTEGER
set_parameter_property O_ID_WIDTH             UNITS               None
set_parameter_property O_ID_WIDTH             DESCRIPTION         "Outlet I/F AXI ID width"
set_parameter_property O_ID_WIDTH             AFFECTS_ELABORATION true
set_parameter_property O_ID_WIDTH             HDL_PARAMETER       true

add_parameter          O_DATA_WIDTH           INTEGER             32
set_parameter_property O_DATA_WIDTH           DEFAULT_VALUE       32
set_parameter_property O_DATA_WIDTH           DISPLAY_NAME        "Outlet I/F Data Width"
set_parameter_property O_DATA_WIDTH           UNITS               "bits"
set_parameter_property O_DATA_WIDTH           HDL_PARAMETER       true
set_parameter_property O_DATA_WIDTH           ALLOWED_RANGES      "32,64,128,256,512,1024"

add_parameter          O_ADDR_WIDTH           INTEGER             32
set_parameter_property O_ADDR_WIDTH           DEFAULT_VALUE       32
set_parameter_property O_ADDR_WIDTH           DISPLAY_NAME        "Outlet I/F Byte Address Width"
set_parameter_property O_ADDR_WIDTH           UNITS               "bits"
set_parameter_property O_ADDR_WIDTH           HDL_PARAMETER       true
set_parameter_property O_ADDR_WIDTH           AFFECTS_ELABORATION true
set_parameter_property O_ADDR_WIDTH           ALLOWED_RANGES      1:64

add_parameter          O_USE_ADDR_USER        INTEGER             1
set_parameter_property O_USE_ADDR_USER        DISPLAY_NAME        "Use Outlet I/F Address Sideband Signals"
set_parameter_property O_USE_ADDR_USER        TYPE                INTEGER
set_parameter_property O_USE_ADDR_USER        UNITS               None
set_parameter_property O_USE_ADDR_USER        DESCRIPTION         "Use Outlet I/F Address Sideband Signals"
set_parameter_property O_USE_ADDR_USER        AFFECTS_ELABORATION true
set_parameter_property O_USE_ADDR_USER        ALLOWED_RANGES      0:1
set_parameter_property O_USE_ADDR_USER        DISPLAY_HINT        "boolean"

add_parameter          O_AUSER_WIDTH          INTEGER             2
set_parameter_property O_AUSER_WIDTH          DEFAULT_VALUE       2
set_parameter_property O_AUSER_WIDTH          DISPLAY_NAME        "Outlet I/F AXI AWUSER/ARUSER width"
set_parameter_property O_AUSER_WIDTH          TYPE                INTEGER
set_parameter_property O_AUSER_WIDTH          UNITS               None
set_parameter_property O_AUSER_WIDTH          DESCRIPTION         "Outlet I/F AXI AWUSER/ARUSER width"
set_parameter_property O_AUSER_WIDTH          AFFECTS_ELABORATION true
set_parameter_property O_AUSER_WIDTH          HDL_PARAMETER       true

# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point C_CLK
# | 
add_interface          C_CLK   clock   end
set_interface_property C_CLK   ENABLED true
add_interface_port     C_CLK   C_CLK   clk Input 1

add_interface          M_CLK   clock   end
set_interface_property M_CLK   ENABLED true
add_interface_port     M_CLK   M_CLK   clk Input 1

add_interface          I_CLK   clock   end
set_interface_property I_CLK   ENABLED true
add_interface_port     I_CLK   I_CLK   clk Input 1

add_interface          O_CLK   clock   end
set_interface_property O_CLK   ENABLED true
add_interface_port     O_CLK   O_CLK   clk Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point RESET
# | 
add_interface          ARESETn reset               sink
set_interface_property ARESETn associatedClock     C_CLK
set_interface_property ARESETn synchronousEdges    DEASSERT
set_interface_property ARESETn ENABLED             true
set_interface_property ARESETn EXPORT_OF           ""
set_interface_property ARESETn PORT_NAME_MAP       ""
set_interface_property ARESETn CMSIS_SVD_VARIABLES ""
set_interface_property ARESETn SVD_ADDRESS_GROUP   ""
add_interface_port     ARESETn ARESETn reset_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point IRQ
# | 
add_interface          IRQ     interrupt end
set_interface_property IRQ     associatedAddressablePoint CSR
set_interface_property IRQ     ASSOCIATED_CLOCK C_CLK
add_interface_port     IRQ     IRQ irq Output 1

# +-----------------------------------
# | Elaboration callback
# +-----------------------------------
proc elaborate {} {
    # +-----------------------------------
    # | connection point CSR
    # +-----------------------------------
    set csr_id_width        [ get_parameter_value C_ID_WIDTH        ]
    set csr_data_width      [ get_parameter_value C_DATA_WIDTH      ]
    set csr_addr_width      [ get_parameter_value C_ADDR_WIDTH      ]
    set csr_burst_length    8
    set csr_lock_width      1

    add_interface          CSR   axi4             end
    set_interface_property CSR   associatedClock  C_CLK
    set_interface_property CSR   associatedReset  ARESETn
    set_interface_property CSR   readAcceptanceCapability     1
    set_interface_property CSR   writeAcceptanceCapability    1
    set_interface_property CSR   combinedAcceptanceCapability 1
    set_interface_property CSR   readDataReorderingDepth      1
    set_interface_property CSR   ENABLED        true
    add_interface_port     CSR   C_AWID         awid     Input  $csr_id_width
    add_interface_port     CSR   C_AWADDR       awaddr   Input  $csr_addr_width
    add_interface_port     CSR   C_AWLEN        awlen    Input  $csr_burst_length
    add_interface_port     CSR   C_AWSIZE       awsize   Input  3
    add_interface_port     CSR   C_AWBURST      awburst  Input  2
    add_interface_port     CSR   C_AWVALID      awvalid  Input  1
    add_interface_port     CSR   C_AWREADY      awready  Output 1
    add_interface_port     CSR   C_WDATA        wdata    Input  $csr_data_width
    add_interface_port     CSR   C_WSTRB        wstrb    Input  $csr_data_width/8
    add_interface_port     CSR   C_WLAST        wlast    Input  1
    add_interface_port     CSR   C_WVALID       wvalid   Input  1
    add_interface_port     CSR   C_WREADY       wready   Output 1
    add_interface_port     CSR   C_BID          bid      Output $csr_id_width
    add_interface_port     CSR   C_BRESP        bresp    Output 2
    add_interface_port     CSR   C_BVALID       bvalid   Output 1
    add_interface_port     CSR   C_BREADY       bready   Input  1
    add_interface_port     CSR   C_ARID         arid     Input  $csr_id_width
    add_interface_port     CSR   C_ARADDR       araddr   Input  $csr_addr_width
    add_interface_port     CSR   C_ARLEN        arlen    Input  $csr_burst_length
    add_interface_port     CSR   C_ARSIZE       arsize   Input  3
    add_interface_port     CSR   C_ARBURST      arburst  Input  2
    add_interface_port     CSR   C_ARVALID      arvalid  Input  1
    add_interface_port     CSR   C_ARREADY      arready  Output 1
    add_interface_port     CSR   C_RID          rid      Output $csr_id_width
    add_interface_port     CSR   C_RDATA        rdata    Output $csr_data_width
    add_interface_port     CSR   C_RRESP        rresp    Output 2
    add_interface_port     CSR   C_RLAST        rlast    Output 1
    add_interface_port     CSR   C_RVALID       rvalid   Output 1
    add_interface_port     CSR   C_RREADY       rready   Input  1

    # +-----------------------------------
    # | connection point M
    # +-----------------------------------
    set m_id_width        [ get_parameter_value M_ID_WIDTH        ]
    set m_data_width      [ get_parameter_value M_DATA_WIDTH      ]
    set m_addr_width      [ get_parameter_value M_ADDR_WIDTH      ]
    set m_use_addr_user   [ get_parameter_value M_USE_ADDR_USER   ]
    set m_addr_user_width [ get_parameter_value M_AUSER_WIDTH     ]
    set m_data_user_width 4
    set m_burst_length    8
    set m_lock_width      1

    add_interface          M     axi4             start
    set_interface_property M     associatedClock  M_CLK
    set_interface_property M     associatedReset  ARESETn
    set_interface_property M     ENABLED          true
    add_interface_port     M     M_AWID         awid     Output $m_id_width
    add_interface_port     M     M_AWADDR       awaddr   Output $m_addr_width
    add_interface_port     M     M_AWLEN        awlen    Output $m_burst_length
    add_interface_port     M     M_AWSIZE       awsize   Output 3
    add_interface_port     M     M_AWBURST      awburst  Output 2
    add_interface_port     M     M_AWLOCK       awlock   Output $m_lock_width
    add_interface_port     M     M_AWCACHE      awcache  Output 4
    add_interface_port     M     M_AWPROT       awprot   Output 3
    add_interface_port     M     M_AWUSER       awuser   Output $m_addr_user_width
    add_interface_port     M     M_AWQOS        awqos    Output 4
    add_interface_port     M     M_AWREGION     awregion Output 4
    add_interface_port     M     M_AWVALID      awvalid  Output 1
    add_interface_port     M     M_AWREADY      awready  Input  1
    add_interface_port     M     M_WDATA        wdata    Output $m_data_width
    add_interface_port     M     M_WSTRB        wstrb    Output $m_data_width/8
    add_interface_port     M     M_WLAST        wlast    Output 1
    add_interface_port     M     M_WVALID       wvalid   Output 1
    add_interface_port     M     M_WREADY       wready   Input  1
    add_interface_port     M     M_BID          bid      Input  $m_id_width
    add_interface_port     M     M_BRESP        bresp    Input  2
    add_interface_port     M     M_BVALID       bvalid   Input  1
    add_interface_port     M     M_BREADY       bready   Output 1
    add_interface_port     M     M_ARID         arid     Output $m_id_width
    add_interface_port     M     M_ARADDR       araddr   Output $m_addr_width
    add_interface_port     M     M_ARLEN        arlen    Output $m_burst_length
    add_interface_port     M     M_ARSIZE       arsize   Output 3
    add_interface_port     M     M_ARBURST      arburst  Output 2
    add_interface_port     M     M_ARLOCK       arlock   Output $m_lock_width
    add_interface_port     M     M_ARCACHE      arcache  Output 4
    add_interface_port     M     M_ARPROT       arprot   Output 3
    add_interface_port     M     M_ARUSER       aruser   Output $m_addr_user_width
    add_interface_port     M     M_ARQOS        arqos    Output 4
    add_interface_port     M     M_ARREGION     arregion Output 4
    add_interface_port     M     M_ARVALID      arvalid  Output 1
    add_interface_port     M     M_ARREADY      arready  Input  1
    add_interface_port     M     M_RID          rid      Input  $m_id_width
    add_interface_port     M     M_RDATA        rdata    Input  $m_data_width
    add_interface_port     M     M_RRESP        rresp    Input  2
    add_interface_port     M     M_RLAST        rlast    Input  1
    add_interface_port     M     M_RVALID       rvalid   Input  1
    add_interface_port     M     M_RREADY       rready   Output 1

    if { $m_use_addr_user == 0 } {
        set_port_property M_AWUSER TERMINATION true
        set_port_property M_ARUSER TERMINATION true
    }

    # +-----------------------------------
    # | connection point I
    # +-----------------------------------
    set i_id_width        [ get_parameter_value I_ID_WIDTH        ]
    set i_data_width      [ get_parameter_value I_DATA_WIDTH      ]
    set i_addr_width      [ get_parameter_value I_ADDR_WIDTH      ]
    set i_use_addr_user   [ get_parameter_value I_USE_ADDR_USER   ]
    set i_addr_user_width [ get_parameter_value I_AUSER_WIDTH     ]
    set i_burst_length    8
    set i_lock_width      1

    add_interface          I     axi4             start
    set_interface_property I     associatedClock  I_CLK
    set_interface_property I     associatedReset  ARESETn
    set_interface_property I     ENABLED          true
    add_interface_port     I     I_AWID         awid     Output $i_id_width
    add_interface_port     I     I_AWADDR       awaddr   Output $i_addr_width
    add_interface_port     I     I_AWLEN        awlen    Output $i_burst_length
    add_interface_port     I     I_AWSIZE       awsize   Output 3
    add_interface_port     I     I_AWBURST      awburst  Output 2
    add_interface_port     I     I_AWLOCK       awlock   Output $i_lock_width
    add_interface_port     I     I_AWCACHE      awcache  Output 4
    add_interface_port     I     I_AWPROT       awprot   Output 3
    add_interface_port     I     I_AWUSER       awuser   Output $i_addr_user_width
    add_interface_port     I     I_AWQOS        awqos    Output 4
    add_interface_port     I     I_AWREGION     awregion Output 4
    add_interface_port     I     I_AWVALID      awvalid  Output 1
    add_interface_port     I     I_AWREADY      awready  Input  1
    add_interface_port     I     I_WDATA        wdata    Output $i_data_width
    add_interface_port     I     I_WSTRB        wstrb    Output $i_data_width/8
    add_interface_port     I     I_WLAST        wlast    Output 1
    add_interface_port     I     I_WVALID       wvalid   Output 1
    add_interface_port     I     I_WREADY       wready   Input  1
    add_interface_port     I     I_BID          bid      Input  $i_id_width
    add_interface_port     I     I_BRESP        bresp    Input  2
    add_interface_port     I     I_BVALID       bvalid   Input  1
    add_interface_port     I     I_BREADY       bready   Output 1
    add_interface_port     I     I_ARID         arid     Output $i_id_width
    add_interface_port     I     I_ARADDR       araddr   Output $i_addr_width
    add_interface_port     I     I_ARLEN        arlen    Output $i_burst_length
    add_interface_port     I     I_ARSIZE       arsize   Output 3
    add_interface_port     I     I_ARBURST      arburst  Output 2
    add_interface_port     I     I_ARLOCK       arlock   Output $i_lock_width
    add_interface_port     I     I_ARCACHE      arcache  Output 4
    add_interface_port     I     I_ARPROT       arprot   Output 3
    add_interface_port     I     I_ARUSER       aruser   Output $i_addr_user_width
    add_interface_port     I     I_ARQOS        arqos    Output 4
    add_interface_port     I     I_ARREGION     arregion Output 4
    add_interface_port     I     I_ARVALID      arvalid  Output 1
    add_interface_port     I     I_ARREADY      arready  Input  1
    add_interface_port     I     I_RID          rid      Input  $i_id_width
    add_interface_port     I     I_RDATA        rdata    Input  $i_data_width
    add_interface_port     I     I_RRESP        rresp    Input  2
    add_interface_port     I     I_RLAST        rlast    Input  1
    add_interface_port     I     I_RVALID       rvalid   Input  1
    add_interface_port     I     I_RREADY       rready   Output 1

    if { $i_use_addr_user == 0 } {
        set_port_property I_ARUSER TERMINATION true
    }
    ## set_port_property I_AWID     TERMINATION true
    ## set_port_property I_AWADDR   TERMINATION true
    ## set_port_property I_AWLEN    TERMINATION true
    ## set_port_property I_AWSIZE   TERMINATION true
    ## set_port_property I_AWBURST  TERMINATION true
    ## set_port_property I_AWLOCK   TERMINATION true
    ## set_port_property I_AWCACHE  TERMINATION true
    ## set_port_property I_AWPROT   TERMINATION true
    ## set_port_property I_AWUSER   TERMINATION true
    ## set_port_property I_AWQOS    TERMINATION true
    ## set_port_property I_AWREGION TERMINATION true
    ## set_port_property I_AWVALID  TERMINATION true
    ## set_port_property I_AWREADY  TERMINATION true
    ## set_port_property I_WDATA    TERMINATION true
    ## set_port_property I_WSTRB    TERMINATION true
    ## set_port_property I_WLAST    TERMINATION true
    ## set_port_property I_WVALID   TERMINATION true
    ## set_port_property I_WUSER    TERMINATION true
    ## set_port_property I_WREADY   TERMINATION true
    ## set_port_property I_BID      TERMINATION true
    ## set_port_property I_BRESP    TERMINATION true
    ## set_port_property I_BUSER    TERMINATION true
    ## set_port_property I_BVALID   TERMINATION true
    ## set_port_property I_BREADY   TERMINATION true

    # +-----------------------------------
    # | connection point O
    # +-----------------------------------
    set o_id_width        [ get_parameter_value O_ID_WIDTH        ]
    set o_data_width      [ get_parameter_value O_DATA_WIDTH      ]
    set o_addr_width      [ get_parameter_value O_ADDR_WIDTH      ]
    set o_use_addr_user   [ get_parameter_value O_USE_ADDR_USER   ]
    set o_addr_user_width [ get_parameter_value O_AUSER_WIDTH     ]
    set o_burst_length    8
    set o_lock_width      1

    add_interface          O     axi4             start
    set_interface_property O     associatedClock  O_CLK
    set_interface_property O     associatedReset  ARESETn
    set_interface_property O     ENABLED          true
    add_interface_port     O     O_AWID         awid     Output $o_id_width
    add_interface_port     O     O_AWADDR       awaddr   Output $o_addr_width
    add_interface_port     O     O_AWLEN        awlen    Output $o_burst_length
    add_interface_port     O     O_AWSIZE       awsize   Output 3
    add_interface_port     O     O_AWBURST      awburst  Output 2
    add_interface_port     O     O_AWLOCK       awlock   Output $o_lock_width
    add_interface_port     O     O_AWCACHE      awcache  Output 4
    add_interface_port     O     O_AWPROT       awprot   Output 3
    add_interface_port     O     O_AWUSER       awuser   Output $o_addr_user_width
    add_interface_port     O     O_AWQOS        awqos    Output 4
    add_interface_port     O     O_AWREGION     awregion Output 4
    add_interface_port     O     O_AWVALID      awvalid  Output 1
    add_interface_port     O     O_AWREADY      awready  Input  1
    add_interface_port     O     O_WDATA        wdata    Output $o_data_width
    add_interface_port     O     O_WSTRB        wstrb    Output $o_data_width/8
    add_interface_port     O     O_WLAST        wlast    Output 1
    add_interface_port     O     O_WVALID       wvalid   Output 1
    add_interface_port     O     O_WREADY       wready   Input  1
    add_interface_port     O     O_BID          bid      Input  $o_id_width
    add_interface_port     O     O_BRESP        bresp    Input  2
    add_interface_port     O     O_BVALID       bvalid   Input  1
    add_interface_port     O     O_BREADY       bready   Output 1
    add_interface_port     O     O_ARID         arid     Output $o_id_width
    add_interface_port     O     O_ARADDR       araddr   Output $o_addr_width
    add_interface_port     O     O_ARLEN        arlen    Output $o_burst_length
    add_interface_port     O     O_ARSIZE       arsize   Output 3
    add_interface_port     O     O_ARBURST      arburst  Output 2
    add_interface_port     O     O_ARLOCK       arlock   Output $o_lock_width
    add_interface_port     O     O_ARCACHE      arcache  Output 4
    add_interface_port     O     O_ARPROT       arprot   Output 3
    add_interface_port     O     O_ARUSER       aruser   Output $o_addr_user_width
    add_interface_port     O     O_ARQOS        arqos    Output 4
    add_interface_port     O     O_ARREGION     arregion Output 4
    add_interface_port     O     O_ARVALID      arvalid  Output 1
    add_interface_port     O     O_ARREADY      arready  Input  1
    add_interface_port     O     O_RID          rid      Input  $o_id_width
    add_interface_port     O     O_RDATA        rdata    Input  $o_data_width
    add_interface_port     O     O_RRESP        rresp    Input  2
    add_interface_port     O     O_RLAST        rlast    Input  1
    add_interface_port     O     O_RVALID       rvalid   Input  1
    add_interface_port     O     O_RREADY       rready   Output 1

    if { $o_use_addr_user == 0 } {
        set_port_property O_AWUSER TERMINATION true
    }
    ## set_port_property O_ARUSER   TERMINATION true
    ## set_port_property O_ARID     TERMINATION true
    ## set_port_property O_ARADDR   TERMINATION true
    ## set_port_property O_ARLEN    TERMINATION true
    ## set_port_property O_ARSIZE   TERMINATION true
    ## set_port_property O_ARBURST  TERMINATION true
    ## set_port_property O_ARLOCK   TERMINATION true
    ## set_port_property O_ARCACHE  TERMINATION true
    ## set_port_property O_ARPROT   TERMINATION true
    ## set_port_property O_ARUSER   TERMINATION true
    ## set_port_property O_ARQOS    TERMINATION true
    ## set_port_property O_ARREGION TERMINATION true
    ## set_port_property O_ARVALID  TERMINATION true
    ## set_port_property O_ARREADY  TERMINATION true
    ## set_port_property O_RID      TERMINATION true
    ## set_port_property O_RDATA    TERMINATION true
    ## set_port_property O_RRESP    TERMINATION true
    ## set_port_property O_RLAST    TERMINATION true
    ## set_port_property O_RVALID   TERMINATION true
    ## set_port_property O_RREADY   TERMINATION true
    ## set_port_property O_RUSER    TERMINATION true
}

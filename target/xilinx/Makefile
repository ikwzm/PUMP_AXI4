IP_VENDOR_NAME  ?= ikwzm
IP_LIBRARY_NAME ?= pipework
IP_NAME         ?= pump_axi3_to_axi3
IP_VERSION      ?= 2.4

IP_ROOT_DIR     := ./ip/$(IP_VENDOR_NAME)_$(IP_LIBRARY_NAME)_$(IP_NAME)_$(IP_VERSION)
IP_VHDL_DIR     := $(IP_ROOT_DIR)/src/vhdl
IP_XGUI_DIR     := $(IP_ROOT_DIR)/xgui

XGUI_VERSION    := $(addprefix v,$(subst .,_,$(IP_VERSION)))
XGUI_FILE       := $(IP_NAME)_$(XGUI_VERSION).tcl

VHDL_FILES      := pipework.vhd               \
                   pump_axi4_to_axi4.vhd      \
                   pump_axi4_to_axi4_core.vhd \
                   $(ENDLIST)
ifeq ($(IP_NAME), pump_axi3_to_axi3)
    VHDL_FILES  += pump_axi3_to_axi3.vhd
endif
VHDL_SRC_DIR    := ../../src/main/vhdl
VHDL_SRC_FILES  := $(addprefix $(VHDL_SRC_DIR)/,$(VHDL_FILES))

IP_VHDL_FILES   := $(addprefix $(IP_VHDL_DIR)/,$(VHDL_FILES))
IP_XGUI_FILE    := $(addprefix $(IP_XGUI_DIR)/,$(XGUI_FILE))
IP_ICON_FILE    := $(IP_ROOT_DIR)/src/PipeWork.png

INSTALL := install
COPY    := cp

all: $(IP_VHDL_FILES) $(IP_XGUI_FILE) $(IP_ICON_FILE)

$(IP_VHDL_DIR)/pipework.vhd : libs.yml
	$(INSTALL) -d $(IP_VHDL_DIR)
	../../PipeWork/tools/vhdl-archiver.rb --config libs.yml --library pipework --archive $@

$(IP_VHDL_DIR)/pump_axi3_to_axi3.vhd : $(VHDL_SRC_DIR)/pump_axi3_to_axi3.vhd
	$(INSTALL) -d $(IP_VHDL_DIR)
	$(COPY) $< $@

$(IP_VHDL_DIR)/pump_axi4_to_axi4.vhd : $(VHDL_SRC_DIR)/pump_axi4_to_axi4.vhd
	$(INSTALL) -d $(IP_VHDL_DIR)
	$(COPY) $< $@

$(IP_VHDL_DIR)/pump_axi4_to_axi4_core.vhd : $(VHDL_SRC_DIR)/pump_axi4_to_axi4_core.vhd
	$(INSTALL) -d $(IP_VHDL_DIR)
	$(COPY) $< $@

$(IP_ICON_FILE) : ../../PipeWork/icons/PipeWork_100x100.png
	$(INSTALL) -d $(IP_VHDL_DIR)
	$(COPY) $< $@

$(IP_XGUI_FILE) : ./xgui/$(XGUI_FILE)
	$(INSTALL) -d $(IP_XGUI_DIR)
	$(COPY) $< $@


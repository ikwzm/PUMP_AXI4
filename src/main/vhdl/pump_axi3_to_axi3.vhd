-----------------------------------------------------------------------------------
--!     @file    pump_axi3_to_axi3.vhd
--!     @brief   Pump Sample Module (AXI3 to AXI3)
--!     @version 1.0.0
--!     @date    2015/12/21
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2015 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
-----------------------------------------------------------------------------------
--! @brief 
-----------------------------------------------------------------------------------
entity  PUMP_AXI3_TO_AXI3 is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        C_ADDR_WIDTH    : integer range 1 to   64 := 32;
        C_DATA_WIDTH    : integer range 8 to 1024 := 32;
        C_ID_WIDTH      : integer                 :=  8;
        M_ADDR_WIDTH    : integer range 1 to   64 := 32;
        M_DATA_WIDTH    : integer range 8 to 1024 := 32;
        M_ID_WIDTH      : integer                 :=  8;
        M_AUSER_WIDTH   : integer                 :=  4;
        M_AXI_ID        : integer                 :=  1;
        I_AXI_ID        : integer                 :=  1;
        I_ADDR_WIDTH    : integer range 1 to   64 := 32;
        I_DATA_WIDTH    : integer range 8 to 1024 := 32;
        I_ID_WIDTH      : integer                 :=  8;
        I_AUSER_WIDTH   : integer                 :=  4;
        I_MAX_XFER_SIZE : integer                 :=  8;
        I_PROC_VALID    : integer range 0 to    1 :=  1;
        O_AXI_ID        : integer                 :=  2;
        O_ADDR_WIDTH    : integer range 1 to   64 := 32;
        O_DATA_WIDTH    : integer range 8 to 1024 := 32;
        O_ID_WIDTH      : integer                 :=  8;
        O_AUSER_WIDTH   : integer                 :=  4;
        O_MAX_XFER_SIZE : integer                 :=  8;
        O_PROC_VALID    : integer range 0 to    1 :=  1;
        BUF_DEPTH       : integer                 := 12
    );
    port(
    -------------------------------------------------------------------------------
    -- Reset Signals.
    -------------------------------------------------------------------------------
        ARESETn         : in    std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F Clock.
    -------------------------------------------------------------------------------
        C_CLK           : in    std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        C_ARID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_ARADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
        C_ARLEN         : in    std_logic_vector(3 downto 0);
        C_ARSIZE        : in    std_logic_vector(2 downto 0);
        C_ARBURST       : in    std_logic_vector(1 downto 0);
        C_ARVALID       : in    std_logic;
        C_ARREADY       : out   std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        C_RID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_RDATA         : out   std_logic_vector(C_DATA_WIDTH  -1 downto 0);
        C_RRESP         : out   std_logic_vector(1 downto 0);
        C_RLAST         : out   std_logic;
        C_RVALID        : out   std_logic;
        C_RREADY        : in    std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        C_AWID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_AWADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
        C_AWLEN         : in    std_logic_vector(3 downto 0);
        C_AWSIZE        : in    std_logic_vector(2 downto 0);
        C_AWBURST       : in    std_logic_vector(1 downto 0);
        C_AWVALID       : in    std_logic;
        C_AWREADY       : out   std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        C_WDATA         : in    std_logic_vector(C_DATA_WIDTH  -1 downto 0);
        C_WSTRB         : in    std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
        C_WLAST         : in    std_logic;
        C_WVALID        : in    std_logic;
        C_WREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Control Status Register I/F AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        C_BID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_BRESP         : out   std_logic_vector(1 downto 0);
        C_BVALID        : out   std_logic;
        C_BREADY        : in    std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch I/F Clock.
    -------------------------------------------------------------------------------
        M_CLK           : in    std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch I/F AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        M_ARID          : out   std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_ARADDR        : out   std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
        M_ARLEN         : out   std_logic_vector(3 downto 0);
        M_ARSIZE        : out   std_logic_vector(2 downto 0);
        M_ARBURST       : out   std_logic_vector(1 downto 0);
        M_ARLOCK        : out   std_logic_vector(1 downto 0);
        M_ARCACHE       : out   std_logic_vector(3 downto 0);
        M_ARPROT        : out   std_logic_vector(2 downto 0);
        M_ARQOS         : out   std_logic_vector(3 downto 0);
        M_ARREGION      : out   std_logic_vector(3 downto 0);
        M_ARUSER        : out   std_logic_vector(M_AUSER_WIDTH -1 downto 0);
        M_ARVALID       : out   std_logic;
        M_ARREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch I/F AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        M_RID           : in    std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_RDATA         : in    std_logic_vector(M_DATA_WIDTH  -1 downto 0);
        M_RRESP         : in    std_logic_vector(1 downto 0);
        M_RLAST         : in    std_logic;
        M_RVALID        : in    std_logic;
        M_RREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch I/F AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        M_AWID          : out   std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_AWADDR        : out   std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
        M_AWLEN         : out   std_logic_vector(3 downto 0);
        M_AWSIZE        : out   std_logic_vector(2 downto 0);
        M_AWBURST       : out   std_logic_vector(1 downto 0);
        M_AWLOCK        : out   std_logic_vector(1 downto 0);
        M_AWCACHE       : out   std_logic_vector(3 downto 0);
        M_AWPROT        : out   std_logic_vector(2 downto 0);
        M_AWQOS         : out   std_logic_vector(3 downto 0);
        M_AWREGION      : out   std_logic_vector(3 downto 0);
        M_AWUSER        : out   std_logic_vector(M_AUSER_WIDTH -1 downto 0);
        M_AWVALID       : out   std_logic;
        M_AWREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch I/F AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        M_WID           : out   std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_WDATA         : out   std_logic_vector(M_DATA_WIDTH  -1 downto 0);
        M_WSTRB         : out   std_logic_vector(M_DATA_WIDTH/8-1 downto 0);
        M_WLAST         : out   std_logic;
        M_WVALID        : out   std_logic;
        M_WREADY        : in    std_logic;
    -------------------------------------------------------------------------------
    -- Operation Code Fetch I/F AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        M_BID           : in    std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_BRESP         : in    std_logic_vector(1 downto 0);
        M_BVALID        : in    std_logic;
        M_BREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F Clock.
    -------------------------------------------------------------------------------
        I_CLK           : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        I_AWID          : out   std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_AWADDR        : out   std_logic_vector(I_ADDR_WIDTH  -1 downto 0);
        I_AWLEN         : out   std_logic_vector(3 downto 0);
        I_AWSIZE        : out   std_logic_vector(2 downto 0);
        I_AWBURST       : out   std_logic_vector(1 downto 0);
        I_AWLOCK        : out   std_logic_vector(1 downto 0);
        I_AWCACHE       : out   std_logic_vector(3 downto 0);
        I_AWPROT        : out   std_logic_vector(2 downto 0);
        I_AWQOS         : out   std_logic_vector(3 downto 0);
        I_AWREGION      : out   std_logic_vector(3 downto 0);
        I_AWUSER        : out   std_logic_vector(I_AUSER_WIDTH -1 downto 0);
        I_AWVALID       : out   std_logic;
        I_AWREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        I_WID           : out   std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_WDATA         : out   std_logic_vector(I_DATA_WIDTH  -1 downto 0);
        I_WSTRB         : out   std_logic_vector(I_DATA_WIDTH/8-1 downto 0);
        I_WLAST         : out   std_logic;
        I_WVALID        : out   std_logic;
        I_WREADY        : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        I_BID           : in    std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_BRESP         : in    std_logic_vector(1 downto 0);
        I_BVALID        : in    std_logic;
        I_BREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        I_ARID          : out   std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_ARADDR        : out   std_logic_vector(I_ADDR_WIDTH  -1 downto 0);
        I_ARLEN         : out   std_logic_vector(3 downto 0);
        I_ARSIZE        : out   std_logic_vector(2 downto 0);
        I_ARBURST       : out   std_logic_vector(1 downto 0);
        I_ARLOCK        : out   std_logic_vector(1 downto 0);
        I_ARCACHE       : out   std_logic_vector(3 downto 0);
        I_ARPROT        : out   std_logic_vector(2 downto 0);
        I_ARQOS         : out   std_logic_vector(3 downto 0);
        I_ARREGION      : out   std_logic_vector(3 downto 0);
        I_ARUSER        : out   std_logic_vector(I_AUSER_WIDTH -1 downto 0);
        I_ARVALID       : out   std_logic;
        I_ARREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Intake I/F AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        I_RID           : in    std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_RDATA         : in    std_logic_vector(I_DATA_WIDTH  -1 downto 0);
        I_RRESP         : in    std_logic_vector(1 downto 0);
        I_RLAST         : in    std_logic;
        I_RVALID        : in    std_logic;
        I_RREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F Clock.
    -------------------------------------------------------------------------------
        O_CLK           : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F AXI4 Read Address Channel Signals.
    -------------------------------------------------------------------------------
        O_ARID          : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_ARADDR        : out   std_logic_vector(O_ADDR_WIDTH  -1 downto 0);
        O_ARLEN         : out   std_logic_vector(3 downto 0);
        O_ARSIZE        : out   std_logic_vector(2 downto 0);
        O_ARBURST       : out   std_logic_vector(1 downto 0);
        O_ARLOCK        : out   std_logic_vector(1 downto 0);
        O_ARCACHE       : out   std_logic_vector(3 downto 0);
        O_ARPROT        : out   std_logic_vector(2 downto 0);
        O_ARQOS         : out   std_logic_vector(3 downto 0);
        O_ARREGION      : out   std_logic_vector(3 downto 0);
        O_ARUSER        : out   std_logic_vector(O_AUSER_WIDTH -1 downto 0);
        O_ARVALID       : out   std_logic;
        O_ARREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F AXI4 Read Data Channel Signals.
    -------------------------------------------------------------------------------
        O_RID           : in    std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_RDATA         : in    std_logic_vector(O_DATA_WIDTH  -1 downto 0);
        O_RRESP         : in    std_logic_vector(1 downto 0);
        O_RLAST         : in    std_logic;
        O_RVALID        : in    std_logic;
        O_RREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F AXI4 Write Address Channel Signals.
    -------------------------------------------------------------------------------
        O_AWID          : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_AWADDR        : out   std_logic_vector(O_ADDR_WIDTH  -1 downto 0);
        O_AWLEN         : out   std_logic_vector(3 downto 0);
        O_AWSIZE        : out   std_logic_vector(2 downto 0);
        O_AWBURST       : out   std_logic_vector(1 downto 0);
        O_AWLOCK        : out   std_logic_vector(1 downto 0);
        O_AWCACHE       : out   std_logic_vector(3 downto 0);
        O_AWPROT        : out   std_logic_vector(2 downto 0);
        O_AWQOS         : out   std_logic_vector(3 downto 0);
        O_AWREGION      : out   std_logic_vector(3 downto 0);
        O_AWUSER        : out   std_logic_vector(O_AUSER_WIDTH -1 downto 0);
        O_AWVALID       : out   std_logic;
        O_AWREADY       : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F AXI4 Write Data Channel Signals.
    -------------------------------------------------------------------------------
        O_WID           : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_WDATA         : out   std_logic_vector(O_DATA_WIDTH  -1 downto 0);
        O_WSTRB         : out   std_logic_vector(O_DATA_WIDTH/8-1 downto 0);
        O_WLAST         : out   std_logic;
        O_WVALID        : out   std_logic;
        O_WREADY        : in    std_logic;
    -------------------------------------------------------------------------------
    -- Pump Outlet I/F AXI4 Write Response Channel Signals.
    -------------------------------------------------------------------------------
        O_BID           : in    std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_BRESP         : in    std_logic_vector(1 downto 0);
        O_BVALID        : in    std_logic;
        O_BREADY        : out   std_logic;
    -------------------------------------------------------------------------------
    -- Interrupt Request Signals.
    -------------------------------------------------------------------------------
        I_IRQ           : out   std_logic;
        O_IRQ           : out   std_logic;
        IRQ             : out   std_logic
    );
end PUMP_AXI3_TO_AXI3;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
architecture RTL of PUMP_AXI3_TO_AXI3 is
    component PUMP_AXI4_TO_AXI4 is
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        generic (
            C_ADDR_WIDTH    : integer range 1 to   64 := 32;
            C_DATA_WIDTH    : integer range 8 to 1024 := 32;
            C_ID_WIDTH      : integer                 :=  8;
            M_ADDR_WIDTH    : integer range 1 to   64 := 32;
            M_DATA_WIDTH    : integer range 8 to 1024 := 32;
            M_ID_WIDTH      : integer                 :=  8;
            M_AUSER_WIDTH   : integer                 :=  4;
            M_AXI_ID        : integer                 :=  1;
            I_AXI_ID        : integer                 :=  1;
            I_ADDR_WIDTH    : integer range 1 to   64 := 32;
            I_DATA_WIDTH    : integer range 8 to 1024 := 32;
            I_ID_WIDTH      : integer                 :=  8;
            I_AUSER_WIDTH   : integer                 :=  4;
            I_MAX_XFER_SIZE : integer                 :=  8;
            I_PROC_VALID    : integer range 0 to    1 :=  1;
            O_AXI_ID        : integer                 :=  2;
            O_ADDR_WIDTH    : integer range 1 to   64 := 32;
            O_DATA_WIDTH    : integer range 8 to 1024 := 32;
            O_ID_WIDTH      : integer                 :=  8;
            O_AUSER_WIDTH   : integer                 :=  4;
            O_MAX_XFER_SIZE : integer                 :=  8;
            O_PROC_VALID    : integer range 0 to    1 :=  1;
            BUF_DEPTH       : integer                 := 12
        );
        port(
        ---------------------------------------------------------------------------
        -- Reset Signals.
        ---------------------------------------------------------------------------
            ARESETn         : in    std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F Clock.
        ---------------------------------------------------------------------------
            C_CLK           : in    std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            C_ARID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_ARADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
            C_ARLEN         : in    std_logic_vector(7 downto 0);
            C_ARSIZE        : in    std_logic_vector(2 downto 0);
            C_ARBURST       : in    std_logic_vector(1 downto 0);
            C_ARVALID       : in    std_logic;
            C_ARREADY       : out   std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            C_RID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_RDATA         : out   std_logic_vector(C_DATA_WIDTH  -1 downto 0);
            C_RRESP         : out   std_logic_vector(1 downto 0);
            C_RLAST         : out   std_logic;
            C_RVALID        : out   std_logic;
            C_RREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            C_AWID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_AWADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
            C_AWLEN         : in    std_logic_vector(7 downto 0);
            C_AWSIZE        : in    std_logic_vector(2 downto 0);
            C_AWBURST       : in    std_logic_vector(1 downto 0);
            C_AWVALID       : in    std_logic;
            C_AWREADY       : out   std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            C_WDATA         : in    std_logic_vector(C_DATA_WIDTH  -1 downto 0);
            C_WSTRB         : in    std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
            C_WLAST         : in    std_logic;
            C_WVALID        : in    std_logic;
            C_WREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            C_BID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_BRESP         : out   std_logic_vector(1 downto 0);
            C_BVALID        : out   std_logic;
            C_BREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F Clock.
        ---------------------------------------------------------------------------
            M_CLK           : in    std_logic;
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            M_ARID          : out   std_logic_vector(M_ID_WIDTH    -1 downto 0);
            M_ARADDR        : out   std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
            M_ARLEN         : out   std_logic_vector(7 downto 0);
            M_ARSIZE        : out   std_logic_vector(2 downto 0);
            M_ARBURST       : out   std_logic_vector(1 downto 0);
            M_ARLOCK        : out   std_logic_vector(0 downto 0);
            M_ARCACHE       : out   std_logic_vector(3 downto 0);
            M_ARPROT        : out   std_logic_vector(2 downto 0);
            M_ARQOS         : out   std_logic_vector(3 downto 0);
            M_ARREGION      : out   std_logic_vector(3 downto 0);
            M_ARUSER        : out   std_logic_vector(M_AUSER_WIDTH -1 downto 0);
            M_ARVALID       : out   std_logic;
            M_ARREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            M_RID           : in    std_logic_vector(M_ID_WIDTH    -1 downto 0);
            M_RDATA         : in    std_logic_vector(M_DATA_WIDTH  -1 downto 0);
            M_RRESP         : in    std_logic_vector(1 downto 0);
            M_RLAST         : in    std_logic;
            M_RVALID        : in    std_logic;
            M_RREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            M_AWID          : out   std_logic_vector(M_ID_WIDTH    -1 downto 0);
            M_AWADDR        : out   std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
            M_AWLEN         : out   std_logic_vector(7 downto 0);
            M_AWSIZE        : out   std_logic_vector(2 downto 0);
            M_AWBURST       : out   std_logic_vector(1 downto 0);
            M_AWLOCK        : out   std_logic_vector(0 downto 0);
            M_AWCACHE       : out   std_logic_vector(3 downto 0);
            M_AWPROT        : out   std_logic_vector(2 downto 0);
            M_AWQOS         : out   std_logic_vector(3 downto 0);
            M_AWREGION      : out   std_logic_vector(3 downto 0);
            M_AWUSER        : out   std_logic_vector(M_AUSER_WIDTH -1 downto 0);
            M_AWVALID       : out   std_logic;
            M_AWREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            M_WDATA         : out   std_logic_vector(M_DATA_WIDTH  -1 downto 0);
            M_WSTRB         : out   std_logic_vector(M_DATA_WIDTH/8-1 downto 0);
            M_WLAST         : out   std_logic;
            M_WVALID        : out   std_logic;
            M_WREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            M_BID           : in    std_logic_vector(M_ID_WIDTH    -1 downto 0);
            M_BRESP         : in    std_logic_vector(1 downto 0);
            M_BVALID        : in    std_logic;
            M_BREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Pump Intake I/F Clock.
        ---------------------------------------------------------------------------
            I_CLK           : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Intake I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            I_AWID          : out   std_logic_vector(I_ID_WIDTH    -1 downto 0);
            I_AWADDR        : out   std_logic_vector(I_ADDR_WIDTH  -1 downto 0);
            I_AWLEN         : out   std_logic_vector(7 downto 0);
            I_AWSIZE        : out   std_logic_vector(2 downto 0);
            I_AWBURST       : out   std_logic_vector(1 downto 0);
            I_AWLOCK        : out   std_logic_vector(0 downto 0);
            I_AWCACHE       : out   std_logic_vector(3 downto 0);
            I_AWPROT        : out   std_logic_vector(2 downto 0);
            I_AWQOS         : out   std_logic_vector(3 downto 0);
            I_AWREGION      : out   std_logic_vector(3 downto 0);
            I_AWUSER        : out   std_logic_vector(I_AUSER_WIDTH -1 downto 0);
            I_AWVALID       : out   std_logic;
            I_AWREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Intake I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            I_WDATA         : out   std_logic_vector(I_DATA_WIDTH  -1 downto 0);
            I_WSTRB         : out   std_logic_vector(I_DATA_WIDTH/8-1 downto 0);
            I_WLAST         : out   std_logic;
            I_WVALID        : out   std_logic;
            I_WREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Intake I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            I_BID           : in    std_logic_vector(I_ID_WIDTH    -1 downto 0);
            I_BRESP         : in    std_logic_vector(1 downto 0);
            I_BVALID        : in    std_logic;
            I_BREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Pump Intake I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            I_ARID          : out   std_logic_vector(I_ID_WIDTH    -1 downto 0);
            I_ARADDR        : out   std_logic_vector(I_ADDR_WIDTH  -1 downto 0);
            I_ARLEN         : out   std_logic_vector(7 downto 0);
            I_ARSIZE        : out   std_logic_vector(2 downto 0);
            I_ARBURST       : out   std_logic_vector(1 downto 0);
            I_ARLOCK        : out   std_logic_vector(0 downto 0);
            I_ARCACHE       : out   std_logic_vector(3 downto 0);
            I_ARPROT        : out   std_logic_vector(2 downto 0);
            I_ARQOS         : out   std_logic_vector(3 downto 0);
            I_ARREGION      : out   std_logic_vector(3 downto 0);
            I_ARUSER        : out   std_logic_vector(I_AUSER_WIDTH -1 downto 0);
            I_ARVALID       : out   std_logic;
            I_ARREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Intake I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            I_RID           : in    std_logic_vector(I_ID_WIDTH    -1 downto 0);
            I_RDATA         : in    std_logic_vector(I_DATA_WIDTH  -1 downto 0);
            I_RRESP         : in    std_logic_vector(1 downto 0);
            I_RLAST         : in    std_logic;
            I_RVALID        : in    std_logic;
            I_RREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F Clock.
        ---------------------------------------------------------------------------
            O_CLK           : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            O_ARID          : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_ARADDR        : out   std_logic_vector(O_ADDR_WIDTH  -1 downto 0);
            O_ARLEN         : out   std_logic_vector(7 downto 0);
            O_ARSIZE        : out   std_logic_vector(2 downto 0);
            O_ARBURST       : out   std_logic_vector(1 downto 0);
            O_ARLOCK        : out   std_logic_vector(0 downto 0);
            O_ARCACHE       : out   std_logic_vector(3 downto 0);
            O_ARPROT        : out   std_logic_vector(2 downto 0);
            O_ARQOS         : out   std_logic_vector(3 downto 0);
            O_ARREGION      : out   std_logic_vector(3 downto 0);
            O_ARUSER        : out   std_logic_vector(O_AUSER_WIDTH -1 downto 0);
            O_ARVALID       : out   std_logic;
            O_ARREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            O_RID           : in    std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_RDATA         : in    std_logic_vector(O_DATA_WIDTH  -1 downto 0);
            O_RRESP         : in    std_logic_vector(1 downto 0);
            O_RLAST         : in    std_logic;
            O_RVALID        : in    std_logic;
            O_RREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            O_AWID          : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_AWADDR        : out   std_logic_vector(O_ADDR_WIDTH  -1 downto 0);
            O_AWLEN         : out   std_logic_vector(7 downto 0);
            O_AWSIZE        : out   std_logic_vector(2 downto 0);
            O_AWBURST       : out   std_logic_vector(1 downto 0);
            O_AWLOCK        : out   std_logic_vector(0 downto 0);
            O_AWCACHE       : out   std_logic_vector(3 downto 0);
            O_AWPROT        : out   std_logic_vector(2 downto 0);
            O_AWQOS         : out   std_logic_vector(3 downto 0);
            O_AWREGION      : out   std_logic_vector(3 downto 0);
            O_AWUSER        : out   std_logic_vector(O_AUSER_WIDTH -1 downto 0);
            O_AWVALID       : out   std_logic;
            O_AWREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            O_WDATA         : out   std_logic_vector(O_DATA_WIDTH  -1 downto 0);
            O_WSTRB         : out   std_logic_vector(O_DATA_WIDTH/8-1 downto 0);
            O_WLAST         : out   std_logic;
            O_WVALID        : out   std_logic;
            O_WREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            O_BID           : in    std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_BRESP         : in    std_logic_vector(1 downto 0);
            O_BVALID        : in    std_logic;
            O_BREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Interrupt Request Signals.
        ---------------------------------------------------------------------------
            I_IRQ           : out   std_logic;
            O_IRQ           : out   std_logic;
            IRQ             : out   std_logic
        );
    end component;
    signal  m_arlen_hi      : std_logic_vector(7 downto 4);
    signal  m_awlen_hi      : std_logic_vector(7 downto 4);
    signal  i_arlen_hi      : std_logic_vector(7 downto 4);
    signal  i_awlen_hi      : std_logic_vector(7 downto 4);
    signal  o_arlen_hi      : std_logic_vector(7 downto 4);
    signal  o_awlen_hi      : std_logic_vector(7 downto 4);
begin
    U: PUMP_AXI4_TO_AXI4 
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        generic map (
            C_ADDR_WIDTH    => C_ADDR_WIDTH    ,
            C_DATA_WIDTH    => C_DATA_WIDTH    ,
            C_ID_WIDTH      => C_ID_WIDTH      ,
            M_ADDR_WIDTH    => M_ADDR_WIDTH    ,
            M_DATA_WIDTH    => M_DATA_WIDTH    ,
            M_ID_WIDTH      => M_ID_WIDTH      ,
            M_AUSER_WIDTH   => M_AUSER_WIDTH   ,
            M_AXI_ID        => M_AXI_ID        ,
            I_AXI_ID        => I_AXI_ID        ,
            I_ADDR_WIDTH    => I_ADDR_WIDTH    ,
            I_DATA_WIDTH    => I_DATA_WIDTH    ,
            I_ID_WIDTH      => I_ID_WIDTH      ,
            I_AUSER_WIDTH   => I_AUSER_WIDTH   ,
            I_MAX_XFER_SIZE => I_MAX_XFER_SIZE ,
            I_PROC_VALID    => I_PROC_VALID    ,
            O_AXI_ID        => O_AXI_ID        ,
            O_ADDR_WIDTH    => O_ADDR_WIDTH    ,
            O_DATA_WIDTH    => O_DATA_WIDTH    ,
            O_ID_WIDTH      => O_ID_WIDTH      ,
            O_AUSER_WIDTH   => O_AUSER_WIDTH   ,
            O_MAX_XFER_SIZE => O_MAX_XFER_SIZE ,
            O_PROC_VALID    => O_PROC_VALID    ,
            BUF_DEPTH       => BUF_DEPTH       
        )
        port map(
        ---------------------------------------------------------------------------
        -- Reset Signals.
        ---------------------------------------------------------------------------
            ARESETn             => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F Clock.
        ---------------------------------------------------------------------------
            C_CLK               => C_CLK           , -- In  :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            C_ARID              => C_ARID          , -- In  :
            C_ARADDR            => C_ARADDR        , -- In  :
            C_ARLEN(3 downto 0) => C_ARLEN         , -- In  :
            C_ARLEN(7 downto 4) => "0000"          , -- In  :
            C_ARSIZE            => C_ARSIZE        , -- In  :
            C_ARBURST           => C_ARBURST       , -- In  :
            C_ARVALID           => C_ARVALID       , -- In  :
            C_ARREADY           => C_ARREADY       , -- Out :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            C_RID               => C_RID           , -- Out :
            C_RDATA             => C_RDATA         , -- Out :
            C_RRESP             => C_RRESP         , -- Out :
            C_RLAST             => C_RLAST         , -- Out :
            C_RVALID            => C_RVALID        , -- Out :
            C_RREADY            => C_RREADY        , -- In  :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            C_AWID              => C_AWID          , -- In  :
            C_AWADDR            => C_AWADDR        , -- In  :
            C_AWLEN(3 downto 0) => C_AWLEN         , -- In  :
            C_AWLEN(7 downto 4) => "0000"          , -- In  :
            C_AWSIZE            => C_AWSIZE        , -- In  :
            C_AWBURST           => C_AWBURST       , -- In  :
            C_AWVALID           => C_AWVALID       , -- In  :
            C_AWREADY           => C_AWREADY       , -- Out :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            C_WDATA             => C_WDATA         , -- In  :
            C_WSTRB             => C_WSTRB         , -- In  :
            C_WLAST             => C_WLAST         , -- In  :
            C_WVALID            => C_WVALID        , -- In  :
            C_WREADY            => C_WREADY        , -- Out :
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            C_BID               => C_BID           , -- Out :
            C_BRESP             => C_BRESP         , -- Out :
            C_BVALID            => C_BVALID        , -- Out :
            C_BREADY            => C_BREADY        , -- In  :
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F Clock.
        ---------------------------------------------------------------------------
            M_CLK               => M_CLK           , -- In  :
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            M_ARID              => open            , -- Out :
            M_ARADDR            => M_ARADDR        , -- Out :
            M_ARLEN(3 downto 0) => M_ARLEN         , -- Out :
            M_ARLEN(7 downto 4) => m_arlen_hi      , -- Out :
            M_ARSIZE            => M_ARSIZE        , -- Out :
            M_ARBURST           => M_ARBURST       , -- Out :
            M_ARLOCK(0)         => M_ARLOCK(0)     , -- Out :
            M_ARCACHE           => M_ARCACHE       , -- Out :
            M_ARPROT            => M_ARPROT        , -- Out :
            M_ARQOS             => M_ARQOS         , -- Out :
            M_ARREGION          => M_ARREGION      , -- Out :
            M_ARUSER            => M_ARUSER        , -- Out :
            M_ARVALID           => M_ARVALID       , -- Out :
            M_ARREADY           => M_ARREADY       , -- In  :
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            M_RID               => M_RID           , -- In  :
            M_RDATA             => M_RDATA         , -- In  :
            M_RRESP             => M_RRESP         , -- In  :
            M_RLAST             => M_RLAST         , -- In  :
            M_RVALID            => M_RVALID        , -- In  :
            M_RREADY            => M_RREADY        , -- Out :
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            M_AWID              => open            , -- Out :
            M_AWADDR            => M_AWADDR        , -- Out :
            M_AWLEN(3 downto 0) => M_AWLEN         , -- Out :
            M_AWLEN(7 downto 4) => m_awlen_hi      , -- Out :
            M_AWSIZE            => M_AWSIZE        , -- Out :
            M_AWBURST           => M_AWBURST       , -- Out :
            M_AWLOCK(0)         => M_AWLOCK(0)     , -- Out :
            M_AWCACHE           => M_AWCACHE       , -- Out :
            M_AWPROT            => M_AWPROT        , -- Out :
            M_AWQOS             => M_AWQOS         , -- Out :
            M_AWREGION          => M_AWREGION      , -- Out :
            M_AWUSER            => M_AWUSER        , -- Out :
            M_AWVALID           => M_AWVALID       , -- Out :
            M_AWREADY           => M_AWREADY       , -- In  :
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            M_WDATA             => M_WDATA         , -- Out :
            M_WSTRB             => M_WSTRB         , -- Out :
            M_WLAST             => M_WLAST         , -- Out :
            M_WVALID            => M_WVALID        , -- Out :
            M_WREADY            => M_WREADY        , -- In  :
        ---------------------------------------------------------------------------
        -- Operation Code Fetch I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            M_BID               => M_BID           , -- In  :
            M_BRESP             => M_BRESP         , -- In  :
            M_BVALID            => M_BVALID        , -- In  :
            M_BREADY            => M_BREADY        , -- Out :
        ---------------------------------------------------------------------------
        -- Pump Intake I/F Clock.
        ---------------------------------------------------------------------------
            I_CLK               => I_CLK           , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Intake I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            I_AWID              => open            , -- Out :
            I_AWADDR            => I_AWADDR        , -- Out :
            I_AWLEN(3 downto 0) => I_AWLEN         , -- Out :
            I_AWLEN(7 downto 4) => i_awlen_hi      , -- Out :
            I_AWSIZE            => I_AWSIZE        , -- Out :
            I_AWBURST           => I_AWBURST       , -- Out :
            I_AWLOCK(0)         => I_AWLOCK(0)     , -- Out :
            I_AWCACHE           => I_AWCACHE       , -- Out :
            I_AWPROT            => I_AWPROT        , -- Out :
            I_AWQOS             => I_AWQOS         , -- Out :
            I_AWREGION          => I_AWREGION      , -- Out :
            I_AWUSER            => I_AWUSER        , -- Out :
            I_AWVALID           => I_AWVALID       , -- Out :
            I_AWREADY           => I_AWREADY       , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Intake I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            I_WDATA             => I_WDATA         , -- Out :
            I_WSTRB             => I_WSTRB         , -- Out :
            I_WLAST             => I_WLAST         , -- Out :
            I_WVALID            => I_WVALID        , -- Out :
            I_WREADY            => I_WREADY        , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Intake I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            I_BID               => I_BID           , -- In  :
            I_BRESP             => I_BRESP         , -- In  :
            I_BVALID            => I_BVALID        , -- In  :
            I_BREADY            => I_BREADY        , -- Out :
        ---------------------------------------------------------------------------
        -- Pump Intake I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            I_ARID              => open            , -- Out :
            I_ARADDR            => I_ARADDR        , -- Out :
            I_ARLEN(3 downto 0) => I_ARLEN         , -- Out :
            I_ARLEN(7 downto 4) => i_arlen_hi      , -- Out :
            I_ARSIZE            => I_ARSIZE        , -- Out :
            I_ARBURST           => I_ARBURST       , -- Out :
            I_ARLOCK(0)         => I_ARLOCK(0)     , -- Out :
            I_ARCACHE           => I_ARCACHE       , -- Out :
            I_ARPROT            => I_ARPROT        , -- Out :
            I_ARQOS             => I_ARQOS         , -- Out :
            I_ARREGION          => I_ARREGION      , -- Out :
            I_ARUSER            => I_ARUSER        , -- Out :
            I_ARVALID           => I_ARVALID       , -- Out :
            I_ARREADY           => I_ARREADY       , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Intake I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            I_RID               => I_RID           , -- In  :
            I_RDATA             => I_RDATA         , -- In  :
            I_RRESP             => I_RRESP         , -- In  :
            I_RLAST             => I_RLAST         , -- In  :
            I_RVALID            => I_RVALID        , -- In  :
            I_RREADY            => I_RREADY        , -- Out :
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F Clock.
        ---------------------------------------------------------------------------
            O_CLK               => O_CLK           , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            O_ARID              => open            , -- Out :
            O_ARADDR            => O_ARADDR        , -- Out :
            O_ARLEN(3 downto 0) => O_ARLEN         , -- Out :
            O_ARLEN(7 downto 4) => o_arlen_hi      , -- Out :
            O_ARSIZE            => O_ARSIZE        , -- Out :
            O_ARBURST           => O_ARBURST       , -- Out :
            O_ARLOCK(0)         => O_ARLOCK(0)     , -- Out :
            O_ARCACHE           => O_ARCACHE       , -- Out :
            O_ARPROT            => O_ARPROT        , -- Out :
            O_ARQOS             => O_ARQOS         , -- Out :
            O_ARREGION          => O_ARREGION      , -- Out :
            O_ARUSER            => O_ARUSER        , -- Out :
            O_ARVALID           => O_ARVALID       , -- Out :
            O_ARREADY           => O_ARREADY       , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            O_RID               => O_RID           , -- In  :
            O_RDATA             => O_RDATA         , -- In  :
            O_RRESP             => O_RRESP         , -- In  :
            O_RLAST             => O_RLAST         , -- In  :
            O_RVALID            => O_RVALID        , -- In  :
            O_RREADY            => O_RREADY        , -- Out :
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            O_AWID              => open            , -- Out :
            O_AWADDR            => O_AWADDR        , -- Out :
            O_AWLEN(3 downto 0) => O_AWLEN         , -- Out :
            O_AWLEN(7 downto 4) => o_awlen_hi      , -- Out :
            O_AWSIZE            => O_AWSIZE        , -- Out :
            O_AWBURST           => O_AWBURST       , -- Out :
            O_AWLOCK(0)         => O_AWLOCK(0)     , -- Out :
            O_AWCACHE           => O_AWCACHE       , -- Out :
            O_AWPROT            => O_AWPROT        , -- Out :
            O_AWQOS             => O_AWQOS         , -- Out :
            O_AWREGION          => O_AWREGION      , -- Out :
            O_AWUSER            => O_AWUSER        , -- Out :
            O_AWVALID           => O_AWVALID       , -- Out :
            O_AWREADY           => O_AWREADY       , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
            O_WDATA             => O_WDATA         , -- Out :
            O_WSTRB             => O_WSTRB         , -- Out :
            O_WLAST             => O_WLAST         , -- Out :
            O_WVALID            => O_WVALID        , -- Out :
            O_WREADY            => O_WREADY        , -- In  :
        ---------------------------------------------------------------------------
        -- Pump Outlet I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
            O_BID               => O_BID           , -- In  :
            O_BRESP             => O_BRESP         , -- In  :
            O_BVALID            => O_BVALID        , -- In  :
            O_BREADY            => O_BREADY        , -- Out :
        ---------------------------------------------------------------------------
        -- Interrupt Request Signals.
        ---------------------------------------------------------------------------
            I_IRQ               => I_IRQ           , -- Out :
            O_IRQ               => O_IRQ           , -- Out :
            IRQ                 => IRQ               -- Out :
        );
    M_ARID      <= std_logic_vector(to_unsigned(M_AXI_ID, M_ID_WIDTH));
    M_AWID      <= std_logic_vector(to_unsigned(M_AXI_ID, M_ID_WIDTH));
    M_WID       <= std_logic_vector(to_unsigned(M_AXI_ID, M_ID_WIDTH));
    I_ARID      <= std_logic_vector(to_unsigned(I_AXI_ID, I_ID_WIDTH));
    I_AWID      <= std_logic_vector(to_unsigned(I_AXI_ID, I_ID_WIDTH));
    I_WID       <= std_logic_vector(to_unsigned(I_AXI_ID, I_ID_WIDTH));
    O_ARID      <= std_logic_vector(to_unsigned(O_AXI_ID, O_ID_WIDTH));
    O_AWID      <= std_logic_vector(to_unsigned(O_AXI_ID, O_ID_WIDTH));
    O_WID       <= std_logic_vector(to_unsigned(O_AXI_ID, O_ID_WIDTH));
    M_ARLOCK(1) <= '0';
    M_AWLOCK(1) <= '0';
    I_ARLOCK(1) <= '0';
    I_AWLOCK(1) <= '0';
    O_ARLOCK(1) <= '0';
    O_AWLOCK(1) <= '0';
end RTL;


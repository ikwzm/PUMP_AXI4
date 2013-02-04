-----------------------------------------------------------------------------------
--!     @file    pump_axi4_to_axi4_sg.vhd
--!     @brief   Pump Sample Module (AXI4 to AXI4)
--!     @version 0.0.12
--!     @date    2013/2/3
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012,2013 Ichiro Kawazome
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
library PipeWork;
use     PipeWork.AXI4_TYPES.all;
-----------------------------------------------------------------------------------
--! @brief 
-----------------------------------------------------------------------------------
entity  PUMP_AXI4_TO_AXI4_SG is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        C_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        C_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        C_ID_WIDTH      : integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
        M_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        M_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        M_ID_WIDTH      : integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
        M_AUSER_WIDTH   : integer range 1 to 32                  :=  4;
        M_AXI_ID        : integer                                :=  1;
        I_AXI_ID        : integer                                :=  1;
        I_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        I_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        I_ID_WIDTH      : integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
        I_AUSER_WIDTH   : integer range 1 to 32                  :=  4;
        I_RUSER_WIDTH   : integer range 1 to 32                  :=  4;
        I_MAX_XFER_SIZE : integer                                :=  8;
        O_AXI_ID        : integer                                :=  2;
        O_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        O_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        O_ID_WIDTH      : integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
        O_AUSER_WIDTH   : integer range 1 to 32                  :=  4;
        O_WUSER_WIDTH   : integer range 1 to 32                  :=  4;
        O_BUSER_WIDTH   : integer range 1 to 32                  :=  4;
        O_MAX_XFER_SIZE : integer                                :=  8;
        BUF_DEPTH       : integer                                := 12
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
        C_ARID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_ARADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
        C_ARLEN         : in    AXI4_ALEN_TYPE;
        C_ARSIZE        : in    AXI4_ASIZE_TYPE;
        C_ARBURST       : in    AXI4_ABURST_TYPE;
        C_ARVALID       : in    std_logic;
        C_ARREADY       : out   std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
        C_RID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_RDATA         : out   std_logic_vector(C_DATA_WIDTH  -1 downto 0);
        C_RRESP         : out   AXI4_RESP_TYPE;
        C_RLAST         : out   std_logic;
        C_RVALID        : out   std_logic;
        C_RREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
        C_AWID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_AWADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
        C_AWLEN         : in    AXI4_ALEN_TYPE;
        C_AWSIZE        : in    AXI4_ASIZE_TYPE;
        C_AWBURST       : in    AXI4_ABURST_TYPE;
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
        C_BRESP         : out   AXI4_RESP_TYPE;
        C_BVALID        : out   std_logic;
        C_BREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Transfer Request Block Access I/F AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
        M_ARID          : out   std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_ARADDR        : out   std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
        M_ARLEN         : out   AXI4_ALEN_TYPE;
        M_ARSIZE        : out   AXI4_ASIZE_TYPE;
        M_ARBURST       : out   AXI4_ABURST_TYPE;
        M_ARLOCK        : out   AXI4_ALOCK_TYPE;
        M_ARCACHE       : out   AXI4_ACACHE_TYPE;
        M_ARPROT        : out   AXI4_APROT_TYPE;
        M_ARQOS         : out   AXI4_AQOS_TYPE;
        M_ARREGION      : out   AXI4_AREGION_TYPE;
        M_ARUSER        : out   std_logic_vector(M_AUSER_WIDTH -1 downto 0);
        M_ARVALID       : out   std_logic;
        M_ARREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Transfer Request Block Access I/F AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
        M_RID           : in    std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_RDATA         : in    std_logic_vector(M_DATA_WIDTH  -1 downto 0);
        M_RRESP         : in    AXI4_RESP_TYPE;
        M_RLAST         : in    std_logic;
        M_RVALID        : in    std_logic;
        M_RREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Transfer Request Block Access I/F AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
        M_AWID          : out   std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_AWADDR        : out   std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
        M_AWLEN         : out   AXI4_ALEN_TYPE;
        M_AWSIZE        : out   AXI4_ASIZE_TYPE;
        M_AWBURST       : out   AXI4_ABURST_TYPE;
        M_AWLOCK        : out   AXI4_ALOCK_TYPE;
        M_AWCACHE       : out   AXI4_ACACHE_TYPE;
        M_AWPROT        : out   AXI4_APROT_TYPE;
        M_AWQOS         : out   AXI4_AQOS_TYPE;
        M_AWREGION      : out   AXI4_AREGION_TYPE;
        M_AWUSER        : out   std_logic_vector(M_AUSER_WIDTH -1 downto 0);
        M_AWVALID       : out   std_logic;
        M_AWREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Transfer Request Block Access I/F AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
        M_WDATA         : out   std_logic_vector(M_DATA_WIDTH  -1 downto 0);
        M_WSTRB         : out   std_logic_vector(M_DATA_WIDTH/8-1 downto 0);
        M_WLAST         : out   std_logic;
        M_WVALID        : out   std_logic;
        M_WREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Transfer Request Block Access I/F AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
        M_BID           : in    std_logic_vector(M_ID_WIDTH    -1 downto 0);
        M_BRESP         : in    AXI4_RESP_TYPE;
        M_BVALID        : in    std_logic;
        M_BREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Input AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
        I_ARID          : out   std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_ARADDR        : out   std_logic_vector(I_ADDR_WIDTH  -1 downto 0);
        I_ARLEN         : out   AXI4_ALEN_TYPE;
        I_ARSIZE        : out   AXI4_ASIZE_TYPE;
        I_ARBURST       : out   AXI4_ABURST_TYPE;
        I_ARLOCK        : out   AXI4_ALOCK_TYPE;
        I_ARCACHE       : out   AXI4_ACACHE_TYPE;
        I_ARPROT        : out   AXI4_APROT_TYPE;
        I_ARQOS         : out   AXI4_AQOS_TYPE;
        I_ARREGION      : out   AXI4_AREGION_TYPE;
        I_ARUSER        : out   std_logic_vector(I_AUSER_WIDTH -1 downto 0);
        I_ARVALID       : out   std_logic;
        I_ARREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Input AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
        I_RID           : in    std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_RDATA         : in    std_logic_vector(I_DATA_WIDTH  -1 downto 0);
        I_RRESP         : in    AXI4_RESP_TYPE;
        I_RLAST         : in    std_logic;
        I_RUSER         : in    std_logic_vector(I_RUSER_WIDTH -1 downto 0);
        I_RVALID        : in    std_logic;
        I_RREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- Output AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
        O_AWID          : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_AWADDR        : out   std_logic_vector(O_ADDR_WIDTH  -1 downto 0);
        O_AWLEN         : out   AXI4_ALEN_TYPE;
        O_AWSIZE        : out   AXI4_ASIZE_TYPE;
        O_AWBURST       : out   AXI4_ABURST_TYPE;
        O_AWLOCK        : out   AXI4_ALOCK_TYPE;
        O_AWCACHE       : out   AXI4_ACACHE_TYPE;
        O_AWPROT        : out   AXI4_APROT_TYPE;
        O_AWQOS         : out   AXI4_AQOS_TYPE;
        O_AWREGION      : out   AXI4_AREGION_TYPE;
        O_AWUSER        : out   std_logic_vector(O_AUSER_WIDTH -1 downto 0);
        O_AWVALID       : out   std_logic;
        O_AWREADY       : in    std_logic;
        ---------------------------------------------------------------------------
        -- Output AXI4 Write Data Channel Signals.
        ---------------------------------------------------------------------------
        O_WID           : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_WDATA         : out   std_logic_vector(O_DATA_WIDTH  -1 downto 0);
        O_WSTRB         : out   std_logic_vector(O_DATA_WIDTH/8-1 downto 0);
        O_WUSER         : out   std_logic_vector(O_WUSER_WIDTH -1 downto 0);
        O_WLAST         : out   std_logic;
        O_WVALID        : out   std_logic;
        O_WREADY        : in    std_logic;
        ---------------------------------------------------------------------------
        -- Output AXI4 Write Response Channel Signals.
        ---------------------------------------------------------------------------
        O_BID           : in    std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_BRESP         : in    AXI4_RESP_TYPE;
        O_BUSER         : in    std_logic_vector(O_BUSER_WIDTH -1 downto 0);
        O_BVALID        : in    std_logic;
        O_BREADY        : out   std_logic;
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        I_IRQ           : out   std_logic;
        O_IRQ           : out   std_logic
    );
end PUMP_AXI4_TO_AXI4_SG;
-----------------------------------------------------------------------------------
-- アーキテクチャ本体
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
library PIPEWORK;
use     PIPEWORK.AXI4_TYPES.all;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_READ_INTERFACE;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_MASTER_WRITE_INTERFACE;
use     PIPEWORK.AXI4_COMPONENTS.AXI4_REGISTER_INTERFACE;
use     PIPEWORK.COMPONENTS.QUEUE_ARBITER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROLLER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_SEQUENCER;
architecture RTL of PUMP_AXI4_TO_AXI4_SG is
    -------------------------------------------------------------------------------
    -- リセット信号.
    -------------------------------------------------------------------------------
    signal   RST                : std_logic;
    constant CLR                : std_logic := '0';
    -------------------------------------------------------------------------------
    -- PUMP_AXI4_TO_AXI4_CORE のコンポーネント宣言.
    -------------------------------------------------------------------------------
    component PUMP_AXI4_TO_AXI4_CORE
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        generic (
            I_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
            I_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
            I_ID_WIDTH      : integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
            I_AUSER_WIDTH   : integer range 1 to 32                  :=  4;
            I_RUSER_WIDTH   : integer range 1 to 32                  :=  4;
            I_AXI_ID        : integer                                :=  1;
            I_REG_ADDR_BITS : integer                                := 32;
            I_REG_SIZE_BITS : integer                                := 32;
            I_REG_MODE_BITS : integer                                := 32;
            I_REG_STAT_BITS : integer                                := 32;
            I_MAX_XFER_SIZE : integer                                :=  8;
            I_RES_QUEUE     : integer                                :=  1;
            O_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
            O_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
            O_ID_WIDTH      : integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
            O_AUSER_WIDTH   : integer range 1 to 32                  :=  4;
            O_WUSER_WIDTH   : integer range 1 to 32                  :=  4;
            O_BUSER_WIDTH   : integer range 1 to 32                  :=  4;
            O_AXI_ID        : integer                                :=  2;
            O_REG_ADDR_BITS : integer                                := 32;
            O_REG_SIZE_BITS : integer                                := 32;
            O_REG_MODE_BITS : integer                                := 32;
            O_REG_STAT_BITS : integer                                := 32;
            O_MAX_XFER_SIZE : integer                                :=  1;
            O_RES_QUEUE     : integer                                :=  2;
            BUF_DEPTH       : integer                                := 12
        );
        ---------------------------------------------------------------------------
        -- 入出力ポートの定義.
        ---------------------------------------------------------------------------
        port(
            -----------------------------------------------------------------------
            -- Clock & Reset Signals.
            -----------------------------------------------------------------------
            CLK             : in  std_logic; 
            RST             : in  std_logic;
            CLR             : in  std_logic;
            -----------------------------------------------------------------------
            -- Intake Control Register Interface.
            -----------------------------------------------------------------------
            I_ADDR_L        : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
            I_ADDR_D        : in  std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
            I_ADDR_Q        : out std_logic_vector(I_REG_ADDR_BITS-1 downto 0);
            I_SIZE_L        : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
            I_SIZE_D        : in  std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
            I_SIZE_Q        : out std_logic_vector(I_REG_SIZE_BITS-1 downto 0);
            I_MODE_L        : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
            I_MODE_D        : in  std_logic_vector(I_REG_MODE_BITS-1 downto 0);
            I_MODE_Q        : out std_logic_vector(I_REG_MODE_BITS-1 downto 0);
            I_STAT_L        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
            I_STAT_D        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
            I_STAT_Q        : out std_logic_vector(I_REG_STAT_BITS-1 downto 0);
            I_STAT_I        : in  std_logic_vector(I_REG_STAT_BITS-1 downto 0);
            I_RESET_L       : in  std_logic;
            I_RESET_D       : in  std_logic;
            I_RESET_Q       : out std_logic;
            I_START_L       : in  std_logic;
            I_START_D       : in  std_logic;
            I_START_Q       : out std_logic;
            I_STOP_L        : in  std_logic;
            I_STOP_D        : in  std_logic;
            I_STOP_Q        : out std_logic;
            I_PAUSE_L       : in  std_logic;
            I_PAUSE_D       : in  std_logic;
            I_PAUSE_Q       : out std_logic;
            I_FIRST_L       : in  std_logic;
            I_FIRST_D       : in  std_logic;
            I_FIRST_Q       : out std_logic;
            I_LAST_L        : in  std_logic;
            I_LAST_D        : in  std_logic;
            I_LAST_Q        : out std_logic;
            I_DONE_EN_L     : in  std_logic;
            I_DONE_EN_D     : in  std_logic;
            I_DONE_EN_Q     : out std_logic;
            I_DONE_ST_L     : in  std_logic;
            I_DONE_ST_D     : in  std_logic;
            I_DONE_ST_Q     : out std_logic;
            I_ERR_ST_L      : in  std_logic;
            I_ERR_ST_D      : in  std_logic;
            I_ERR_ST_Q      : out std_logic;
            I_ADDR_FIX      : in  std_logic;
            I_SPECULATIVE   : in  std_logic;
            I_SAFETY        : in  std_logic;
            I_CACHE         : in  AXI4_ACACHE_TYPE ;
            I_LOCK          : in  AXI4_ALOCK_TYPE  ;
            I_PROT          : in  AXI4_APROT_TYPE  ;
            I_QOS           : in  AXI4_AQOS_TYPE   ;
            I_REGION        : in  AXI4_AREGION_TYPE;
            -----------------------------------------------------------------------
            -- Outlet Control Register Interface.
            -----------------------------------------------------------------------
            O_ADDR_L        : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
            O_ADDR_D        : in  std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
            O_ADDR_Q        : out std_logic_vector(O_REG_ADDR_BITS-1 downto 0);
            O_SIZE_L        : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
            O_SIZE_D        : in  std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
            O_SIZE_Q        : out std_logic_vector(O_REG_SIZE_BITS-1 downto 0);
            O_MODE_L        : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
            O_MODE_D        : in  std_logic_vector(O_REG_MODE_BITS-1 downto 0);
            O_MODE_Q        : out std_logic_vector(O_REG_MODE_BITS-1 downto 0);
            O_STAT_L        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
            O_STAT_D        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
            O_STAT_Q        : out std_logic_vector(O_REG_STAT_BITS-1 downto 0);
            O_STAT_I        : in  std_logic_vector(O_REG_STAT_BITS-1 downto 0);
            O_RESET_L       : in  std_logic;
            O_RESET_D       : in  std_logic;
            O_RESET_Q       : out std_logic;
            O_START_L       : in  std_logic;
            O_START_D       : in  std_logic;
            O_START_Q       : out std_logic;
            O_STOP_L        : in  std_logic;
            O_STOP_D        : in  std_logic;
            O_STOP_Q        : out std_logic;
            O_PAUSE_L       : in  std_logic;
            O_PAUSE_D       : in  std_logic;
            O_PAUSE_Q       : out std_logic;
            O_FIRST_L       : in  std_logic;
            O_FIRST_D       : in  std_logic;
            O_FIRST_Q       : out std_logic;
            O_LAST_L        : in  std_logic;
            O_LAST_D        : in  std_logic;
            O_LAST_Q        : out std_logic;
            O_DONE_EN_L     : in  std_logic;
            O_DONE_EN_D     : in  std_logic;
            O_DONE_EN_Q     : out std_logic;
            O_DONE_ST_L     : in  std_logic;
            O_DONE_ST_D     : in  std_logic;
            O_DONE_ST_Q     : out std_logic;
            O_ERR_ST_L      : in  std_logic;
            O_ERR_ST_D      : in  std_logic;
            O_ERR_ST_Q      : out std_logic;
            O_ADDR_FIX      : in  std_logic;
            O_SPECULATIVE   : in  std_logic;
            O_SAFETY        : in  std_logic;
            O_CACHE         : in  AXI4_ACACHE_TYPE ;
            O_LOCK          : in  AXI4_ALOCK_TYPE  ;
            O_PROT          : in  AXI4_APROT_TYPE  ;
            O_QOS           : in  AXI4_AQOS_TYPE   ;
            O_REGION        : in  AXI4_AREGION_TYPE;
            ----------------------------------------------------------------------
            -- Input AXI4 Read Address Channel Signals.
            ----------------------------------------------------------------------
            I_ARID          : out std_logic_vector(I_ID_WIDTH    -1 downto 0);
            I_ARADDR        : out std_logic_vector(I_ADDR_WIDTH  -1 downto 0);
            I_ARLEN         : out AXI4_ALEN_TYPE;
            I_ARSIZE        : out AXI4_ASIZE_TYPE;
            I_ARBURST       : out AXI4_ABURST_TYPE;
            I_ARLOCK        : out AXI4_ALOCK_TYPE;
            I_ARCACHE       : out AXI4_ACACHE_TYPE;
            I_ARPROT        : out AXI4_APROT_TYPE;
            I_ARQOS         : out AXI4_AQOS_TYPE;
            I_ARREGION      : out AXI4_AREGION_TYPE;
            I_ARUSER        : out std_logic_vector(I_AUSER_WIDTH -1 downto 0);
            I_ARVALID       : out std_logic;
            I_ARREADY       : in  std_logic;
            -----------------------------------------------------------------------
            -- Input AXI4 Read Data Channel Signals.
            -----------------------------------------------------------------------
            I_RID           : in  std_logic_vector(I_ID_WIDTH    -1 downto 0);
            I_RDATA         : in  std_logic_vector(I_DATA_WIDTH  -1 downto 0);
            I_RRESP         : in  AXI4_RESP_TYPE;
            I_RLAST         : in  std_logic;
            I_RUSER         : in  std_logic_vector(I_RUSER_WIDTH -1 downto 0);
            I_RVALID        : in  std_logic;
            I_RREADY        : out std_logic;
            -----------------------------------------------------------------------
            -- Output AXI4 Write Address Channel Signals.
            -----------------------------------------------------------------------
            O_AWID          : out std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_AWADDR        : out std_logic_vector(O_ADDR_WIDTH  -1 downto 0);
            O_AWLEN         : out AXI4_ALEN_TYPE;
            O_AWSIZE        : out AXI4_ASIZE_TYPE;
            O_AWBURST       : out AXI4_ABURST_TYPE;
            O_AWLOCK        : out AXI4_ALOCK_TYPE;
            O_AWCACHE       : out AXI4_ACACHE_TYPE;
            O_AWPROT        : out AXI4_APROT_TYPE;
            O_AWQOS         : out AXI4_AQOS_TYPE;
            O_AWREGION      : out AXI4_AREGION_TYPE;
            O_AWUSER        : out std_logic_vector(O_AUSER_WIDTH -1 downto 0);
            O_AWVALID       : out std_logic;
            O_AWREADY       : in  std_logic;
            -----------------------------------------------------------------------
            -- Output AXI4 Write Data Channel Signals.
            -----------------------------------------------------------------------
            O_WID           : out std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_WDATA         : out std_logic_vector(O_DATA_WIDTH  -1 downto 0);
            O_WSTRB         : out std_logic_vector(O_DATA_WIDTH/8-1 downto 0);
            O_WUSER         : out std_logic_vector(O_WUSER_WIDTH -1 downto 0);
            O_WLAST         : out std_logic;
            O_WVALID        : out std_logic;
            O_WREADY        : in  std_logic;
            -----------------------------------------------------------------------
            -- Output AXI4 Write Response Channel Signals.
            -----------------------------------------------------------------------
            O_BID           : in  std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_BRESP         : in  AXI4_RESP_TYPE;
            O_BUSER         : in  std_logic_vector(O_BUSER_WIDTH -1 downto 0);
            O_BVALID        : in  std_logic;
            O_BREADY        : out std_logic;
            -----------------------------------------------------------------------
            -- Intake Status.
            -----------------------------------------------------------------------
            I_OPEN          : out std_logic;
            I_RUNNING       : out std_logic;
            I_DONE          : out std_logic;
            I_ERROR         : out std_logic;
            -----------------------------------------------------------------------
            -- Outlet Status.
            -----------------------------------------------------------------------
            O_OPEN          : out std_logic;
            O_RUNNING       : out std_logic;
            O_DONE          : out std_logic;
            O_ERROR         : out std_logic
        );
    end component;
    -------------------------------------------------------------------------------
    -- アドレスレジスタのビット数.
    -------------------------------------------------------------------------------
    constant M_ADDR_REGS_BITS   : integer := 64;
    -------------------------------------------------------------------------------
    -- レジスタアクセスインターフェースのアドレスのビット数.
    -------------------------------------------------------------------------------
    constant REGS_ADDR_WIDTH    : integer := 5;
    -------------------------------------------------------------------------------
    -- レジスタアクセスインターフェースのデータのビット数.
    -------------------------------------------------------------------------------
    constant REGS_DATA_WIDTH    : integer := 32;
    -------------------------------------------------------------------------------
    -- 全レジスタのビット数.
    -------------------------------------------------------------------------------
    constant REGS_DATA_BITS     : integer := (2**REGS_ADDR_WIDTH)*8;
    -------------------------------------------------------------------------------
    -- 定数
    -------------------------------------------------------------------------------
    constant I_LOCK             : AXI4_ALOCK_TYPE  := (others => '0');
    constant I_PROT             : AXI4_APROT_TYPE  := (others => '0');
    constant I_QOS              : AXI4_AQOS_TYPE   := (others => '0');
    constant I_REGION           : AXI4_AREGION_TYPE:= (others => '0');
    -------------------------------------------------------------------------------
    -- 定数
    -------------------------------------------------------------------------------
    constant O_LOCK             : AXI4_ALOCK_TYPE  := (others => '0');
    constant O_PROT             : AXI4_APROT_TYPE  := (others => '0');
    constant O_QOS              : AXI4_AQOS_TYPE   := (others => '0');
    constant O_REGION           : AXI4_AREGION_TYPE:= (others => '0');
    -------------------------------------------------------------------------------
    -- 定数
    -------------------------------------------------------------------------------
    constant MR_BUF_SIZE        : integer := 4;
    constant MR_BUF_WIDTH       : integer := 5;
    constant MR_SIZE_BITS       : integer := MR_BUF_SIZE+1;
    constant MR_RES_QUEUE       : integer := 1;
    constant MR_MAX_XFER_SIZE   : integer := 4;
    constant MR_ID              : std_logic_vector(M_ID_WIDTH -1 downto 0) := 
                                  std_logic_vector(to_unsigned(M_AXI_ID, M_ID_WIDTH));
    constant MR_XFER_SIZE_SEL   : std_logic_vector(MR_MAX_XFER_SIZE downto MR_MAX_XFER_SIZE) := "1";
    constant MR_SPECULATIVE     : std_logic := '0';
    constant MR_SAFETY          : std_logic := '1';
    constant MR_LOCK            : AXI4_ALOCK_TYPE  := (others => '0');
    constant MR_PROT            : AXI4_APROT_TYPE  := (others => '0');
    constant MR_QOS             : AXI4_AQOS_TYPE   := (others => '0');
    constant MR_REGION          : AXI4_AREGION_TYPE:= (others => '0');
    signal   mr_cache           : AXI4_ACACHE_TYPE;
    constant MR_AUSER           : std_logic_vector(M_AUSER_WIDTH -1 downto 0) := (others => '0');
    signal   mr_req_addr        : std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
    signal   mr_req_size        : std_logic_vector(MR_SIZE_BITS  -1 downto 0);
    signal   mr_req_ptr         : std_logic_vector(MR_BUF_SIZE   -1 downto 0);
    signal   mr_req_first       : std_logic;
    signal   mr_req_last        : std_logic;
    signal   mr_req_valid       : std_logic_vector(1 downto 0);
    signal   mr_req_ready       : std_logic;
    signal   mr_xfer_busy       : std_logic;
    signal   mr_ack_valid       : std_logic_vector(1 downto 0);
    signal   mr_ack_error       : std_logic;
    signal   mr_ack_next        : std_logic;
    signal   mr_ack_last        : std_logic;
    signal   mr_ack_stop        : std_logic;
    signal   mr_ack_none        : std_logic;
    signal   mr_ack_size        : std_logic_vector(MR_SIZE_BITS  -1 downto 0);
    signal   mr_flow_pause      : std_logic;
    signal   mr_flow_stop       : std_logic;
    signal   mr_flow_last       : std_logic;
    signal   mr_flow_size       : std_logic_vector(MR_SIZE_BITS  -1 downto 0);
    signal   mr_push_valid      : std_logic_vector(1 downto 0);
    signal   mr_push_size       : std_logic_vector(MR_SIZE_BITS  -1 downto 0);
    signal   mr_push_last       : std_logic;
    signal   mr_push_error      : std_logic;
    signal   mr_buf_wen         : std_logic_vector(1 downto 0);
    signal   mr_buf_ben         : std_logic_vector(2**(MR_BUF_WIDTH-3) downto 0);
    signal   mr_buf_wdata       : std_logic_vector(2**(MR_BUF_WIDTH  ) downto 0);
    signal   mr_buf_wptr        : std_logic_vector(MR_BUF_SIZE   -1 downto 0);
    signal   mr_buf_wready      : std_logic;
    -------------------------------------------------------------------------------
    -- 定数
    -------------------------------------------------------------------------------
    constant MW_BUF_SIZE        : integer := 4;
    constant MW_BUF_WIDTH       : integer := 5;
    constant MW_SIZE_BITS       : integer := MR_BUF_SIZE+1;
    constant MW_RES_QUEUE       : integer := 1;
    constant MW_MAX_XFER_SIZE   : integer := 4;
    constant MW_ID              : std_logic_vector(M_ID_WIDTH -1 downto 0) := 
                                  std_logic_vector(to_unsigned(M_AXI_ID, M_ID_WIDTH));
    constant MW_SPECULATIVE     : std_logic := '0';
    constant MW_SAFETY          : std_logic := '1';
    constant MW_XFER_SIZE_SEL   : std_logic_vector(MW_MAX_XFER_SIZE downto MW_MAX_XFER_SIZE) := "1";
    constant MW_LOCK            : AXI4_ALOCK_TYPE  := (others => '0');
    constant MW_PROT            : AXI4_APROT_TYPE  := (others => '0');
    constant MW_QOS             : AXI4_AQOS_TYPE   := (others => '0');
    constant MW_REGION          : AXI4_AREGION_TYPE:= (others => '0');
    constant MW_CACHE           : AXI4_ACACHE_TYPE := (others => '0');
    constant MW_AUSER           : std_logic_vector(M_AUSER_WIDTH -1 downto 0) := (others => '0');
    constant mw_req_addr        : std_logic_vector(M_ADDR_WIDTH  -1 downto 0) := (others => '0');
    constant mw_req_size        : std_logic_vector(MW_SIZE_BITS  -1 downto 0) := (others => '0');
    constant mw_req_ptr         : std_logic_vector(MW_BUF_SIZE   -1 downto 0) := (others => '0');
    constant mw_req_first       : std_logic := '0';
    constant mw_req_last        : std_logic := '0';
    constant mw_req_valid       : std_logic_vector(1 downto 0) := (others => '0');
    signal   mw_req_ready       : std_logic;
    signal   mw_xfer_busy       : std_logic;
    signal   mw_ack_valid       : std_logic_vector(1 downto 0);
    signal   mw_ack_error       : std_logic;
    signal   mw_ack_next        : std_logic;
    signal   mw_ack_last        : std_logic;
    signal   mw_ack_stop        : std_logic;
    signal   mw_ack_none        : std_logic;
    signal   mw_ack_size        : std_logic_vector(MW_SIZE_BITS  -1 downto 0);
    constant mw_flow_pause      : std_logic := '0';
    constant mw_flow_stop       : std_logic := '0';
    constant mw_flow_last       : std_logic := '0';
    constant mw_flow_size       : std_logic_vector(MW_SIZE_BITS  -1 downto 0) := (others => '0');
    signal   mw_pull_valid      : std_logic_vector(1 downto 0);
    signal   mw_pull_size       : std_logic_vector(MW_SIZE_BITS  -1 downto 0);
    signal   mw_pull_last       : std_logic;
    signal   mw_pull_error      : std_logic;
    constant mw_buf_rdata       : std_logic_vector(2**(MW_BUF_WIDTH  ) downto 0) := (others => '0');
    signal   mw_buf_rptr        : std_logic_vector(MW_BUF_SIZE   -1 downto 0);
    constant mw_buf_rready      : std_logic := '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   im_req_addr        : std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
    signal   im_req_size        : std_logic_vector(MR_SIZE_BITS  -1 downto 0);
    signal   im_req_ptr         : std_logic_vector(MR_BUF_SIZE   -1 downto 0);
    signal   im_req_first       : std_logic;
    signal   im_req_last        : std_logic;
    signal   im_req_valid       : std_logic;
    signal   im_ack_valid       : std_logic;
    signal   im_buf_wen         : std_logic;
    signal   im_buf_wrdy        : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   om_req_addr        : std_logic_vector(M_ADDR_WIDTH  -1 downto 0);
    signal   om_req_size        : std_logic_vector(MR_SIZE_BITS  -1 downto 0);
    signal   om_req_ptr         : std_logic_vector(MR_BUF_SIZE   -1 downto 0);
    signal   om_req_first       : std_logic;
    signal   om_req_last        : std_logic;
    signal   om_req_valid       : std_logic;
    signal   om_ack_valid       : std_logic;
    signal   om_buf_wen         : std_logic;
    signal   om_buf_wrdy        : std_logic;
    -------------------------------------------------------------------------------
    -- レジスタアクセス用の信号群.
    -------------------------------------------------------------------------------
    signal   regs_req           : std_logic;
    signal   regs_write         : std_logic;
    signal   regs_ack           : std_logic;
    constant regs_err           : std_logic := '0';
    signal   regs_addr          : std_logic_vector(REGS_ADDR_WIDTH  -1 downto 0);
    signal   regs_ben           : std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
    signal   regs_wdata         : std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
    signal   regs_rdata         : std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
    signal   regs_load          : std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal   regs_wbit          : std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal   regs_rbit          : std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal   im_stat_i          : std_logic_vector(5 downto 0);
    signal   im_enter           : std_logic;
    signal   im_done            : std_logic;
    signal   im_error           : std_logic_vector(2 downto 0);
    signal   om_stat_i          : std_logic_vector(5 downto 0);
    signal   om_enter           : std_logic;
    signal   om_done            : std_logic;
    signal   om_error           : std_logic_vector(2 downto 0);
    -------------------------------------------------------------------------------
    -- レジスタのアドレスマップ.
    -------------------------------------------------------------------------------
    -- Outlet Transfer Request Block Address Register
    -------------------------------------------------------------------------------
    constant OM_ADDR_REGS_ADDR  : integer := 16#00#;
    constant OM_ADDR_REGS_LO    : integer := 8*OM_ADDR_REGS_ADDR;
    constant OM_ADDR_REGS_HI    : integer := 8*OM_ADDR_REGS_ADDR + M_ADDR_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Outlet Transfer Request Block Mode Register
    -------------------------------------------------------------------------------
    constant OM_MODE_REGS_ADDR  : integer := 16#08#;
    constant OM_MODE_REGS_LO    : integer := 8*OM_MODE_REGS_ADDR +  0;
    constant OM_MODE_REGS_HI    : integer := 8*OM_MODE_REGS_ADDR + 47;
    constant OM_MODE_CACHE_LO   : integer := 8*OM_MODE_REGS_ADDR + 40;
    constant OM_MODE_CACHE_HI   : integer := 8*OM_MODE_REGS_ADDR + 43;
    -------------------------------------------------------------------------------
    -- Outlet Transfer Request Block Status Register
    -------------------------------------------------------------------------------
    constant OM_STAT_REGS_ADDR  : integer := 16#0E#;
    constant OM_STAT_REGS_LO    : integer := 8*OM_STAT_REGS_ADDR +  0;
    constant OM_STAT_REGS_HI    : integer := 8*OM_STAT_REGS_ADDR +  7;
    -------------------------------------------------------------------------------
    -- Outlet Transfer Request Block Control Register
    -------------------------------------------------------------------------------
    constant OM_CTRL_REGS_ADDR  : integer := 16#0F#;
    constant OM_CTRL_START_POS  : integer := 8*OM_CTRL_REGS_ADDR +  4;
    constant OM_CTRL_STOP_POS   : integer := 8*OM_CTRL_REGS_ADDR +  5;
    constant OM_CTRL_PAUSE_POS  : integer := 8*OM_CTRL_REGS_ADDR +  6;
    constant OM_CTRL_RESET_POS  : integer := 8*OM_CTRL_REGS_ADDR +  7;
    -------------------------------------------------------------------------------
    -- Intake Transfer Request Block Address Register
    -------------------------------------------------------------------------------
    constant IM_ADDR_REGS_ADDR  : integer := 16#10#;
    constant IM_ADDR_REGS_LO    : integer := 8*IM_ADDR_REGS_ADDR;
    constant IM_ADDR_REGS_HI    : integer := 8*IM_ADDR_REGS_ADDR + M_ADDR_REGS_BITS-1;
    -------------------------------------------------------------------------------
    -- Intake Transfer Request Block Mode Register
    -------------------------------------------------------------------------------
    constant IM_MODE_REGS_ADDR  : integer := 16#08#;
    constant IM_MODE_REGS_LO    : integer := 8*IM_MODE_REGS_ADDR +  0;
    constant IM_MODE_REGS_HI    : integer := 8*IM_MODE_REGS_ADDR + 47;
    constant IM_MODE_CACHE_LO   : integer := 8*IM_MODE_REGS_ADDR + 40;
    constant IM_MODE_CACHE_HI   : integer := 8*IM_MODE_REGS_ADDR + 43;
    -------------------------------------------------------------------------------
    -- Intake Transfer Request Block Status Register
    -------------------------------------------------------------------------------
    constant IM_STAT_REGS_ADDR  : integer := 16#1E#;
    constant IM_STAT_REGS_LO    : integer := 8*IM_STAT_REGS_ADDR +  0;
    constant IM_STAT_REGS_HI    : integer := 8*IM_STAT_REGS_ADDR +  7;
    -------------------------------------------------------------------------------
    -- Intake Transfer Request Block Control Register
    -------------------------------------------------------------------------------
    constant IM_CTRL_REGS_ADDR  : integer := 16#1F#;
    constant IM_CTRL_START_POS  : integer := 8*IM_CTRL_REGS_ADDR +  4;
    constant IM_CTRL_STOP_POS   : integer := 8*IM_CTRL_REGS_ADDR +  5;
    constant IM_CTRL_PAUSE_POS  : integer := 8*IM_CTRL_REGS_ADDR +  6;
    constant IM_CTRL_RESET_POS  : integer := 8*IM_CTRL_REGS_ADDR +  7;
    -------------------------------------------------------------------------------
    -- TRB(Transfer Request Block)のフォーマット
    -------------------------------------------------------------------------------
    constant TRB_BITS           : integer := 128;
    constant TRB_PUMP_BITS      : integer := 124;
    constant TRB_PUMP_LO        : integer :=   0;
    constant TRB_PUMP_HI        : integer := TRB_PUMP_LO + TRB_PUMP_BITS-1;
    constant TRB_ADDR_BITS      : integer :=  64;
    constant TRB_SIZE_BITS      : integer :=  32;
    constant TRB_MODE_BITS      : integer :=  16;
    constant TRB_STAT_BITS      : integer :=   6;
    constant TRB_ADDR_LO        : integer :=   0;
    constant TRB_ADDR_HI        : integer := TRB_ADDR_LO + TRB_ADDR_BITS - 1;
    constant TRB_SIZE_LO        : integer :=  64;
    constant TRB_SIZE_HI        : integer := TRB_SIZE_LO + TRB_SIZE_BITS - 1;
    constant TRB_MODE_LO        : integer :=  96;
    constant TRB_MODE_HI        : integer := TRB_MODE_LO + TRB_MODE_BITS - 1;
    constant TRB_DONE_ST_POS    : integer := 112;
    constant TRB_ERR_ST_POS     : integer := 113;
    constant TRB_STAT_LO        : integer := 114;
    constant TRB_STAT_HI        : integer := TRB_STAT_LO + TRB_STAT_BITS - 1;
    constant TRB_LAST_POS       : integer := 120;
    constant TRB_FIRST_POS      : integer := 121;
    constant TRB_DONE_EN_POS    : integer := 122;
    constant TRB_RESV_POS       : integer := 123;
    constant TRB_CACHE_LO       : integer := TRB_MODE_LO +  8;
    constant TRB_CACHE_HI       : integer := TRB_MODE_LO + 11;
    constant TRB_ADDR_FIX_POS   : integer := TRB_MODE_LO + 13;
    constant TRB_SPECUL_POS     : integer := TRB_MODE_LO + 14;
    constant TRB_SAFETY_POS     : integer := TRB_MODE_LO + 15;
    -------------------------------------------------------------------------------
    -- Outlet Transfer Request Block
    -------------------------------------------------------------------------------
    signal   op_trb_load        : std_logic_vector(TRB_PUMP_BITS-1 downto 0);
    signal   op_trb_wbit        : std_logic_vector(TRB_PUMP_BITS-1 downto 0);
    signal   op_trb_rbit        : std_logic_vector(TRB_PUMP_BITS-1 downto 0);
    signal   op_reset_load      : std_logic;
    signal   op_reset_wbit      : std_logic;
    signal   op_reset_rbit      : std_logic;
    signal   op_start_load      : std_logic;
    signal   op_start_wbit      : std_logic;
    signal   op_start_rbit      : std_logic;
    signal   op_stop_load       : std_logic;
    signal   op_stop_wbit       : std_logic;
    signal   op_stop_rbit       : std_logic;
    signal   op_pause_load      : std_logic;
    signal   op_pause_wbit      : std_logic;
    signal   op_pause_rbit      : std_logic;
    signal   op_open            : std_logic;
    signal   op_run             : std_logic;
    signal   op_done            : std_logic;
    signal   op_error           : std_logic;
    signal   op_stat_in         : std_logic_vector(TRB_STAT_BITS-1 downto 0);
    -------------------------------------------------------------------------------
    -- Intake Transfer Request Block
    -------------------------------------------------------------------------------
    signal   ip_trb_load        : std_logic_vector(TRB_PUMP_BITS-1 downto 0);
    signal   ip_trb_wbit        : std_logic_vector(TRB_PUMP_BITS-1 downto 0);
    signal   ip_trb_rbit        : std_logic_vector(TRB_PUMP_BITS-1 downto 0);
    signal   ip_reset_load      : std_logic;
    signal   ip_reset_wbit      : std_logic;
    signal   ip_reset_rbit      : std_logic;
    signal   ip_start_load      : std_logic;
    signal   ip_start_wbit      : std_logic;
    signal   ip_start_rbit      : std_logic;
    signal   ip_stop_load       : std_logic;
    signal   ip_stop_wbit       : std_logic;
    signal   ip_stop_rbit       : std_logic;
    signal   ip_pause_load      : std_logic;
    signal   ip_pause_wbit      : std_logic;
    signal   ip_pause_rbit      : std_logic;
    signal   ip_open            : std_logic;
    signal   ip_run             : std_logic;
    signal   ip_done            : std_logic;
    signal   ip_error           : std_logic;
    signal   ip_stat_in         : std_logic_vector(TRB_STAT_BITS-1 downto 0);
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    RST <= '1' when (ARESETn = '0') else '0';
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    C_IF: AXI4_REGISTER_INTERFACE
        generic map (
            AXI4_ADDR_WIDTH => C_ADDR_WIDTH,
            AXI4_DATA_WIDTH => C_DATA_WIDTH,
            AXI4_ID_WIDTH   => C_ID_WIDTH,
            REGS_ADDR_WIDTH => REGS_ADDR_WIDTH,
            REGS_DATA_WIDTH => REGS_DATA_WIDTH
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock and Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
        ---------------------------------------------------------------------------
        -- AXI4 Read Address Channel Signals.
        ---------------------------------------------------------------------------
            ARID            => C_ARID          ,
            ARADDR          => C_ARADDR        , -- In  :
            ARLEN           => C_ARLEN         , -- In  :
            ARSIZE          => C_ARSIZE        , -- In  :
            ARBURST         => C_ARBURST       , -- In  :
            ARVALID         => C_ARVALID       , -- In  :
            ARREADY         => C_ARREADY       , -- Out :
        ---------------------------------------------------------------------------
        -- AXI4 Read Data Channel Signals.
        ---------------------------------------------------------------------------
            RID             => C_RID           , -- Out :
            RDATA           => C_RDATA         , -- Out :
            RRESP           => C_RRESP         , -- Out :
            RLAST           => C_RLAST         , -- Out :
            RVALID          => C_RVALID        , -- Out :
            RREADY          => C_RREADY        , -- In  :
        ---------------------------------------------------------------------------
        -- AXI4 Write Address Channel Signals.
        ---------------------------------------------------------------------------
            AWID            => C_AWID          , -- In  :
            AWADDR          => C_AWADDR        , -- In  :
            AWLEN           => C_AWLEN         , -- In  :
            AWSIZE          => C_AWSIZE        , -- In  :
            AWBURST         => C_AWBURST       , -- In  :
            AWVALID         => C_AWVALID       , -- In  :
            AWREADY         => C_AWREADY       , -- Out :
        --------------------------------------------------------------------------
        -- AXI4 Write Data Channel Signals.
        --------------------------------------------------------------------------
            WDATA           => C_WDATA         , -- In  :
            WSTRB           => C_WSTRB         , -- In  :
            WLAST           => C_WLAST         , -- In  :
            WVALID          => C_WVALID        , -- In  :
            WREADY          => C_WREADY        , -- Out :
        --------------------------------------------------------------------------
        -- AXI4 Write Response Channel Signals.
        --------------------------------------------------------------------------
            BID             => C_BID           , -- Out :
            BRESP           => C_BRESP         , -- Out :
            BVALID          => C_BVALID        , -- Out :
            BREADY          => C_BREADY        , -- In  :
        --------------------------------------------------------------------------
        -- Register Interface.
        --------------------------------------------------------------------------
            REGS_REQ        => regs_req        , -- Out :
            REGS_WRITE      => regs_write      , -- Out :
            REGS_ACK        => regs_ack        , -- In  :
            REGS_ERR        => regs_err        , -- In  :
            REGS_ADDR       => regs_addr       , -- Out :
            REGS_BEN        => regs_ben        , -- Out :
            REGS_WDATA      => regs_wdata      , -- Out :
            REGS_RDATA      => regs_rdata        -- In  :
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    regs_ack <= regs_req;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    process (regs_wdata) begin
        for i in 0 to REGS_DATA_BITS/REGS_DATA_WIDTH-1 loop
            regs_wbit(REGS_DATA_WIDTH*(i+1)-1 downto REGS_DATA_WIDTH*i) <= regs_wdata;
        end loop;
    end process;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    process (regs_addr, regs_req, regs_write, regs_ben)
        variable addr      : unsigned(REGS_ADDR_WIDTH-1 downto 0);
        constant ben_bit_0 : std_logic_vector(REGS_DATA_WIDTH-1 downto 0) := (others => '0');
        variable ben_bit   : std_logic_vector(REGS_DATA_WIDTH-1 downto 0);
    begin
        addr := to_01(unsigned(regs_addr));
        for i in 0 to REGS_DATA_WIDTH/8-1 loop
            if (regs_ben(i) = '1') then
                ben_bit(8*(i+1)-1 downto 8*i) := (8*(i+1)-1 downto 8*i => '1');
            else
                ben_bit(8*(i+1)-1 downto 8*i) := (8*(i+1)-1 downto 8*i => '0');
            end if;
        end loop;
        for i in 0 to REGS_DATA_BITS/REGS_DATA_WIDTH-1 loop
            if (regs_req = '1' and regs_write = '1' and i = addr/(REGS_DATA_WIDTH/8)) then
                regs_load(REGS_DATA_WIDTH*(i+1)-1 downto REGS_DATA_WIDTH*i) <= ben_bit;
            else
                regs_load(REGS_DATA_WIDTH*(i+1)-1 downto REGS_DATA_WIDTH*i) <= ben_bit_0;
            end if;
        end loop;
    end process;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    process (regs_rbit, regs_addr)
        variable addr      : unsigned(REGS_ADDR_WIDTH-1 downto 0);
        variable data      : std_logic_vector(REGS_DATA_WIDTH-1 downto 0);
    begin
        addr := to_01(unsigned(regs_addr));
        data := (others => '0');
        for i in 0 to REGS_DATA_BITS/REGS_DATA_WIDTH-1 loop
            if (i = addr/(REGS_DATA_WIDTH/8)) then
                data := data or regs_rbit(REGS_DATA_WIDTH*(i+1)-1 downto REGS_DATA_WIDTH*i);
            end if;
        end loop;
        regs_rdata <= data;
    end process;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    MR_IF: AXI4_MASTER_READ_INTERFACE
        generic map (
            AXI4_ADDR_WIDTH => M_ADDR_WIDTH    ,
            AXI4_DATA_WIDTH => M_DATA_WIDTH    ,
            AXI4_ID_WIDTH   => M_ID_WIDTH      ,
            VAL_BITS        => 2               ,
            SIZE_BITS       => MR_SIZE_BITS    ,
            REQ_SIZE_BITS   => MR_SIZE_BITS    ,
            REQ_SIZE_VALID  => 1               ,
            FLOW_VALID      => 0               ,
            BUF_DATA_WIDTH  => MR_BUF_WIDTH    ,
            BUF_PTR_BITS    => MR_BUF_SIZE     ,
            XFER_MIN_SIZE   => MR_MAX_XFER_SIZE,
            XFER_MAX_SIZE   => MR_MAX_XFER_SIZE,
            QUEUE_SIZE      => MR_RES_QUEUE
        )
        port map (
        --------------------------------------------------------------------------
        -- Clock and Reset Signals.
        --------------------------------------------------------------------------
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
        --------------------------------------------------------------------------
        -- AXI4 Read Address Channel Signals.
        --------------------------------------------------------------------------
            ARID            => M_ARID          , -- Out :
            ARADDR          => M_ARADDR        , -- Out :
            ARLEN           => M_ARLEN         , -- Out :
            ARSIZE          => M_ARSIZE        , -- Out :
            ARBURST         => M_ARBURST       , -- Out :
            ARLOCK          => M_ARLOCK        , -- Out :
            ARCACHE         => M_ARCACHE       , -- Out :
            ARPROT          => M_ARPROT        , -- Out :
            ARQOS           => M_ARQOS         , -- Out :
            ARREGION        => M_ARREGION      , -- Out :
            ARVALID         => M_ARVALID       , -- Out :
            ARREADY         => M_ARREADY       , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Read Data Channel Signals.
        --------------------------------------------------------------------------
            RID             => M_RID           , -- In  :
            RDATA           => M_RDATA         , -- In  :
            RRESP           => M_RRESP         , -- In  :
            RLAST           => M_RLAST         , -- In  :
            RVALID          => M_RVALID        , -- In  :
            RREADY          => M_RREADY        , -- Out :
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
            REQ_ADDR        => mr_req_addr     , -- In  :
            REQ_SIZE        => mr_req_size     , -- In  :
            REQ_ID          => MR_ID           , -- In  :
            REQ_BURST       => AXI4_ABURST_INCR, -- In  :
            REQ_LOCK        => MR_LOCK         , -- In  :
            REQ_CACHE       => mr_cache        , -- In  :
            REQ_PROT        => MR_PROT         , -- In  :
            REQ_QOS         => MR_QOS          , -- In  :
            REQ_REGION      => MR_REGION       , -- In  :
            REQ_BUF_PTR     => mr_req_ptr      , -- In  :
            REQ_FIRST       => mr_req_first    , -- In  :
            REQ_LAST        => mr_req_last     , -- In  :
            REQ_SPECULATIVE => MR_SPECULATIVE  , -- In  :
            REQ_SAFETY      => MR_SAFETY       , -- In  :
            REQ_VAL         => mr_req_valid    , -- In  :
            REQ_RDY         => mr_req_ready    , -- Out :
            XFER_SIZE_SEL   => MR_XFER_SIZE_SEL, -- In  :
            XFER_BUSY       => mr_xfer_busy    , -- Out :
        ---------------------------------------------------------------------------
        -- Response Signals.
        ---------------------------------------------------------------------------
            ACK_VAL         => mr_ack_valid    , -- Out :
            ACK_ERROR       => mr_ack_error    , -- Out :
            ACK_NEXT        => mr_ack_next     , -- Out :
            ACK_LAST        => mr_ack_last     , -- Out :
            ACK_STOP        => mr_ack_stop     , -- Out :
            ACK_NONE        => mr_ack_none     , -- Out :
            ACK_SIZE        => mr_ack_size     , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_PAUSE      => mr_flow_pause   , -- In  :
            FLOW_STOP       => mr_flow_stop    , -- In  :
            FLOW_LAST       => mr_flow_last    , -- In  :
            FLOW_SIZE       => mr_flow_size    , -- In  :
        ---------------------------------------------------------------------------
        -- Reserve Size Signals.
        ---------------------------------------------------------------------------
            RESV_VAL        => open            , -- Out :
            RESV_SIZE       => open            , -- Out :
            RESV_LAST       => open            , -- Out :
            RESV_ERROR      => open            , -- Out :
        ---------------------------------------------------------------------------
        -- Push Size Signals.
        ---------------------------------------------------------------------------
            PUSH_VAL        => mr_push_valid   , -- Out :
            PUSH_SIZE       => mr_push_size    , -- Out :
            PUSH_LAST       => mr_push_last    , -- Out :
            PUSH_ERROR      => mr_push_error   , -- Out :
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_WEN         => mr_buf_wen      , -- Out :
            BUF_BEN         => mr_buf_ben      , -- Out :
            BUF_DATA        => mr_buf_wdata    , -- Out :
            BUF_PTR         => mr_buf_wptr     , -- Out :
            BUF_RDY         => mr_buf_wready     -- In  :
        );
    M_ARUSER <= MR_AUSER;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    MW_IF: AXI4_MASTER_WRITE_INTERFACE
        generic map (
            AXI4_ADDR_WIDTH => M_ADDR_WIDTH    ,
            AXI4_DATA_WIDTH => M_DATA_WIDTH    ,
            AXI4_ID_WIDTH   => M_ID_WIDTH      ,
            VAL_BITS        => 2               ,
            SIZE_BITS       => MW_SIZE_BITS    ,
            REQ_SIZE_BITS   => MW_SIZE_BITS    ,
            REQ_SIZE_VALID  => 1               ,
            FLOW_VALID      => 0               ,
            BUF_DATA_WIDTH  => MW_BUF_WIDTH    ,
            BUF_PTR_BITS    => MW_BUF_SIZE     ,
            XFER_MIN_SIZE   => MW_MAX_XFER_SIZE,
            XFER_MAX_SIZE   => MW_MAX_XFER_SIZE,
            QUEUE_SIZE      => MW_RES_QUEUE
        )
        port map (
        --------------------------------------------------------------------------
        -- Clock and Reset Signals.
        --------------------------------------------------------------------------
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
        --------------------------------------------------------------------------
        -- AXI4 Write Address Channel Signals.
        --------------------------------------------------------------------------
            AWID            => M_AWID          , -- Out :
            AWADDR          => M_AWADDR        , -- Out :
            AWLEN           => M_AWLEN         , -- Out :
            AWSIZE          => M_AWSIZE        , -- Out :
            AWBURST         => M_AWBURST       , -- Out :
            AWLOCK          => M_AWLOCK        , -- Out :
            AWCACHE         => M_AWCACHE       , -- Out :
            AWPROT          => M_AWPROT        , -- Out :
            AWQOS           => M_AWQOS         , -- Out :
            AWREGION        => M_AWREGION      , -- Out :
            AWVALID         => M_AWVALID       , -- Out :
            AWREADY         => M_AWREADY       , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Write Data Channel Signals.
        --------------------------------------------------------------------------
            WID             => open            , -- Out :
            WDATA           => M_WDATA         , -- Out :
            WSTRB           => M_WSTRB         , -- Out :
            WLAST           => M_WLAST         , -- Out :
            WVALID          => M_WVALID        , -- Out :
            WREADY          => M_WREADY        , -- In  :
        --------------------------------------------------------------------------
        -- AXI4 Write Response Channel Signals.
        --------------------------------------------------------------------------
            BID             => M_BID           , -- In  :
            BRESP           => M_BRESP         , -- In  :
            BVALID          => M_BVALID        , -- In  :
            BREADY          => M_BREADY        , -- Out :
        ---------------------------------------------------------------------------
        -- Command Request Signals.
        ---------------------------------------------------------------------------
            REQ_ADDR        => mw_req_addr     , -- In  :
            REQ_SIZE        => mw_req_size     , -- In  :
            REQ_ID          => MW_ID           , -- In  :
            REQ_BURST       => AXI4_ABURST_INCR, -- In  :
            REQ_LOCK        => MW_LOCK         , -- In  :
            REQ_CACHE       => MW_CACHE        , -- In  :
            REQ_PROT        => MW_PROT         , -- In  :
            REQ_QOS         => MW_QOS          , -- In  :
            REQ_REGION      => MW_REGION       , -- In  :
            REQ_BUF_PTR     => mw_req_ptr      , -- In  :
            REQ_FIRST       => mw_req_first    , -- In  :
            REQ_LAST        => mw_req_last     , -- In  :
            REQ_SPECULATIVE => MW_SPECULATIVE  , -- In  :
            REQ_SAFETY      => MW_SAFETY       , -- In  :
            REQ_VAL         => mw_req_valid    , -- In  :
            REQ_RDY         => mw_req_ready    , -- Out :
            XFER_SIZE_SEL   => MW_XFER_SIZE_SEL, -- In  :
            XFER_BUSY       => mw_xfer_busy    , -- Out :
        ---------------------------------------------------------------------------
        -- Response Signals.
        ---------------------------------------------------------------------------
            ACK_VAL         => mw_ack_valid    , -- Out :
            ACK_ERROR       => mw_ack_error    , -- Out :
            ACK_NEXT        => mw_ack_next     , -- Out :
            ACK_LAST        => mw_ack_last     , -- Out :
            ACK_STOP        => mw_ack_stop     , -- Out :
            ACK_NONE        => mw_ack_none     , -- Out :
            ACK_SIZE        => mw_ack_size     , -- Out :
        ---------------------------------------------------------------------------
        -- Flow Control Signals.
        ---------------------------------------------------------------------------
            FLOW_PAUSE      => mw_flow_pause   , -- In  :
            FLOW_STOP       => mw_flow_stop    , -- In  :
            FLOW_LAST       => mw_flow_last    , -- In  :
            FLOW_SIZE       => mw_flow_size    , -- In  :
        ---------------------------------------------------------------------------
        -- Reserve Size Signals.
        ---------------------------------------------------------------------------
            RESV_VAL        => open            , -- Out :
            RESV_SIZE       => open            , -- Out :
            RESV_LAST       => open            , -- Out :
            RESV_ERROR      => open            , -- Out :
        ---------------------------------------------------------------------------
        -- Pull Size Signals.
        ---------------------------------------------------------------------------
            PULL_VAL        => mw_pull_valid   , -- Out :
            PULL_SIZE       => mw_pull_size    , -- Out :
            PULL_LAST       => mw_pull_last    , -- Out :
            PULL_ERROR      => mw_pull_error   , -- Out :
        ---------------------------------------------------------------------------
        -- Read Buffer Interface Signals.
        ---------------------------------------------------------------------------
            BUF_REN         => open            , -- Out :
            BUF_DATA        => mw_buf_rdata    , -- In  :
            BUF_PTR         => mw_buf_rptr     , -- Out :
            BUF_RDY         => mw_buf_rready
        );
    M_AWUSER <= MW_AUSER;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    M_ARB : block
        constant ENABLE  : std_logic := '1';
        signal   num     : integer range 0 to 1;
        signal   request : std_logic_vector(0 to 1);
        signal   grant   : std_logic_vector(0 to 1);
        signal   valid   : std_logic;
        signal   shift   : std_logic;
    begin
        QUEUE: QUEUE_ARBITER 
            generic map (
                MIN_NUM     => 0,
                MAX_NUM     => 1
            )
            port map (
                CLK         => ACLK           ,  -- In  :
                RST         => RST            ,  -- In  :
                CLR         => CLR            ,  -- In  :
                ENABLE      => ENABLE         ,  -- In  :
                REQUEST     => request        ,  -- In  :
                GRANT       => grant          ,  -- Out :
                GRANT_NUM   => num            ,  -- Out :
                REQUEST_O   => open           ,  -- Out :
                VALID       => valid          ,  -- Out :
                SHIFT       => shift             -- In  :
            );
        request(0)      <= om_req_valid;
        mr_req_valid(0) <= grant(0) and om_req_valid;
        om_ack_valid    <= mr_ack_valid(0);
        om_buf_wen      <= mr_buf_wen(0);
        request(1)      <= im_req_valid;
        mr_req_valid(1) <= grant(1) and im_req_valid;
        im_ack_valid    <= mr_ack_valid(1);
        im_buf_wen      <= mr_buf_wen(1);
        mr_req_addr     <= im_req_addr  when (num = 1) else om_req_addr;
        mr_req_size     <= im_req_size  when (num = 1) else om_req_size;
        mr_req_ptr      <= im_req_ptr   when (num = 1) else om_req_ptr;
        mr_req_first    <= im_req_first when (num = 1) else om_req_first;
        mr_req_last     <= im_req_first when (num = 1) else om_req_last;
        mr_buf_wready   <= im_buf_wrdy  when (num = 1) else om_buf_wrdy;
        mr_cache        <= regs_rbit(IM_MODE_CACHE_HI downto IM_MODE_CACHE_LO) when (num = 1) else
                           regs_rbit(OM_MODE_CACHE_HI downto OM_MODE_CACHE_LO);
    end block;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    OM: PUMP_SEQUENCER
        generic map (
            M_ADDR_BITS     => M_ADDR_WIDTH    , -- 
            M_BUF_SIZE      => MR_BUF_SIZE     , -- 
            M_BUF_WIDTH     => MR_BUF_WIDTH    , -- 
            TRB_BITS        => TRB_BITS        , -- 
            TRB_PUMP_LO     => TRB_PUMP_LO     , -- 
            TRB_PUMP_HI     => TRB_PUMP_HI     , -- 
            TRB_ADDR_LO     => 0               , -- 
            TRB_ADDR_HI     => 63              , -- 
            TRB_MODE_LO     => 64              , -- 
            TRB_MODE_HI     => 64+47           , -- 
            TRB_STAT_LO     => 64+48           , -- 
            TRB_STAT_HI     => 64+48+7           -- 
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock & Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => ACLK            , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        -------------------------------------------------------------------------------
        -- Transfer Request Block Read Signals.
        -------------------------------------------------------------------------------
            M_REQ_VALID     => om_req_valid    , -- Out :
            M_REQ_ADDR      => om_req_addr     , -- Out :
            M_REQ_SIZE      => om_req_size     , -- Out :
            M_REQ_PTR       => om_req_ptr      , -- Out :
            M_REQ_FIRST     => om_req_first    , -- Out :
            M_REQ_LAST      => om_req_last     , -- Out :
            M_REQ_READY     => mr_req_ready    , -- In  :
            M_ACK_VALID     => om_ack_valid    , -- In  :
            M_ACK_ERROR     => mr_ack_error    , -- In  :
            M_ACK_NEXT      => mr_ack_next     , -- In  :
            M_ACK_LAST      => mr_ack_last     , -- In  :
            M_ACK_STOP      => mr_ack_stop     , -- In  :
            M_ACK_NONE      => mr_ack_none     , -- In  :
            M_ACK_SIZE      => mr_ack_size     , -- In  :
            M_BUF_WE        => om_buf_wen      , -- In  :
            M_BUF_BEN       => mr_buf_ben      , -- In  :
            M_BUF_DATA      => mr_buf_wdata    , -- In  :
            M_BUF_PTR       => mr_buf_wptr     , -- In  :
            M_BUF_RDY       => om_buf_wrdy     , -- Out :
        -------------------------------------------------------------------------------
        -- Control Status Register Interface Signals.
        -------------------------------------------------------------------------------
            T_ADDR_L        => regs_load(OM_ADDR_REGS_HI downto OM_ADDR_REGS_LO),
            T_ADDR_D        => regs_wbit(OM_ADDR_REGS_HI downto OM_ADDR_REGS_LO),
            T_ADDR_Q        => regs_rbit(OM_ADDR_REGS_HI downto OM_ADDR_REGS_LO),
            T_MODE_L        => regs_load(OM_MODE_REGS_HI downto OM_MODE_REGS_LO),
            T_MODE_D        => regs_wbit(OM_MODE_REGS_HI downto OM_MODE_REGS_LO),
            T_MODE_Q        => regs_rbit(OM_MODE_REGS_HI downto OM_MODE_REGS_LO),
            T_STAT_L        => regs_load(OM_STAT_REGS_HI downto OM_STAT_REGS_LO),
            T_STAT_D        => regs_wbit(OM_STAT_REGS_HI downto OM_STAT_REGS_LO),
            T_STAT_Q        => regs_rbit(OM_STAT_REGS_HI downto OM_STAT_REGS_LO),
            T_STAT_I        => om_stat_i       , -- In  :
            T_RESET_L       => regs_load(OM_CTRL_RESET_POS),
            T_RESET_D       => regs_wbit(OM_CTRL_RESET_POS),
            T_RESET_Q       => regs_rbit(OM_CTRL_RESET_POS),
            T_START_L       => regs_load(OM_CTRL_START_POS),
            T_START_D       => regs_wbit(OM_CTRL_START_POS),
            T_START_Q       => regs_rbit(OM_CTRL_START_POS),
            T_STOP_L        => regs_load(OM_CTRL_STOP_POS ),
            T_STOP_D        => regs_wbit(OM_CTRL_STOP_POS ),
            T_STOP_Q        => regs_rbit(OM_CTRL_STOP_POS ),
            T_PAUSE_L       => regs_load(OM_CTRL_PAUSE_POS),
            T_PAUSE_D       => regs_wbit(OM_CTRL_PAUSE_POS),
            T_PAUSE_Q       => regs_rbit(OM_CTRL_PAUSE_POS),
            T_ERROR         => om_error        , -- Out :
            T_DONE          => om_done         , -- Out :
            T_ENTER         => om_enter        , -- Out :
        -------------------------------------------------------------------------------
        -- Pump Control Register Interface Signals.
        -------------------------------------------------------------------------------
            P_RESET_L       => op_reset_load   , -- Out :
            P_RESET_D       => op_reset_wbit   , -- Out :
            P_RESET_Q       => op_reset_rbit   , -- In  :
            P_START_L       => op_start_load   , -- Out :
            P_START_D       => op_start_wbit   , -- Out :
            P_START_Q       => op_start_rbit   , -- In  :
            P_STOP_L        => op_stop_load    , -- Out :
            P_STOP_D        => op_stop_wbit    , -- Out :
            P_STOP_Q        => op_stop_rbit    , -- In  :
            P_PAUSE_L       => op_pause_load   , -- Out :
            P_PAUSE_D       => op_pause_wbit   , -- Out :
            P_PAUSE_Q       => op_pause_rbit   , -- In  :
            P_OPERAND_L     => op_trb_load     , -- Out :
            P_OPERAND_D     => op_trb_wbit     , -- Out :
            P_OPERAND_Q     => op_trb_rbit     , -- In  :
            P_RUN           => op_run          , -- In  :
            P_DONE          => op_done         , -- In  :
            P_ERROR         => op_error          -- In  :
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    IM: PUMP_SEQUENCER
        generic map (
            M_ADDR_BITS     => M_ADDR_WIDTH    , -- 
            M_BUF_SIZE      => MR_BUF_SIZE     , -- 
            M_BUF_WIDTH     => MR_BUF_WIDTH    , -- 
            TRB_BITS        => TRB_BITS        , -- 
            TRB_PUMP_LO     => TRB_PUMP_LO     , -- 
            TRB_PUMP_HI     => TRB_PUMP_HI     , -- 
            TRB_ADDR_LO     => 0               , -- 
            TRB_ADDR_HI     => 63              , -- 
            TRB_MODE_LO     => 64              , -- 
            TRB_MODE_HI     => 64+47           , -- 
            TRB_STAT_LO     => 64+48           , -- 
            TRB_STAT_HI     => 64+48+7           -- 
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock & Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => ACLK            , -- In  :
            RST             => RST             , -- In  :
            CLR             => CLR             , -- In  :
        -------------------------------------------------------------------------------
        -- Transfer Request Block Read Signals.
        -------------------------------------------------------------------------------
            M_REQ_VALID     => im_req_valid    , -- Out :
            M_REQ_ADDR      => im_req_addr     , -- Out :
            M_REQ_SIZE      => im_req_size     , -- Out :
            M_REQ_PTR       => im_req_ptr      , -- Out :
            M_REQ_FIRST     => im_req_first    , -- Out :
            M_REQ_LAST      => im_req_last     , -- Out :
            M_REQ_READY     => mr_req_ready    , -- In  :
            M_ACK_VALID     => im_ack_valid    , -- In  :
            M_ACK_ERROR     => mr_ack_error    , -- In  :
            M_ACK_NEXT      => mr_ack_next     , -- In  :
            M_ACK_LAST      => mr_ack_last     , -- In  :
            M_ACK_STOP      => mr_ack_stop     , -- In  :
            M_ACK_NONE      => mr_ack_none     , -- In  :
            M_ACK_SIZE      => mr_ack_size     , -- In  :
            M_BUF_WE        => im_buf_wen      , -- In  :
            M_BUF_BEN       => mr_buf_ben      , -- In  :
            M_BUF_DATA      => mr_buf_wdata    , -- In  :
            M_BUF_PTR       => mr_buf_wptr     , -- In  :
            M_BUF_RDY       => im_buf_wrdy     , -- Out :
        -------------------------------------------------------------------------------
        -- Control Status Register Interface Signals.
        -------------------------------------------------------------------------------
            T_ADDR_L        => regs_load(IM_ADDR_REGS_HI downto IM_ADDR_REGS_LO),
            T_ADDR_D        => regs_wbit(IM_ADDR_REGS_HI downto IM_ADDR_REGS_LO),
            T_ADDR_Q        => regs_rbit(IM_ADDR_REGS_HI downto IM_ADDR_REGS_LO),
            T_MODE_L        => regs_load(IM_MODE_REGS_HI downto IM_MODE_REGS_LO),
            T_MODE_D        => regs_wbit(IM_MODE_REGS_HI downto IM_MODE_REGS_LO),
            T_MODE_Q        => regs_rbit(IM_MODE_REGS_HI downto IM_MODE_REGS_LO),
            T_STAT_L        => regs_load(IM_STAT_REGS_HI downto IM_STAT_REGS_LO),
            T_STAT_D        => regs_wbit(IM_STAT_REGS_HI downto IM_STAT_REGS_LO),
            T_STAT_Q        => regs_rbit(IM_STAT_REGS_HI downto IM_STAT_REGS_LO),
            T_STAT_I        => im_stat_i       , -- In  :
            T_RESET_L       => regs_load(IM_CTRL_RESET_POS),
            T_RESET_D       => regs_wbit(IM_CTRL_RESET_POS),
            T_RESET_Q       => regs_rbit(IM_CTRL_RESET_POS),
            T_START_L       => regs_load(IM_CTRL_START_POS),
            T_START_D       => regs_wbit(IM_CTRL_START_POS),
            T_START_Q       => regs_rbit(IM_CTRL_START_POS),
            T_STOP_L        => regs_load(IM_CTRL_STOP_POS ),
            T_STOP_D        => regs_wbit(IM_CTRL_STOP_POS ),
            T_STOP_Q        => regs_rbit(IM_CTRL_STOP_POS ),
            T_PAUSE_L       => regs_load(IM_CTRL_PAUSE_POS),
            T_PAUSE_D       => regs_wbit(IM_CTRL_PAUSE_POS),
            T_PAUSE_Q       => regs_rbit(IM_CTRL_PAUSE_POS),
            T_ERROR         => im_error        , -- Out :
            T_DONE          => im_done         , -- Out :
            T_ENTER         => im_enter        , -- Out :
        -------------------------------------------------------------------------------
        -- Pump Control Register Interface Signals.
        -------------------------------------------------------------------------------
            P_RESET_L       => ip_reset_load   , -- Out :
            P_RESET_D       => ip_reset_wbit   , -- Out :
            P_RESET_Q       => ip_reset_rbit   , -- In  :
            P_START_L       => ip_start_load   , -- Out :
            P_START_D       => ip_start_wbit   , -- Out :
            P_START_Q       => ip_start_rbit   , -- In  :
            P_STOP_L        => ip_stop_load    , -- Out :
            P_STOP_D        => ip_stop_wbit    , -- Out :
            P_STOP_Q        => ip_stop_rbit    , -- In  :
            P_PAUSE_L       => ip_pause_load   , -- Out :
            P_PAUSE_D       => ip_pause_wbit   , -- Out :
            P_PAUSE_Q       => ip_pause_rbit   , -- In  :
            P_OPERAND_L     => ip_trb_load     , -- Out :
            P_OPERAND_D     => ip_trb_wbit     , -- Out :
            P_OPERAND_Q     => ip_trb_rbit     , -- In  :
            P_RUN           => ip_run          , -- In  :
            P_DONE          => ip_done         , -- In  :
            P_ERROR         => ip_error          -- In  :
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    CORE: PUMP_AXI4_TO_AXI4_CORE
        generic map (
            I_ADDR_WIDTH    => I_ADDR_WIDTH    ,
            I_DATA_WIDTH    => I_DATA_WIDTH    ,
            I_ID_WIDTH      => I_ID_WIDTH      ,
            I_AUSER_WIDTH   => I_AUSER_WIDTH   ,
            I_RUSER_WIDTH   => I_RUSER_WIDTH   ,
            I_AXI_ID        => I_AXI_ID        ,
            I_REG_ADDR_BITS => TRB_ADDR_BITS   ,
            I_REG_SIZE_BITS => TRB_SIZE_BITS   ,
            I_REG_MODE_BITS => TRB_MODE_BITS   ,
            I_REG_STAT_BITS => TRB_STAT_BITS   ,
            I_MAX_XFER_SIZE => I_MAX_XFER_SIZE ,
            I_RES_QUEUE     => 1               ,
            O_ADDR_WIDTH    => O_ADDR_WIDTH    ,
            O_DATA_WIDTH    => O_DATA_WIDTH    ,
            O_ID_WIDTH      => O_ID_WIDTH      ,
            O_AUSER_WIDTH   => O_AUSER_WIDTH   ,
            O_WUSER_WIDTH   => O_WUSER_WIDTH   ,
            O_BUSER_WIDTH   => O_BUSER_WIDTH   ,
            O_AXI_ID        => O_AXI_ID        ,
            O_REG_ADDR_BITS => TRB_ADDR_BITS   ,
            O_REG_SIZE_BITS => TRB_SIZE_BITS   ,
            O_REG_MODE_BITS => TRB_MODE_BITS   ,
            O_REG_STAT_BITS => TRB_STAT_BITS   ,
            O_MAX_XFER_SIZE => O_MAX_XFER_SIZE ,
            O_RES_QUEUE     => 2               ,
            BUF_DEPTH       => BUF_DEPTH       
        )
        port map (
        ---------------------------------------------------------------------------
        -- Clock & Reset Signals.
        ---------------------------------------------------------------------------
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
        ---------------------------------------------------------------------------
        -- Intake Control Register Interface.
        ---------------------------------------------------------------------------
            I_ADDR_L        => ip_trb_load(TRB_ADDR_HI downto TRB_ADDR_LO),
            I_ADDR_D        => ip_trb_wbit(TRB_ADDR_HI downto TRB_ADDR_LO),
            I_ADDR_Q        => ip_trb_rbit(TRB_ADDR_HI downto TRB_ADDR_LO),
            I_SIZE_L        => ip_trb_load(TRB_SIZE_HI downto TRB_SIZE_LO),
            I_SIZE_D        => ip_trb_wbit(TRB_SIZE_HI downto TRB_SIZE_LO),
            I_SIZE_Q        => ip_trb_rbit(TRB_SIZE_HI downto TRB_SIZE_LO),
            I_MODE_L        => ip_trb_load(TRB_MODE_HI downto TRB_MODE_LO),
            I_MODE_D        => ip_trb_wbit(TRB_MODE_HI downto TRB_MODE_LO),
            I_MODE_Q        => ip_trb_rbit(TRB_MODE_HI downto TRB_MODE_LO),
            I_STAT_L        => ip_trb_load(TRB_STAT_HI downto TRB_STAT_LO),
            I_STAT_D        => ip_trb_wbit(TRB_STAT_HI downto TRB_STAT_LO),
            I_STAT_Q        => ip_trb_rbit(TRB_STAT_HI downto TRB_STAT_LO),
            I_STAT_I        => ip_stat_in      ,
            I_RESET_L       => ip_reset_load   ,
            I_RESET_D       => ip_reset_wbit   ,
            I_RESET_Q       => ip_reset_rbit   ,
            I_START_L       => ip_start_load   ,
            I_START_D       => ip_start_wbit   ,
            I_START_Q       => ip_start_rbit   ,
            I_STOP_L        => ip_stop_load    , 
            I_STOP_D        => ip_stop_wbit    ,
            I_STOP_Q        => ip_stop_rbit    ,
            I_PAUSE_L       => ip_pause_load   ,
            I_PAUSE_D       => ip_pause_wbit   ,
            I_PAUSE_Q       => ip_pause_rbit   ,
            I_FIRST_L       => ip_trb_load(TRB_FIRST_POS  ),
            I_FIRST_D       => ip_trb_wbit(TRB_FIRST_POS  ),
            I_FIRST_Q       => ip_trb_rbit(TRB_FIRST_POS  ),
            I_LAST_L        => ip_trb_load(TRB_LAST_POS   ),
            I_LAST_D        => ip_trb_wbit(TRB_LAST_POS   ),
            I_LAST_Q        => ip_trb_rbit(TRB_LAST_POS   ),
            I_DONE_EN_L     => ip_trb_load(TRB_DONE_EN_POS),
            I_DONE_EN_D     => ip_trb_wbit(TRB_DONE_EN_POS),
            I_DONE_EN_Q     => ip_trb_rbit(TRB_DONE_EN_POS),
            I_DONE_ST_L     => ip_trb_load(TRB_DONE_ST_POS),
            I_DONE_ST_D     => ip_trb_wbit(TRB_DONE_ST_POS),
            I_DONE_ST_Q     => ip_trb_rbit(TRB_DONE_ST_POS),
            I_ERR_ST_L      => ip_trb_load(TRB_ERR_ST_POS ),
            I_ERR_ST_D      => ip_trb_wbit(TRB_ERR_ST_POS ),
            I_ERR_ST_Q      => ip_trb_rbit(TRB_ERR_ST_POS ),
            I_ADDR_FIX      => ip_trb_rbit(TRB_ADDR_FIX_POS),
            I_SPECULATIVE   => ip_trb_rbit(TRB_SPECUL_POS ),
            I_SAFETY        => ip_trb_rbit(TRB_SAFETY_POS ),
            I_CACHE         => ip_trb_rbit(TRB_CACHE_HI downto TRB_CACHE_LO),
            I_LOCK          => I_LOCK          ,
            I_PROT          => I_PROT          ,
            I_QOS           => I_QOS           ,
            I_REGION        => I_REGION        ,
        -------------------------------------------------------------------------------
        -- Outlet Control Register Interface.
        -------------------------------------------------------------------------------
            O_ADDR_L        => op_trb_load(TRB_ADDR_HI downto TRB_ADDR_LO),
            O_ADDR_D        => op_trb_wbit(TRB_ADDR_HI downto TRB_ADDR_LO),
            O_ADDR_Q        => op_trb_rbit(TRB_ADDR_HI downto TRB_ADDR_LO),
            O_SIZE_L        => op_trb_load(TRB_SIZE_HI downto TRB_SIZE_LO),
            O_SIZE_D        => op_trb_wbit(TRB_SIZE_HI downto TRB_SIZE_LO),
            O_SIZE_Q        => op_trb_rbit(TRB_SIZE_HI downto TRB_SIZE_LO),
            O_MODE_L        => op_trb_load(TRB_MODE_HI downto TRB_MODE_LO),
            O_MODE_D        => op_trb_wbit(TRB_MODE_HI downto TRB_MODE_LO),
            O_MODE_Q        => op_trb_rbit(TRB_MODE_HI downto TRB_MODE_LO),
            O_STAT_L        => op_trb_load(TRB_STAT_HI downto TRB_STAT_LO),
            O_STAT_D        => op_trb_wbit(TRB_STAT_HI downto TRB_STAT_LO),
            O_STAT_Q        => op_trb_rbit(TRB_STAT_HI downto TRB_STAT_LO),
            O_STAT_I        => op_stat_in      ,
            O_RESET_L       => op_reset_load   ,
            O_RESET_D       => op_reset_wbit   ,
            O_RESET_Q       => op_reset_rbit   ,
            O_START_L       => op_start_load   ,
            O_START_D       => op_start_wbit   ,
            O_START_Q       => op_start_rbit   ,
            O_STOP_L        => op_stop_load    , 
            O_STOP_D        => op_stop_wbit    ,
            O_STOP_Q        => op_stop_rbit    ,
            O_PAUSE_L       => op_pause_load   ,
            O_PAUSE_D       => op_pause_wbit   ,
            O_PAUSE_Q       => op_pause_rbit   ,
            O_FIRST_L       => op_trb_load(TRB_FIRST_POS  ),
            O_FIRST_D       => op_trb_wbit(TRB_FIRST_POS  ),
            O_FIRST_Q       => op_trb_rbit(TRB_FIRST_POS  ),
            O_LAST_L        => op_trb_load(TRB_LAST_POS   ),
            O_LAST_D        => op_trb_wbit(TRB_LAST_POS   ),
            O_LAST_Q        => op_trb_rbit(TRB_LAST_POS   ),
            O_DONE_EN_L     => op_trb_load(TRB_DONE_EN_POS),
            O_DONE_EN_D     => op_trb_wbit(TRB_DONE_EN_POS),
            O_DONE_EN_Q     => op_trb_rbit(TRB_DONE_EN_POS),
            O_DONE_ST_L     => op_trb_load(TRB_DONE_ST_POS),
            O_DONE_ST_D     => op_trb_wbit(TRB_DONE_ST_POS),
            O_DONE_ST_Q     => op_trb_rbit(TRB_DONE_ST_POS),
            O_ERR_ST_L      => op_trb_load(TRB_ERR_ST_POS ),
            O_ERR_ST_D      => op_trb_wbit(TRB_ERR_ST_POS ),
            O_ERR_ST_Q      => op_trb_rbit(TRB_ERR_ST_POS ),
            O_ADDR_FIX      => op_trb_rbit(TRB_ADDR_FIX_POS),
            O_SPECULATIVE   => op_trb_rbit(TRB_SPECUL_POS ),
            O_SAFETY        => op_trb_rbit(TRB_SAFETY_POS ),
            O_CACHE         => op_trb_rbit(TRB_CACHE_HI downto TRB_CACHE_LO),
            O_LOCK          => O_LOCK          ,
            O_PROT          => O_PROT          ,
            O_QOS           => O_QOS           ,
            O_REGION        => O_REGION        ,
        --------------------------------------------------------------------------
        -- Input AXI4 Read Address Channel Signals.
        --------------------------------------------------------------------------
            I_ARID          => I_ARID          , -- Out :
            I_ARADDR        => I_ARADDR        , -- Out :
            I_ARLEN         => I_ARLEN         , -- Out :
            I_ARSIZE        => I_ARSIZE        , -- Out :
            I_ARBURST       => I_ARBURST       , -- Out :
            I_ARLOCK        => I_ARLOCK        , -- Out :
            I_ARCACHE       => I_ARCACHE       , -- Out :
            I_ARPROT        => I_ARPROT        , -- Out :
            I_ARQOS         => I_ARQOS         , -- Out :
            I_ARREGION      => I_ARREGION      , -- Out :
            I_ARUSER        => I_ARUSER        , -- Out :
            I_ARVALID       => I_ARVALID       , -- Out :
            I_ARREADY       => I_ARREADY       , -- In  :
        --------------------------------------------------------------------------
        -- Input AXI4 Read Data Channel Signals.
        --------------------------------------------------------------------------
            I_RID           => I_RID           , -- In  :
            I_RDATA         => I_RDATA         , -- In  :
            I_RRESP         => I_RRESP         , -- In  :
            I_RLAST         => I_RLAST         , -- In  :
            I_RUSER         => I_RUSER         , -- In  :
            I_RVALID        => I_RVALID        , -- In  :
            I_RREADY        => I_RREADY        , -- Out :
        --------------------------------------------------------------------------
        -- Output AXI4 Write Address Channel Signals.
        --------------------------------------------------------------------------
            O_AWID          => O_AWID          , -- Out :
            O_AWADDR        => O_AWADDR        , -- Out :
            O_AWLEN         => O_AWLEN         , -- Out :
            O_AWSIZE        => O_AWSIZE        , -- Out :
            O_AWBURST       => O_AWBURST       , -- Out :
            O_AWLOCK        => O_AWLOCK        , -- Out :
            O_AWCACHE       => O_AWCACHE       , -- Out :
            O_AWPROT        => O_AWPROT        , -- Out :
            O_AWQOS         => O_AWQOS         , -- Out :
            O_AWREGION      => O_AWREGION      , -- Out :
            O_AWUSER        => O_AWUSER        , -- Out :
            O_AWVALID       => O_AWVALID       , -- Out :
            O_AWREADY       => O_AWREADY       , -- In  :
        --------------------------------------------------------------------------
        -- Output AXI4 Write Data Channel Signals.
        --------------------------------------------------------------------------
            O_WID           => O_WID           , -- Out :
            O_WDATA         => O_WDATA         , -- Out :
            O_WSTRB         => O_WSTRB         , -- Out :
            O_WUSER         => O_WUSER         , -- Out :
            O_WLAST         => O_WLAST         , -- Out :
            O_WVALID        => O_WVALID        , -- Out :
            O_WREADY        => O_WREADY        , -- In  :
        --------------------------------------------------------------------------
        -- Output AXI4 Write Response Channel Signals.
        --------------------------------------------------------------------------
            O_BID           => O_BID           , -- In  :
            O_BRESP         => O_BRESP         , -- In  :
            O_BUSER         => O_BUSER         , -- In  :
            O_BVALID        => O_BVALID        , -- In  :
            O_BREADY        => O_BREADY        , -- Out :
        -------------------------------------------------------------------------------
        -- Intake Status.
        -------------------------------------------------------------------------------
            I_OPEN          => ip_open         , -- Out :
            I_RUNNING       => ip_run          , -- Out :
            I_DONE          => ip_done         , -- Out :
            I_ERROR         => ip_error        , -- Out :
        -------------------------------------------------------------------------------
        -- Outlet Status.
        -------------------------------------------------------------------------------
            O_OPEN          => op_open         , -- Out :
            O_RUNNING       => op_run          , -- Out :
            O_DONE          => op_done         , -- Out :
            O_ERROR         => op_error          -- Out :
        );
    ip_trb_rbit(TRB_RESV_POS) <= '0';
    op_trb_rbit(TRB_RESV_POS) <= '0';
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    ip_stat_in <= (others => '0');
    op_stat_in <= (others => '0');
end RTL;

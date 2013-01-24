-----------------------------------------------------------------------------------
--!     @file    pump_axi4_to_axi4.vhd
--!     @brief   Pump Sample Module (AXI4 to AXI4)
--!     @version 0.0.9
--!     @date    2013/1/23
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
entity  PUMP_AXI4_TO_AXI4 is
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    generic (
        C_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        C_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        C_ID_WIDTH      : integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
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
        --------------------------------------------------------------------------
        -- Clock and Reset Signals.
        --------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        --------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Address Channel Signals.
        --------------------------------------------------------------------------
        C_ARID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_ARADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
        C_ARLEN         : in    AXI4_ALEN_TYPE;
        C_ARSIZE        : in    AXI4_ASIZE_TYPE;
        C_ARBURST       : in    AXI4_ABURST_TYPE;
        C_ARVALID       : in    std_logic;
        C_ARREADY       : out   std_logic;
        --------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Read Data Channel Signals.
        --------------------------------------------------------------------------
        C_RID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_RDATA         : out   std_logic_vector(C_DATA_WIDTH  -1 downto 0);
        C_RRESP         : out   AXI4_RESP_TYPE;
        C_RLAST         : out   std_logic;
        C_RVALID        : out   std_logic;
        C_RREADY        : in    std_logic;
        --------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Address Channel Signals.
        --------------------------------------------------------------------------
        C_AWID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_AWADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
        C_AWLEN         : in    AXI4_ALEN_TYPE;
        C_AWSIZE        : in    AXI4_ASIZE_TYPE;
        C_AWBURST       : in    AXI4_ABURST_TYPE;
        C_AWVALID       : in    std_logic;
        C_AWREADY       : out   std_logic;
        --------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Data Channel Signals.
        --------------------------------------------------------------------------
        C_WDATA         : in    std_logic_vector(C_DATA_WIDTH  -1 downto 0);
        C_WSTRB         : in    std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
        C_WLAST         : in    std_logic;
        C_WVALID        : in    std_logic;
        C_WREADY        : out   std_logic;
        --------------------------------------------------------------------------
        -- Control Status Register I/F AXI4 Write Response Channel Signals.
        --------------------------------------------------------------------------
        C_BID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
        C_BRESP         : out   AXI4_RESP_TYPE;
        C_BVALID        : out   std_logic;
        C_BREADY        : in    std_logic;
        --------------------------------------------------------------------------
        -- Input AXI4 Read Address Channel Signals.
        --------------------------------------------------------------------------
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
        --------------------------------------------------------------------------
        -- Input AXI4 Read Data Channel Signals.
        --------------------------------------------------------------------------
        I_RID           : in    std_logic_vector(I_ID_WIDTH    -1 downto 0);
        I_RDATA         : in    std_logic_vector(I_DATA_WIDTH  -1 downto 0);
        I_RRESP         : in    AXI4_RESP_TYPE;
        I_RLAST         : in    std_logic;
        I_RUSER         : in    std_logic_vector(I_RUSER_WIDTH -1 downto 0);
        I_RVALID        : in    std_logic;
        I_RREADY        : out   std_logic;
        --------------------------------------------------------------------------
        -- Output AXI4 Write Address Channel Signals.
        --------------------------------------------------------------------------
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
        --------------------------------------------------------------------------
        -- Output AXI4 Write Data Channel Signals.
        --------------------------------------------------------------------------
        O_WID           : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_WDATA         : out   std_logic_vector(O_DATA_WIDTH  -1 downto 0);
        O_WSTRB         : out   std_logic_vector(O_DATA_WIDTH/8-1 downto 0);
        O_WUSER         : out   std_logic_vector(O_WUSER_WIDTH -1 downto 0);
        O_WLAST         : out   std_logic;
        O_WVALID        : out   std_logic;
        O_WREADY        : in    std_logic;
        --------------------------------------------------------------------------
        -- Output AXI4 Write Response Channel Signals.
        --------------------------------------------------------------------------
        O_BID           : in    std_logic_vector(O_ID_WIDTH    -1 downto 0);
        O_BRESP         : in    AXI4_RESP_TYPE;
        O_BUSER         : in    std_logic_vector(O_BUSER_WIDTH -1 downto 0);
        O_BVALID        : in    std_logic;
        O_BREADY        : out   std_logic;
        --------------------------------------------------------------------------
        -- 
        --------------------------------------------------------------------------
        I_IRQ           : out   std_logic;
        O_IRQ           : out   std_logic
    );
end PUMP_AXI4_TO_AXI4;
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
use     PIPEWORK.COMPONENTS.SDPRAM;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROLLER;
architecture RTL of PUMP_AXI4_TO_AXI4 is
    ------------------------------------------------------------------------------
    -- リセット信号.
    ------------------------------------------------------------------------------
    signal   RST                : std_logic;
    constant CLR                : std_logic := '0';
    ------------------------------------------------------------------------------
    -- PUMP_AXI4_TO_AXI4_CORE のコンポーネント宣言.
    ------------------------------------------------------------------------------
    component PUMP_AXI4_TO_AXI4_CORE
        --------------------------------------------------------------------------
        -- 
        --------------------------------------------------------------------------
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
            I_SPECULATIVE   : in  std_logic;
            I_SAFETY        : in  std_logic;
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
            O_SPECULATIVE   : in  std_logic;
            O_SAFETY        : in  std_logic;
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
            ----------------------------------------------------------------------
            -- Input AXI4 Read Data Channel Signals.
            ----------------------------------------------------------------------
            I_RID           : in  std_logic_vector(I_ID_WIDTH    -1 downto 0);
            I_RDATA         : in  std_logic_vector(I_DATA_WIDTH  -1 downto 0);
            I_RRESP         : in  AXI4_RESP_TYPE;
            I_RLAST         : in  std_logic;
            I_RUSER         : in  std_logic_vector(I_RUSER_WIDTH -1 downto 0);
            I_RVALID        : in  std_logic;
            I_RREADY        : out std_logic;
            ----------------------------------------------------------------------
            -- Output AXI4 Write Address Channel Signals.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- Output AXI4 Write Data Channel Signals.
            ----------------------------------------------------------------------
            O_WID           : out std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_WDATA         : out std_logic_vector(O_DATA_WIDTH  -1 downto 0);
            O_WSTRB         : out std_logic_vector(O_DATA_WIDTH/8-1 downto 0);
            O_WUSER         : out std_logic_vector(O_WUSER_WIDTH -1 downto 0);
            O_WLAST         : out std_logic;
            O_WVALID        : out std_logic;
            O_WREADY        : in  std_logic;
            ----------------------------------------------------------------------
            -- Output AXI4 Write Response Channel Signals.
            ----------------------------------------------------------------------
            O_BID           : in  std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_BRESP         : in  AXI4_RESP_TYPE;
            O_BUSER         : in  std_logic_vector(O_BUSER_WIDTH -1 downto 0);
            O_BVALID        : in  std_logic;
            O_BREADY        : out std_logic;
            ----------------------------------------------------------------------
            -- Intake Status.
            ----------------------------------------------------------------------
            I_OPEN          : out std_logic;
            I_RUNNING       : out std_logic;
            I_DONE          : out std_logic;
            ----------------------------------------------------------------------
            -- Outlet Status.
            ----------------------------------------------------------------------
            O_OPEN          : out std_logic;
            O_RUNNING       : out std_logic;
            O_DONE          : out std_logic
        );
    end component;
    ------------------------------------------------------------------------------
    -- アドレスレジスタのビット数.
    ------------------------------------------------------------------------------
    constant ADDR_REGS_BITS     : integer := 64;
    ------------------------------------------------------------------------------
    -- サイズレジスタのビット数.
    ------------------------------------------------------------------------------
    constant SIZE_REGS_BITS     : integer := 32;
    ------------------------------------------------------------------------------
    -- レジスタアクセスインターフェースのアドレスのビット数.
    ------------------------------------------------------------------------------
    constant REGS_ADDR_WIDTH    : integer := 5;
    ------------------------------------------------------------------------------
    -- レジスタアクセスインターフェースのデータのビット数.
    ------------------------------------------------------------------------------
    constant REGS_DATA_WIDTH    : integer := 32;
    ------------------------------------------------------------------------------
    -- 全レジスタのビット数.
    ------------------------------------------------------------------------------
    constant REGS_DATA_BITS     : integer := (2**REGS_ADDR_WIDTH)*8;
    ------------------------------------------------------------------------------
    -- レジスタアクセス用の信号群.
    ------------------------------------------------------------------------------
    signal   regs_req           : std_logic;
    signal   regs_write         : std_logic;
    signal   regs_ack           : std_logic;
    constant regs_err           : std_logic := '0';
    signal   regs_addr          : std_logic_vector(REGS_ADDR_WIDTH  -1 downto 0);
    signal   regs_ben           : std_logic_vector(REGS_DATA_WIDTH/8-1 downto 0);
    signal   regs_wdata         : std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
    signal   regs_rdata         : std_logic_vector(REGS_DATA_WIDTH  -1 downto 0);
    signal   regs_wen           : std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal   regs_wbit          : std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal   regs_rbit          : std_logic_vector(REGS_DATA_BITS   -1 downto 0);
    signal   i_stat_in          : std_logic_vector(5 downto 0);
    signal   i_open             : std_logic;
    signal   i_running          : std_logic;
    signal   i_done             : std_logic;
    signal   o_stat_in          : std_logic_vector(5 downto 0);
    signal   o_open             : std_logic;
    signal   o_running          : std_logic;
    signal   o_done             : std_logic;
    ------------------------------------------------------------------------------
    -- レジスタのアドレスマップ.
    ------------------------------------------------------------------------------
    -- Outlet Address Register
    ------------------------------------------------------------------------------
    constant O_ADDR_REGS_ADDR   : integer := 16#00#;
    constant O_ADDR_REGS_LO     : integer := 8*O_ADDR_REGS_ADDR;
    constant O_ADDR_REGS_HI     : integer := 8*O_ADDR_REGS_ADDR + ADDR_REGS_BITS-1;
    ------------------------------------------------------------------------------
    -- Outlet Size Register
    ------------------------------------------------------------------------------
    constant O_SIZE_REGS_ADDR   : integer := 16#08#;
    constant O_SIZE_REGS_LO     : integer := 8*O_SIZE_REGS_ADDR;
    constant O_SIZE_REGS_HI     : integer := 8*O_SIZE_REGS_ADDR + SIZE_REGS_BITS-1;
    ------------------------------------------------------------------------------
    -- Outlet Mode Register
    ------------------------------------------------------------------------------
    constant O_MODE_REGS_ADDR   : integer := 16#0C#;
    constant O_MODE_REGS_LO     : integer := 8*O_MODE_REGS_ADDR +  0;
    constant O_MODE_REGS_HI     : integer := 8*O_MODE_REGS_ADDR + 15;
    constant O_MODE_DONE_IE_POS : integer := 8*O_MODE_REGS_ADDR +  0;
    constant O_MODE_ERROR_IE_POS: integer := 8*O_MODE_REGS_ADDR +  1;
    constant O_MODE_SPECUL_POS  : integer := 8*O_MODE_REGS_ADDR + 14;
    constant O_MODE_SAFETY_POS  : integer := 8*O_MODE_REGS_ADDR + 15;
    ------------------------------------------------------------------------------
    -- Outlet Status Register
    ------------------------------------------------------------------------------
    constant O_STAT_REGS_ADDR   : integer := 16#0E#;
    constant O_STAT_DONE_POS    : integer := 8*O_STAT_REGS_ADDR +  0;
    constant O_STAT_ERROR_POS   : integer := 8*O_STAT_REGS_ADDR +  1;
    constant O_STAT_RESV_LO     : integer := 8*O_STAT_REGS_ADDR +  2;
    constant O_STAT_RESV_HI     : integer := 8*O_STAT_REGS_ADDR +  7;
    ------------------------------------------------------------------------------
    -- Outlet Control Register
    ------------------------------------------------------------------------------
    constant O_CTRL_REGS_ADDR   : integer := 16#0F#;
    constant O_CTRL_START_POS   : integer := 8*O_CTRL_REGS_ADDR +  0;
    constant O_CTRL_FIRST_POS   : integer := 8*O_CTRL_REGS_ADDR +  1;
    constant O_CTRL_LAST_POS    : integer := 8*O_CTRL_REGS_ADDR +  2;
    constant O_CTRL_DONE_EN_POS : integer := 8*O_CTRL_REGS_ADDR +  3;
    constant O_CTRL_RESV_POS    : integer := 8*O_CTRL_REGS_ADDR +  4;
    constant O_CTRL_STOP_POS    : integer := 8*O_CTRL_REGS_ADDR +  5;
    constant O_CTRL_PAUSE_POS   : integer := 8*O_CTRL_REGS_ADDR +  6;
    constant O_CTRL_RESET_POS   : integer := 8*O_CTRL_REGS_ADDR +  7;
    ------------------------------------------------------------------------------
    -- Intake Address Register
    ------------------------------------------------------------------------------
    constant I_ADDR_REGS_ADDR   : integer := 16#10#;
    constant I_ADDR_REGS_LO     : integer := 8*I_ADDR_REGS_ADDR;
    constant I_ADDR_REGS_HI     : integer := 8*I_ADDR_REGS_ADDR + ADDR_REGS_BITS-1;
    ------------------------------------------------------------------------------
    -- Intake Size Register
    ------------------------------------------------------------------------------
    constant I_SIZE_REGS_ADDR   : integer := 16#18#;
    constant I_SIZE_REGS_LO     : integer := 8*I_SIZE_REGS_ADDR;
    constant I_SIZE_REGS_HI     : integer := 8*I_SIZE_REGS_ADDR + SIZE_REGS_BITS-1;
    ------------------------------------------------------------------------------
    -- Intake Mode Register
    ------------------------------------------------------------------------------
    constant I_MODE_REGS_ADDR   : integer := 16#1C#;
    constant I_MODE_REGS_LO     : integer := 8*I_MODE_REGS_ADDR +  0;
    constant I_MODE_DONE_IE_POS : integer := 8*I_MODE_REGS_ADDR +  0;
    constant I_MODE_ERROR_IE_POS: integer := 8*I_MODE_REGS_ADDR +  1;
    constant I_MODE_SPECUL_POS  : integer := 8*I_MODE_REGS_ADDR + 14;
    constant I_MODE_SAFETY_POS  : integer := 8*I_MODE_REGS_ADDR + 15;
    constant I_MODE_REGS_HI     : integer := 8*I_MODE_REGS_ADDR + 15;
    ------------------------------------------------------------------------------
    -- Intake Status Register
    ------------------------------------------------------------------------------
    constant I_STAT_REGS_ADDR   : integer := 16#1E#;
    constant I_STAT_DONE_POS    : integer := 8*I_STAT_REGS_ADDR +  0;
    constant I_STAT_ERROR_POS   : integer := 8*I_STAT_REGS_ADDR +  1;
    constant I_STAT_RESV_LO     : integer := 8*I_STAT_REGS_ADDR +  2;
    constant I_STAT_RESV_HI     : integer := 8*I_STAT_REGS_ADDR +  7;
    ------------------------------------------------------------------------------
    -- Intake Control Register
    ------------------------------------------------------------------------------
    constant I_CTRL_REGS_ADDR   : integer := 16#1F#;
    constant I_CTRL_START_POS   : integer := 8*I_CTRL_REGS_ADDR +  0;
    constant I_CTRL_FIRST_POS   : integer := 8*I_CTRL_REGS_ADDR +  1;
    constant I_CTRL_LAST_POS    : integer := 8*I_CTRL_REGS_ADDR +  2;
    constant I_CTRL_DONE_EN_POS : integer := 8*I_CTRL_REGS_ADDR +  3;
    constant I_CTRL_RESV_POS    : integer := 8*I_CTRL_REGS_ADDR +  4;
    constant I_CTRL_STOP_POS    : integer := 8*I_CTRL_REGS_ADDR +  5;
    constant I_CTRL_PAUSE_POS   : integer := 8*I_CTRL_REGS_ADDR +  6;
    constant I_CTRL_RESET_POS   : integer := 8*I_CTRL_REGS_ADDR +  7;
begin
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    RST <= '1' when (ARESETn = '0') else '0';
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    C_IF: AXI4_REGISTER_INTERFACE
        generic map (
            AXI4_ADDR_WIDTH => C_ADDR_WIDTH,
            AXI4_DATA_WIDTH => C_DATA_WIDTH,
            AXI4_ID_WIDTH   => C_ID_WIDTH,
            REGS_ADDR_WIDTH => REGS_ADDR_WIDTH,
            REGS_DATA_WIDTH => REGS_DATA_WIDTH
        )
        port map (
            ----------------------------------------------------------------------
            -- Clock and Reset Signals.
            ----------------------------------------------------------------------
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
            ----------------------------------------------------------------------
            -- AXI4 Read Address Channel Signals.
            ----------------------------------------------------------------------
            ARID            => C_ARID          ,
            ARADDR          => C_ARADDR        , -- In  :
            ARLEN           => C_ARLEN         , -- In  :
            ARSIZE          => C_ARSIZE        , -- In  :
            ARBURST         => C_ARBURST       , -- In  :
            ARVALID         => C_ARVALID       , -- In  :
            ARREADY         => C_ARREADY       , -- Out :
            ----------------------------------------------------------------------
            -- AXI4 Read Data Channel Signals.
            ----------------------------------------------------------------------
            RID             => C_RID           , -- Out :
            RDATA           => C_RDATA         , -- Out :
            RRESP           => C_RRESP         , -- Out :
            RLAST           => C_RLAST         , -- Out :
            RVALID          => C_RVALID        , -- Out :
            RREADY          => C_RREADY        , -- In  :
            ----------------------------------------------------------------------
            -- AXI4 Write Address Channel Signals.
            ----------------------------------------------------------------------
            AWID            => C_AWID          , -- In  :
            AWADDR          => C_AWADDR        , -- In  :
            AWLEN           => C_AWLEN         , -- In  :
            AWSIZE          => C_AWSIZE        , -- In  :
            AWBURST         => C_AWBURST       , -- In  :
            AWVALID         => C_AWVALID       , -- In  :
            AWREADY         => C_AWREADY       , -- Out :
            ----------------------------------------------------------------------
            -- AXI4 Write Data Channel Signals.
            ----------------------------------------------------------------------
            WDATA           => C_WDATA         , -- In  :
            WSTRB           => C_WSTRB         , -- In  :
            WLAST           => C_WLAST         , -- In  :
            WVALID          => C_WVALID        , -- In  :
            WREADY          => C_WREADY        , -- Out :
            ----------------------------------------------------------------------
            -- AXI4 Write Response Channel Signals.
            ----------------------------------------------------------------------
            BID             => C_BID           , -- Out :
            BRESP           => C_BRESP         , -- Out :
            BVALID          => C_BVALID        , -- Out :
            BREADY          => C_BREADY        , -- In  :
            ----------------------------------------------------------------------
            -- Register Interface.
            ----------------------------------------------------------------------
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
                regs_wen(REGS_DATA_WIDTH*(i+1)-1 downto REGS_DATA_WIDTH*i) <= ben_bit;
            else
                regs_wen(REGS_DATA_WIDTH*(i+1)-1 downto REGS_DATA_WIDTH*i) <= ben_bit_0;
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
    CORE: PUMP_AXI4_TO_AXI4_CORE
        generic map (
            I_ADDR_WIDTH    => I_ADDR_WIDTH    ,
            I_DATA_WIDTH    => I_DATA_WIDTH    ,
            I_ID_WIDTH      => I_ID_WIDTH      ,
            I_AUSER_WIDTH   => I_AUSER_WIDTH   ,
            I_RUSER_WIDTH   => I_RUSER_WIDTH   ,
            I_AXI_ID        => I_AXI_ID        ,
            I_REG_ADDR_BITS => ADDR_REGS_BITS  ,
            I_REG_SIZE_BITS => SIZE_REGS_BITS  ,
            I_REG_MODE_BITS => 16              ,
            I_REG_STAT_BITS => 6               ,
            I_MAX_XFER_SIZE => I_MAX_XFER_SIZE ,
            I_RES_QUEUE     => 1               ,
            O_ADDR_WIDTH    => O_ADDR_WIDTH    ,
            O_DATA_WIDTH    => O_DATA_WIDTH    ,
            O_ID_WIDTH      => O_ID_WIDTH      ,
            O_AUSER_WIDTH   => O_AUSER_WIDTH   ,
            O_WUSER_WIDTH   => O_WUSER_WIDTH   ,
            O_BUSER_WIDTH   => O_BUSER_WIDTH   ,
            O_AXI_ID        => O_AXI_ID        ,
            O_REG_ADDR_BITS => ADDR_REGS_BITS  ,
            O_REG_SIZE_BITS => SIZE_REGS_BITS  ,
            O_REG_MODE_BITS => 16              ,
            O_REG_STAT_BITS => 6               ,
            O_MAX_XFER_SIZE => O_MAX_XFER_SIZE ,
            O_RES_QUEUE     => 2               ,
            BUF_DEPTH       => BUF_DEPTH       
        )
        port map (
        -------------------------------------------------------------------------------
        -- Clock & Reset Signals.
        -------------------------------------------------------------------------------
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
        -------------------------------------------------------------------------------
        -- Intake Control Register Interface.
        -------------------------------------------------------------------------------
            I_ADDR_L        => regs_wen (I_ADDR_REGS_HI downto I_ADDR_REGS_LO),
            I_ADDR_D        => regs_wbit(I_ADDR_REGS_HI downto I_ADDR_REGS_LO),
            I_ADDR_Q        => regs_rbit(I_ADDR_REGS_HI downto I_ADDR_REGS_LO),
            I_SIZE_L        => regs_wen (I_SIZE_REGS_HI downto I_SIZE_REGS_LO),
            I_SIZE_D        => regs_wbit(I_SIZE_REGS_HI downto I_SIZE_REGS_LO),
            I_SIZE_Q        => regs_rbit(I_SIZE_REGS_HI downto I_SIZE_REGS_LO),
            I_MODE_L        => regs_wen (I_MODE_REGS_HI downto I_MODE_REGS_LO),
            I_MODE_D        => regs_wbit(I_MODE_REGS_HI downto I_MODE_REGS_LO),
            I_MODE_Q        => regs_rbit(I_MODE_REGS_HI downto I_MODE_REGS_LO),
            I_STAT_L        => regs_wen (I_STAT_RESV_HI downto I_STAT_RESV_LO),
            I_STAT_D        => regs_wbit(I_STAT_RESV_HI downto I_STAT_RESV_LO),
            I_STAT_Q        => regs_rbit(I_STAT_RESV_HI downto I_STAT_RESV_LO),
            I_STAT_I        => i_stat_in ,
            I_RESET_L       => regs_wen (I_CTRL_RESET_POS),
            I_RESET_D       => regs_wbit(I_CTRL_RESET_POS),
            I_RESET_Q       => regs_rbit(I_CTRL_RESET_POS),
            I_START_L       => regs_wen (I_CTRL_START_POS),
            I_START_D       => regs_wbit(I_CTRL_START_POS),
            I_START_Q       => regs_rbit(I_CTRL_START_POS),
            I_STOP_L        => regs_wen (I_CTRL_STOP_POS ),
            I_STOP_D        => regs_wbit(I_CTRL_STOP_POS ),
            I_STOP_Q        => regs_rbit(I_CTRL_STOP_POS ),
            I_PAUSE_L       => regs_wen (I_CTRL_PAUSE_POS),
            I_PAUSE_D       => regs_wbit(I_CTRL_PAUSE_POS),
            I_PAUSE_Q       => regs_rbit(I_CTRL_PAUSE_POS),
            I_FIRST_L       => regs_wen (I_CTRL_FIRST_POS),
            I_FIRST_D       => regs_wbit(I_CTRL_FIRST_POS),
            I_FIRST_Q       => regs_rbit(I_CTRL_FIRST_POS),
            I_LAST_L        => regs_wen (I_CTRL_LAST_POS ),
            I_LAST_D        => regs_wbit(I_CTRL_LAST_POS ),
            I_LAST_Q        => regs_rbit(I_CTRL_LAST_POS ),
            I_DONE_EN_L     => regs_wen (I_CTRL_DONE_EN_POS ),
            I_DONE_EN_D     => regs_wbit(I_CTRL_DONE_EN_POS ),
            I_DONE_EN_Q     => regs_rbit(I_CTRL_DONE_EN_POS ),
            I_DONE_ST_L     => regs_wen (I_STAT_DONE_POS ),
            I_DONE_ST_D     => regs_wbit(I_STAT_DONE_POS ),
            I_DONE_ST_Q     => regs_rbit(I_STAT_DONE_POS ),
            I_ERR_ST_L      => regs_wen (I_STAT_ERROR_POS),
            I_ERR_ST_D      => regs_wbit(I_STAT_ERROR_POS),
            I_ERR_ST_Q      => regs_rbit(I_STAT_ERROR_POS),
            I_SPECULATIVE   => regs_rbit(I_MODE_SPECUL_POS),
            I_SAFETY        => regs_rbit(I_MODE_SAFETY_POS),
        -------------------------------------------------------------------------------
        -- Outlet Control Register Interface.
        -------------------------------------------------------------------------------
            O_ADDR_L        => regs_wen (O_ADDR_REGS_HI downto O_ADDR_REGS_LO),
            O_ADDR_D        => regs_wbit(O_ADDR_REGS_HI downto O_ADDR_REGS_LO),
            O_ADDR_Q        => regs_rbit(O_ADDR_REGS_HI downto O_ADDR_REGS_LO),
            O_SIZE_L        => regs_wen (O_SIZE_REGS_HI downto O_SIZE_REGS_LO),
            O_SIZE_D        => regs_wbit(O_SIZE_REGS_HI downto O_SIZE_REGS_LO),
            O_SIZE_Q        => regs_rbit(O_SIZE_REGS_HI downto O_SIZE_REGS_LO),
            O_MODE_L        => regs_wen (O_MODE_REGS_HI downto O_MODE_REGS_LO),
            O_MODE_D        => regs_wbit(O_MODE_REGS_HI downto O_MODE_REGS_LO),
            O_MODE_Q        => regs_rbit(O_MODE_REGS_HI downto O_MODE_REGS_LO),
            O_STAT_L        => regs_wen (O_STAT_RESV_HI downto O_STAT_RESV_LO),
            O_STAT_D        => regs_wbit(O_STAT_RESV_HI downto O_STAT_RESV_LO),
            O_STAT_Q        => regs_rbit(O_STAT_RESV_HI downto O_STAT_RESV_LO),
            O_STAT_I        => o_stat_in ,
            O_RESET_L       => regs_wen (O_CTRL_RESET_POS),
            O_RESET_D       => regs_wbit(O_CTRL_RESET_POS),
            O_RESET_Q       => regs_rbit(O_CTRL_RESET_POS),
            O_START_L       => regs_wen (O_CTRL_START_POS),
            O_START_D       => regs_wbit(O_CTRL_START_POS),
            O_START_Q       => regs_rbit(O_CTRL_START_POS),
            O_STOP_L        => regs_wen (O_CTRL_STOP_POS ),
            O_STOP_D        => regs_wbit(O_CTRL_STOP_POS ),
            O_STOP_Q        => regs_rbit(O_CTRL_STOP_POS ),
            O_PAUSE_L       => regs_wen (O_CTRL_PAUSE_POS),
            O_PAUSE_D       => regs_wbit(O_CTRL_PAUSE_POS),
            O_PAUSE_Q       => regs_rbit(O_CTRL_PAUSE_POS),
            O_FIRST_L       => regs_wen (O_CTRL_FIRST_POS),
            O_FIRST_D       => regs_wbit(O_CTRL_FIRST_POS),
            O_FIRST_Q       => regs_rbit(O_CTRL_FIRST_POS),
            O_LAST_L        => regs_wen (O_CTRL_LAST_POS ),
            O_LAST_D        => regs_wbit(O_CTRL_LAST_POS ),
            O_LAST_Q        => regs_rbit(O_CTRL_LAST_POS ),
            O_DONE_EN_L     => regs_wen (O_CTRL_DONE_EN_POS ),
            O_DONE_EN_D     => regs_wbit(O_CTRL_DONE_EN_POS ),
            O_DONE_EN_Q     => regs_rbit(O_CTRL_DONE_EN_POS ),
            O_DONE_ST_L     => regs_wen (O_STAT_DONE_POS ),
            O_DONE_ST_D     => regs_wbit(O_STAT_DONE_POS ),
            O_DONE_ST_Q     => regs_rbit(O_STAT_DONE_POS ),
            O_ERR_ST_L      => regs_wen (O_STAT_ERROR_POS),
            O_ERR_ST_D      => regs_wbit(O_STAT_ERROR_POS),
            O_ERR_ST_Q      => regs_rbit(O_STAT_ERROR_POS),
            O_SPECULATIVE   => regs_rbit(O_MODE_SPECUL_POS),
            O_SAFETY        => regs_rbit(O_MODE_SAFETY_POS),
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
            I_OPEN          => i_open          , -- Out :
            I_RUNNING       => i_running       , -- Out :
            I_DONE          => i_done          , -- Out :
        -------------------------------------------------------------------------------
        -- Outlet Status.
        -------------------------------------------------------------------------------
            O_OPEN          => o_open          , -- Out :
            O_RUNNING       => o_running       , -- Out :
            O_DONE          => o_done            -- Out :
        );
    regs_rbit(I_CTRL_RESV_POS) <= '0';
    regs_rbit(O_CTRL_RESV_POS) <= '0';
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    i_stat_in(0) <= '0';
    i_stat_in(1) <= '0';
    i_stat_in(2) <= '0';
    i_stat_in(3) <= '0';
    i_stat_in(4) <= '0';
    i_stat_in(5) <= '0';
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    process (ACLK, RST) begin
        if (RST = '1') then
                I_IRQ <= '0';
        elsif (ACLK'event and ACLK = '1') then
            if (regs_rbit(I_MODE_DONE_IE_POS ) = '1' and regs_rbit(I_STAT_DONE_POS ) = '1') or
               (regs_rbit(I_MODE_ERROR_IE_POS) = '1' and regs_rbit(I_STAT_ERROR_POS) = '1') then
                I_IRQ <= '1';
            else
                I_IRQ <= '0';
            end if;
        end if;
    end process;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    o_stat_in(0) <= '0';
    o_stat_in(1) <= '0';
    o_stat_in(2) <= '0';
    o_stat_in(3) <= '0';
    o_stat_in(4) <= '0';
    o_stat_in(5) <= '0';
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    process (ACLK, RST) begin
        if (RST = '1') then
                O_IRQ <= '0';
        elsif (ACLK'event and ACLK = '1') then
            if (regs_rbit(O_MODE_DONE_IE_POS ) = '1' and regs_rbit(O_STAT_DONE_POS ) = '1') or
               (regs_rbit(O_MODE_ERROR_IE_POS) = '1' and regs_rbit(O_STAT_ERROR_POS) = '1') then
                O_IRQ <= '1';
            else
                O_IRQ <= '0';
            end if;
        end if;
    end process;
end RTL;

-----------------------------------------------------------------------------------
--!     @file    pump_axi4_to_axi4_test_bench.vhd
--!     @brief   Test Bench for Pump Sample Module (AXI4 to AXI4)
--!     @version 0.0.4
--!     @date    2013/1/7
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
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
entity  PUMP_AXI4_TO_AXI4_TEST_BENCH is
    generic (
        NAME            : STRING;
        SCENARIO_FILE   : STRING;
        I_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        O_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        MAX_XFER_SIZE   : integer                                :=  6
    );
end     PUMP_AXI4_TO_AXI4_TEST_BENCH;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     std.textio.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_MASTER_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SLAVE_PLAYER;
use     DUMMY_PLUG.AXI4_MODELS.AXI4_SIGNAL_PRINTER;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.CORE.MARCHAL;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.CORE.REPORT_STATUS_VECTOR;
use     DUMMY_PLUG.CORE.MARGE_REPORT_STATUS;
architecture MODEL of PUMP_AXI4_TO_AXI4_TEST_BENCH is
    -------------------------------------------------------------------------------
    -- 各種定数
    -------------------------------------------------------------------------------
    constant PERIOD          : time    := 10 ns;
    constant DELAY           : time    :=  1 ns;
    constant AXI4_ADDR_WIDTH : integer := 32;
    constant C_WIDTH         : AXI4_SIGNAL_WIDTH_TYPE := (
                                 ID          => 4,
                                 AWADDR      => AXI4_ADDR_WIDTH,
                                 ARADDR      => AXI4_ADDR_WIDTH,
                                 WDATA       => 32,
                                 RDATA       => 32,
                                 ARUSER      => 1,
                                 AWUSER      => 1,
                                 WUSER       => 1,
                                 RUSER       => 1,
                                 BUSER       => 1);
    constant I_WIDTH         : AXI4_SIGNAL_WIDTH_TYPE := (
                                 ID          => 4,
                                 AWADDR      => AXI4_ADDR_WIDTH,
                                 ARADDR      => AXI4_ADDR_WIDTH,
                                 WDATA       => I_DATA_WIDTH,
                                 RDATA       => I_DATA_WIDTH,
                                 ARUSER      => 1,
                                 AWUSER      => 1,
                                 WUSER       => 1,
                                 RUSER       => 1,
                                 BUSER       => 1);
    constant O_WIDTH         : AXI4_SIGNAL_WIDTH_TYPE := (
                                 ID          => 4,
                                 AWADDR      => AXI4_ADDR_WIDTH,
                                 ARADDR      => AXI4_ADDR_WIDTH,
                                 WDATA       => O_DATA_WIDTH,
                                 RDATA       => O_DATA_WIDTH,
                                 ARUSER      => 1,
                                 AWUSER      => 1,
                                 WUSER       => 1,
                                 RUSER       => 1,
                                 BUSER       => 1);
    constant I_AXI_ID        : integer :=  1;
    constant O_AXI_ID        : integer :=  2;
    constant BUF_DEPTH       : integer := 12;
    constant SYNC_WIDTH      : integer :=  2;
    constant GPO_WIDTH       : integer :=  8;
    constant GPI_WIDTH       : integer :=  GPO_WIDTH;
    -------------------------------------------------------------------------------
    -- グローバルシグナル.
    -------------------------------------------------------------------------------
    signal   ACLK            : std_logic;
    signal   ARESETn         : std_logic;
    signal   RESET           : std_logic;
    constant CLEAR           : std_logic := '0';
    ------------------------------------------------------------------------------
    -- CSR I/F リードアドレスチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   C_ARADDR        : std_logic_vector(C_WIDTH.ARADDR -1 downto 0);
    signal   C_ARWRITE       : std_logic;
    signal   C_ARLEN         : AXI4_ALEN_TYPE;
    signal   C_ARSIZE        : AXI4_ASIZE_TYPE;
    signal   C_ARBURST       : AXI4_ABURST_TYPE;
    signal   C_ARLOCK        : AXI4_ALOCK_TYPE;
    signal   C_ARCACHE       : AXI4_ACACHE_TYPE;
    signal   C_ARPROT        : AXI4_APROT_TYPE;
    signal   C_ARQOS         : AXI4_AQOS_TYPE;
    signal   C_ARREGION      : AXI4_AREGION_TYPE;
    signal   C_ARUSER        : std_logic_vector(C_WIDTH.ARUSER -1 downto 0);
    signal   C_ARID          : std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal   C_ARVALID       : std_logic;
    signal   C_ARREADY       : std_logic;
    signal   C_RVALID        : std_logic;
    signal   C_RLAST         : std_logic;
    signal   C_RDATA         : std_logic_vector(C_WIDTH.RDATA  -1 downto 0);
    signal   C_RRESP         : AXI4_RESP_TYPE;
    signal   C_RUSER         : std_logic_vector(C_WIDTH.RUSER  -1 downto 0);
    signal   C_RID           : std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal   C_RREADY        : std_logic;
    signal   C_AWADDR        : std_logic_vector(C_WIDTH.AWADDR -1 downto 0);
    signal   C_AWLEN         : AXI4_ALEN_TYPE;
    signal   C_AWSIZE        : AXI4_ASIZE_TYPE;
    signal   C_AWBURST       : AXI4_ABURST_TYPE;
    signal   C_AWLOCK        : AXI4_ALOCK_TYPE;
    signal   C_AWCACHE       : AXI4_ACACHE_TYPE;
    signal   C_AWPROT        : AXI4_APROT_TYPE;
    signal   C_AWQOS         : AXI4_AQOS_TYPE;
    signal   C_AWREGION      : AXI4_AREGION_TYPE;
    signal   C_AWUSER        : std_logic_vector(C_WIDTH.AWUSER -1 downto 0);
    signal   C_AWID          : std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal   C_AWVALID       : std_logic;
    signal   C_AWREADY       : std_logic;
    signal   C_WLAST         : std_logic;
    signal   C_WDATA         : std_logic_vector(C_WIDTH.WDATA  -1 downto 0);
    signal   C_WSTRB         : std_logic_vector(C_WIDTH.WDATA/8-1 downto 0);
    signal   C_WUSER         : std_logic_vector(C_WIDTH.WUSER  -1 downto 0);
    signal   C_WID           : std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal   C_WVALID        : std_logic;
    signal   C_WREADY        : std_logic;
    signal   C_BRESP         : AXI4_RESP_TYPE;
    signal   C_BUSER         : std_logic_vector(C_WIDTH.BUSER  -1 downto 0);
    signal   C_BID           : std_logic_vector(C_WIDTH.ID     -1 downto 0);
    signal   C_BVALID        : std_logic;
    signal   C_BREADY        : std_logic;
    ------------------------------------------------------------------------------
    -- IN I/F リードアドレスチャネルシグナル.
    ------------------------------------------------------------------------------
    signal   I_ARADDR        : std_logic_vector(I_WIDTH.ARADDR -1 downto 0);
    signal   I_ARWRITE       : std_logic;
    signal   I_ARLEN         : AXI4_ALEN_TYPE;
    signal   I_ARSIZE        : AXI4_ASIZE_TYPE;
    signal   I_ARBURST       : AXI4_ABURST_TYPE;
    signal   I_ARLOCK        : AXI4_ALOCK_TYPE;
    signal   I_ARCACHE       : AXI4_ACACHE_TYPE;
    signal   I_ARPROT        : AXI4_APROT_TYPE;
    signal   I_ARQOS         : AXI4_AQOS_TYPE;
    signal   I_ARREGION      : AXI4_AREGION_TYPE;
    signal   I_ARUSER        : std_logic_vector(I_WIDTH.ARUSER -1 downto 0);
    signal   I_ARID          : std_logic_vector(I_WIDTH.ID     -1 downto 0);
    signal   I_ARVALID       : std_logic;
    signal   I_ARREADY       : std_logic;
    signal   I_RVALID        : std_logic;
    signal   I_RLAST         : std_logic;
    signal   I_RDATA         : std_logic_vector(I_WIDTH.RDATA  -1 downto 0);
    signal   I_RRESP         : AXI4_RESP_TYPE;
    signal   I_RUSER         : std_logic_vector(I_WIDTH.RUSER  -1 downto 0);
    signal   I_RID           : std_logic_vector(I_WIDTH.ID     -1 downto 0);
    signal   I_RREADY        : std_logic;
    signal   I_AWADDR        : std_logic_vector(I_WIDTH.AWADDR -1 downto 0);
    signal   I_AWLEN         : AXI4_ALEN_TYPE;
    signal   I_AWSIZE        : AXI4_ASIZE_TYPE;
    signal   I_AWBURST       : AXI4_ABURST_TYPE;
    signal   I_AWLOCK        : AXI4_ALOCK_TYPE;
    signal   I_AWCACHE       : AXI4_ACACHE_TYPE;
    signal   I_AWPROT        : AXI4_APROT_TYPE;
    signal   I_AWQOS         : AXI4_AQOS_TYPE;
    signal   I_AWREGION      : AXI4_AREGION_TYPE;
    signal   I_AWUSER        : std_logic_vector(I_WIDTH.AWUSER -1 downto 0);
    signal   I_AWID          : std_logic_vector(I_WIDTH.ID     -1 downto 0);
    signal   I_AWVALID       : std_logic;
    signal   I_AWREADY       : std_logic;
    signal   I_WLAST         : std_logic;
    signal   I_WDATA         : std_logic_vector(I_WIDTH.WDATA  -1 downto 0);
    signal   I_WSTRB         : std_logic_vector(I_WIDTH.WDATA/8-1 downto 0);
    signal   I_WUSER         : std_logic_vector(I_WIDTH.WUSER  -1 downto 0);
    signal   I_WID           : std_logic_vector(I_WIDTH.ID     -1 downto 0);
    signal   I_WVALID        : std_logic;
    signal   I_WREADY        : std_logic;
    signal   I_BRESP         : AXI4_RESP_TYPE;
    signal   I_BUSER         : std_logic_vector(I_WIDTH.BUSER  -1 downto 0);
    signal   I_BID           : std_logic_vector(I_WIDTH.ID     -1 downto 0);
    signal   I_BVALID        : std_logic;
    signal   I_BREADY        : std_logic;
    -------------------------------------------------------------------------------
    -- OUT I/F ライトアドレスチャネルシグナル.
    -------------------------------------------------------------------------------
    signal   O_ARADDR        : std_logic_vector(O_WIDTH.ARADDR -1 downto 0);
    signal   O_ARWRITE       : std_logic;
    signal   O_ARLEN         : AXI4_ALEN_TYPE;
    signal   O_ARSIZE        : AXI4_ASIZE_TYPE;
    signal   O_ARBURST       : AXI4_ABURST_TYPE;
    signal   O_ARLOCK        : AXI4_ALOCK_TYPE;
    signal   O_ARCACHE       : AXI4_ACACHE_TYPE;
    signal   O_ARPROT        : AXI4_APROT_TYPE;
    signal   O_ARQOS         : AXI4_AQOS_TYPE;
    signal   O_ARREGION      : AXI4_AREGION_TYPE;
    signal   O_ARUSER        : std_logic_vector(O_WIDTH.ARUSER -1 downto 0);
    signal   O_ARID          : std_logic_vector(O_WIDTH.ID     -1 downto 0);
    signal   O_ARVALID       : std_logic;
    signal   O_ARREADY       : std_logic;
    signal   O_RVALID        : std_logic;
    signal   O_RLAST         : std_logic;
    signal   O_RDATA         : std_logic_vector(O_WIDTH.RDATA  -1 downto 0);
    signal   O_RRESP         : AXI4_RESP_TYPE;
    signal   O_RUSER         : std_logic_vector(O_WIDTH.RUSER  -1 downto 0);
    signal   O_RID           : std_logic_vector(O_WIDTH.ID     -1 downto 0);
    signal   O_RREADY        : std_logic;
    signal   O_AWADDR        : std_logic_vector(O_WIDTH.AWADDR -1 downto 0);
    signal   O_AWLEN         : AXI4_ALEN_TYPE;
    signal   O_AWSIZE        : AXI4_ASIZE_TYPE;
    signal   O_AWBURST       : AXI4_ABURST_TYPE;
    signal   O_AWLOCK        : AXI4_ALOCK_TYPE;
    signal   O_AWCACHE       : AXI4_ACACHE_TYPE;
    signal   O_AWPROT        : AXI4_APROT_TYPE;
    signal   O_AWQOS         : AXI4_AQOS_TYPE;
    signal   O_AWREGION      : AXI4_AREGION_TYPE;
    signal   O_AWUSER        : std_logic_vector(O_WIDTH.AWUSER -1 downto 0);
    signal   O_AWID          : std_logic_vector(O_WIDTH.ID     -1 downto 0);
    signal   O_AWVALID       : std_logic;
    signal   O_AWREADY       : std_logic;
    signal   O_WLAST         : std_logic;
    signal   O_WDATA         : std_logic_vector(O_WIDTH.WDATA  -1 downto 0);
    signal   O_WSTRB         : std_logic_vector(O_WIDTH.WDATA/8-1 downto 0);
    signal   O_WUSER         : std_logic_vector(O_WIDTH.WUSER  -1 downto 0);
    signal   O_WID           : std_logic_vector(O_WIDTH.ID     -1 downto 0);
    signal   O_WVALID        : std_logic;
    signal   O_WREADY        : std_logic;
    signal   O_BRESP         : AXI4_RESP_TYPE;
    signal   O_BUSER         : std_logic_vector(O_WIDTH.BUSER  -1 downto 0);
    signal   O_BID           : std_logic_vector(O_WIDTH.ID     -1 downto 0);
    signal   O_BVALID        : std_logic;
    signal   O_BREADY        : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    signal   I_IRQ           : std_logic;
    signal   O_IRQ           : std_logic;
    -------------------------------------------------------------------------------
    -- シンクロ用信号
    -------------------------------------------------------------------------------
    signal   SYNC            : SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
    -------------------------------------------------------------------------------
    -- GPIO(General Purpose Input/Output)
    -------------------------------------------------------------------------------
    signal   C_GPI           : std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal   C_GPO           : std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal   I_GPI           : std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal   I_GPO           : std_logic_vector(GPO_WIDTH    -1 downto 0);
    signal   O_GPI           : std_logic_vector(GPI_WIDTH    -1 downto 0);
    signal   O_GPO           : std_logic_vector(GPO_WIDTH    -1 downto 0);
    -------------------------------------------------------------------------------
    -- 各種状態出力.
    -------------------------------------------------------------------------------
    signal   N_REPORT        : REPORT_STATUS_TYPE;
    signal   C_REPORT        : REPORT_STATUS_TYPE;
    signal   I_REPORT        : REPORT_STATUS_TYPE;
    signal   O_REPORT        : REPORT_STATUS_TYPE;
    signal   N_FINISH        : std_logic;
    signal   C_FINISH        : std_logic;
    signal   I_FINISH        : std_logic;
    signal   O_FINISH        : std_logic;
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    component  PUMP_AXI4_TO_AXI4 
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
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
        ---------------------------------------------------------------------------
        -- 入出力ポートの定義.
        ---------------------------------------------------------------------------
        port(
            -----------------------------------------------------------------------
            -- Clock and Reset Signals.
            -----------------------------------------------------------------------
            ACLK            : in    std_logic;
            ARESETn         : in    std_logic;
            -----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Read Address Channel Signals.
            -----------------------------------------------------------------------
            C_ARID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_ARADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
            C_ARLEN         : in    AXI4_ALEN_TYPE;
            C_ARSIZE        : in    AXI4_ASIZE_TYPE;
            C_ARBURST       : in    AXI4_ABURST_TYPE;
            C_ARVALID       : in    std_logic;
            C_ARREADY       : out   std_logic;
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Read Data Channel Signals.
            ----------------------------------------------------------------------
            C_RID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_RDATA         : out   std_logic_vector(C_DATA_WIDTH  -1 downto 0);
            C_RRESP         : out   AXI4_RESP_TYPE;
            C_RLAST         : out   std_logic;
            C_RVALID        : out   std_logic;
            C_RREADY        : in    std_logic;
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Write Address Channel Signals.
            ----------------------------------------------------------------------
            C_AWID          : in    std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_AWADDR        : in    std_logic_vector(C_ADDR_WIDTH  -1 downto 0);
            C_AWLEN         : in    AXI4_ALEN_TYPE;
            C_AWSIZE        : in    AXI4_ASIZE_TYPE;
            C_AWBURST       : in    AXI4_ABURST_TYPE;
            C_AWVALID       : in    std_logic;
            C_AWREADY       : out   std_logic;
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Write Data Channel Signals.
            ----------------------------------------------------------------------
            C_WDATA         : in    std_logic_vector(C_DATA_WIDTH  -1 downto 0);
            C_WSTRB         : in    std_logic_vector(C_DATA_WIDTH/8-1 downto 0);
            C_WLAST         : in    std_logic;
            C_WVALID        : in    std_logic;
            C_WREADY        : out   std_logic;
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Write Response Channel Signals.
            ----------------------------------------------------------------------
            C_BID           : out   std_logic_vector(C_ID_WIDTH    -1 downto 0);
            C_BRESP         : out   AXI4_RESP_TYPE;
            C_BVALID        : out   std_logic;
            C_BREADY        : in    std_logic;
            ----------------------------------------------------------------------
            -- Input AXI4 Read Address Channel Signals.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- Input AXI4 Read Data Channel Signals.
            ----------------------------------------------------------------------
            I_RID           : in    std_logic_vector(I_ID_WIDTH    -1 downto 0);
            I_RDATA         : in    std_logic_vector(I_DATA_WIDTH  -1 downto 0);
            I_RRESP         : in    AXI4_RESP_TYPE;
            I_RLAST         : in    std_logic;
            I_RUSER         : in    std_logic_vector(I_RUSER_WIDTH -1 downto 0);
            I_RVALID        : in    std_logic;
            I_RREADY        : out   std_logic;
            ----------------------------------------------------------------------
            -- Output AXI4 Write Address Channel Signals.
            ----------------------------------------------------------------------
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
            ----------------------------------------------------------------------
            -- Output AXI4 Write Data Channel Signals.
            ----------------------------------------------------------------------
            O_WID           : out   std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_WDATA         : out   std_logic_vector(O_DATA_WIDTH  -1 downto 0);
            O_WSTRB         : out   std_logic_vector(O_DATA_WIDTH/8-1 downto 0);
            O_WUSER         : out   std_logic_vector(O_WUSER_WIDTH -1 downto 0);
            O_WLAST         : out   std_logic;
            O_WVALID        : out   std_logic;
            O_WREADY        : in    std_logic;
            ----------------------------------------------------------------------
            -- Output AXI4 Write Response Channel Signals.
            ----------------------------------------------------------------------
            O_BID           : in    std_logic_vector(O_ID_WIDTH    -1 downto 0);
            O_BRESP         : in    AXI4_RESP_TYPE;
            O_BUSER         : in    std_logic_vector(O_BUSER_WIDTH -1 downto 0);
            O_BVALID        : in    std_logic;
            O_BREADY        : out   std_logic;
            ----------------------------------------------------------------------
            -- 
            ----------------------------------------------------------------------
            I_IRQ           : out   std_logic;
            O_IRQ           : out   std_logic
        );
    end component;
begin
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    DUT: PUMP_AXI4_TO_AXI4 
        ---------------------------------------------------------------------------
        -- 
        ---------------------------------------------------------------------------
        generic map (
            C_ADDR_WIDTH    => C_WIDTH.AWADDR     ,
            C_DATA_WIDTH    => C_WIDTH.WDATA      ,
            C_ID_WIDTH      => C_WIDTH.ID         ,
            I_AXI_ID        => I_AXI_ID           ,
            I_ADDR_WIDTH    => I_WIDTH.ARADDR     ,
            I_DATA_WIDTH    => I_WIDTH.RDATA      ,
            I_ID_WIDTH      => I_WIDTH.ID         ,
            I_AUSER_WIDTH   => I_WIDTH.ARUSER     ,
            I_RUSER_WIDTH   => I_WIDTH.RUSER      ,
            I_MAX_XFER_SIZE => MAX_XFER_SIZE      ,
            O_AXI_ID        => O_AXI_ID           ,
            O_ADDR_WIDTH    => O_WIDTH.AWADDR     ,
            O_DATA_WIDTH    => O_WIDTH.WDATA      ,
            O_ID_WIDTH      => O_WIDTH.ID         ,
            O_AUSER_WIDTH   => O_WIDTH.AWUSER     ,
            O_WUSER_WIDTH   => O_WIDTH.WUSER      ,
            O_BUSER_WIDTH   => O_WIDTH.BUSER      ,
            O_MAX_XFER_SIZE => MAX_XFER_SIZE      ,
            BUF_DEPTH       => BUF_DEPTH          
        )
        ---------------------------------------------------------------------------
        -- 入出力ポートの定義.
        ---------------------------------------------------------------------------
        port map(
            -----------------------------------------------------------------------
            -- Clock and Reset Signals.
            -----------------------------------------------------------------------
            ACLK            => ACLK            , -- In :
            ARESETn         => ARESETn         , -- In :
            -----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Read Address Channel Signals.
            -----------------------------------------------------------------------
            C_ARID          => C_ARID          , -- In :
            C_ARADDR        => C_ARADDR        , -- In :
            C_ARLEN         => C_ARLEN         , -- In :
            C_ARSIZE        => C_ARSIZE        , -- In :
            C_ARBURST       => C_ARBURST       , -- In :
            C_ARVALID       => C_ARVALID       , -- In :
            C_ARREADY       => C_ARREADY       , -- Out:
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Read Data Channel Signals.
            ----------------------------------------------------------------------
            C_RID           => C_RID           , -- Out:
            C_RDATA         => C_RDATA         , -- Out:
            C_RRESP         => C_RRESP         , -- Out:
            C_RLAST         => C_RLAST         , -- Out:
            C_RVALID        => C_RVALID        , -- Out:
            C_RREADY        => C_RREADY        , -- In :
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Write Address Channel Signals.
            ----------------------------------------------------------------------
            C_AWID          => C_AWID          , -- In :
            C_AWADDR        => C_AWADDR        , -- In :
            C_AWLEN         => C_AWLEN         , -- In :
            C_AWSIZE        => C_AWSIZE        , -- In :
            C_AWBURST       => C_AWBURST       , -- In :
            C_AWVALID       => C_AWVALID       , -- In :
            C_AWREADY       => C_AWREADY       , -- Out:
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Write Data Channel Signals.
            ----------------------------------------------------------------------
            C_WDATA         => C_WDATA         , -- In :
            C_WSTRB         => C_WSTRB         , -- In :
            C_WLAST         => C_WLAST         , -- In :
            C_WVALID        => C_WVALID        , -- In :
            C_WREADY        => C_WREADY        , -- Out:
            ----------------------------------------------------------------------
            -- Control Status Register I/F AXI4 Write Response Channel Signals.
            ----------------------------------------------------------------------
            C_BID           => C_BID           , -- Out:
            C_BRESP         => C_BRESP         , -- Out:
            C_BVALID        => C_BVALID        , -- Out:
            C_BREADY        => C_BREADY        , -- In :
            ----------------------------------------------------------------------
            -- Input AXI4 Read Address Channel Signals.
            ----------------------------------------------------------------------
            I_ARID          => I_ARID          , -- Out:
            I_ARADDR        => I_ARADDR        , -- Out:
            I_ARLEN         => I_ARLEN         , -- Out:
            I_ARSIZE        => I_ARSIZE        , -- Out:
            I_ARBURST       => I_ARBURST       , -- Out:
            I_ARLOCK        => I_ARLOCK        , -- Out:
            I_ARCACHE       => I_ARCACHE       , -- Out:
            I_ARPROT        => I_ARPROT        , -- Out:
            I_ARQOS         => I_ARQOS         , -- Out:
            I_ARREGION      => I_ARREGION      , -- Out:
            I_ARUSER        => I_ARUSER        , -- Out:
            I_ARVALID       => I_ARVALID       , -- Out:
            I_ARREADY       => I_ARREADY       , -- In :
            ----------------------------------------------------------------------
            -- Input AXI4 Read Data Channel Signals.
            ----------------------------------------------------------------------
            I_RID           => I_RID           , -- In :
            I_RDATA         => I_RDATA         , -- In :
            I_RRESP         => I_RRESP         , -- In :
            I_RLAST         => I_RLAST         , -- In :
            I_RUSER         => I_RUSER         , -- In :
            I_RVALID        => I_RVALID        , -- In :
            I_RREADY        => I_RREADY        , -- Out:
            ----------------------------------------------------------------------
            -- Output AXI4 Write Address Channel Signals.
            ----------------------------------------------------------------------
            O_AWID          => O_AWID          , -- Out:
            O_AWADDR        => O_AWADDR        , -- Out:
            O_AWLEN         => O_AWLEN         , -- Out:
            O_AWSIZE        => O_AWSIZE        , -- Out:
            O_AWBURST       => O_AWBURST       , -- Out:
            O_AWLOCK        => O_AWLOCK        , -- Out:
            O_AWCACHE       => O_AWCACHE       , -- Out:
            O_AWPROT        => O_AWPROT        , -- Out:
            O_AWQOS         => O_AWQOS         , -- Out:
            O_AWREGION      => O_AWREGION      , -- Out:
            O_AWUSER        => O_AWUSER        , -- Out:
            O_AWVALID       => O_AWVALID       , -- Out:
            O_AWREADY       => O_AWREADY       , -- In :
            ----------------------------------------------------------------------
            -- Output AXI4 Write Data Channel Signals.
            ----------------------------------------------------------------------
            O_WID           => O_WID           , -- Out:
            O_WDATA         => O_WDATA         , -- Out:
            O_WSTRB         => O_WSTRB         , -- Out:
            O_WUSER         => O_WUSER         , -- Out:
            O_WLAST         => O_WLAST         , -- Out:
            O_WVALID        => O_WVALID        , -- Out:
            O_WREADY        => O_WREADY        , -- In :
            ----------------------------------------------------------------------
            -- Output AXI4 Write Response Channel Signals.
            ----------------------------------------------------------------------
            O_BID           => O_BID           , -- In :
            O_BRESP         => O_BRESP         , -- In :
            O_BUSER         => O_BUSER         , -- In :
            O_BVALID        => O_BVALID        , -- In :
            O_BREADY        => O_BREADY        , -- Out:
            ----------------------------------------------------------------------
            -- 
            ----------------------------------------------------------------------
            I_IRQ           => I_IRQ           ,  -- Out:
            O_IRQ           => O_IRQ              -- Out:
        );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    N: MARCHAL
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE,
            NAME            => "MARCHAL",
            SYNC_PLUG_NUM   => 1,
            SYNC_WIDTH      => SYNC_WIDTH,
            FINISH_ABORT    => FALSE
        )
        port map(
            CLK             => ACLK            , -- In  :
            RESET           => RESET           , -- In  :
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
            REPORT_STATUS   => N_REPORT        , -- Out :
            FINISH          => N_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_MASTER_PLAYER
    ------------------------------------------------------------------------------
    C: AXI4_MASTER_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "CSR"           ,
            READ_ENABLE     => TRUE            ,
            WRITE_ENABLE    => TRUE            ,
            OUTPUT_DELAY    => DELAY           ,
            WIDTH           => C_WIDTH         ,
            SYNC_PLUG_NUM   => 2               ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => C_ARADDR        , -- I/O : 
            ARLEN           => C_ARLEN         , -- I/O : 
            ARSIZE          => C_ARSIZE        , -- I/O : 
            ARBURST         => C_ARBURST       , -- I/O : 
            ARLOCK          => C_ARLOCK        , -- I/O : 
            ARCACHE         => C_ARCACHE       , -- I/O : 
            ARPROT          => C_ARPROT        , -- I/O : 
            ARQOS           => C_ARQOS         , -- I/O : 
            ARREGION        => C_ARREGION      , -- I/O : 
            ARUSER          => C_ARUSER        , -- I/O : 
            ARID            => C_ARID          , -- I/O : 
            ARVALID         => C_ARVALID       , -- I/O : 
            ARREADY         => C_ARREADY       , -- In  :    
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => C_RLAST         , -- In  :    
            RDATA           => C_RDATA         , -- In  :    
            RRESP           => C_RRESP         , -- In  :    
            RUSER           => C_RUSER         , -- In  :    
            RID             => C_RID           , -- In  :    
            RVALID          => C_RVALID        , -- In  :    
            RREADY          => C_RREADY        , -- I/O : 
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
            AWADDR          => C_AWADDR        , -- I/O : 
            AWLEN           => C_AWLEN         , -- I/O : 
            AWSIZE          => C_AWSIZE        , -- I/O : 
            AWBURST         => C_AWBURST       , -- I/O : 
            AWLOCK          => C_AWLOCK        , -- I/O : 
            AWCACHE         => C_AWCACHE       , -- I/O : 
            AWPROT          => C_AWPROT        , -- I/O : 
            AWQOS           => C_AWQOS         , -- I/O : 
            AWREGION        => C_AWREGION      , -- I/O : 
            AWUSER          => C_AWUSER        , -- I/O : 
            AWID            => C_AWID          , -- I/O : 
            AWVALID         => C_AWVALID       , -- I/O : 
            AWREADY         => C_AWREADY       , -- In  :    
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
            WLAST           => C_WLAST         , -- I/O : 
            WDATA           => C_WDATA         , -- I/O : 
            WSTRB           => C_WSTRB         , -- I/O : 
            WUSER           => C_WUSER         , -- I/O : 
            WID             => C_WID           , -- I/O : 
            WVALID          => C_WVALID        , -- I/O : 
            WREADY          => C_WREADY        , -- In  :    
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => C_BRESP         , -- In  :    
            BUSER           => C_BUSER         , -- In  :    
            BID             => C_BID           , -- In  :    
            BVALID          => C_BVALID        , -- In  :    
            BREADY          => C_BREADY        , -- I/O : 
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => C_GPI           , -- In  :
            GPO             => C_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => C_REPORT        , -- Out :
            FINISH          => C_FINISH          -- Out :
        );
    ------------------------------------------------------------------------------
    -- AXI4_SLAVE_PLAYER
    ------------------------------------------------------------------------------
    I: AXI4_SLAVE_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "I"             ,
            READ_ENABLE     => TRUE            ,
            WRITE_ENABLE    => FALSE           ,
            OUTPUT_DELAY    => DELAY           ,
            WIDTH           => I_WIDTH         ,
            SYNC_PLUG_NUM   => 3               ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => I_ARADDR        , -- In  :    
            ARLEN           => I_ARLEN         , -- In  :    
            ARSIZE          => I_ARSIZE        , -- In  :    
            ARBURST         => I_ARBURST       , -- In  :    
            ARLOCK          => I_ARLOCK        , -- In  :    
            ARCACHE         => I_ARCACHE       , -- In  :    
            ARPROT          => I_ARPROT        , -- In  :    
            ARQOS           => I_ARQOS         , -- In  :    
            ARREGION        => I_ARREGION      , -- In  :    
            ARUSER          => I_ARUSER        , -- In  :    
            ARID            => I_ARID          , -- In  :    
            ARVALID         => I_ARVALID       , -- In  :    
            ARREADY         => I_ARREADY       , -- I/O : 
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => I_RLAST         , -- I/O : 
            RDATA           => I_RDATA         , -- I/O : 
            RRESP           => I_RRESP         , -- I/O : 
            RUSER           => I_RUSER         , -- I/O : 
            RID             => I_RID           , -- I/O : 
            RVALID          => I_RVALID        , -- I/O : 
            RREADY          => I_RREADY        , -- In  :    
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            AWADDR          => I_AWADDR        , -- In  :    
            AWLEN           => I_AWLEN         , -- In  :    
            AWSIZE          => I_AWSIZE        , -- In  :    
            AWBURST         => I_AWBURST       , -- In  :    
            AWLOCK          => I_AWLOCK        , -- In  :    
            AWCACHE         => I_AWCACHE       , -- In  :    
            AWPROT          => I_AWPROT        , -- In  :    
            AWQOS           => I_AWQOS         , -- In  :    
            AWREGION        => I_AWREGION      , -- In  :    
            AWUSER          => I_AWUSER        , -- In  :    
            AWID            => I_AWID          , -- In  :    
            AWVALID         => I_AWVALID       , -- In  :    
            AWREADY         => I_AWREADY       , -- I/O : 
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
            WLAST           => I_WLAST         , -- In  :    
            WDATA           => I_WDATA         , -- In  :    
            WSTRB           => I_WSTRB         , -- In  :    
            WUSER           => I_WUSER         , -- In  :    
            WID             => I_WID           , -- In  :    
            WVALID          => I_WVALID        , -- In  :    
            WREADY          => I_WREADY        , -- I/O : 
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => I_BRESP         , -- I/O : 
            BUSER           => I_BUSER         , -- I/O : 
            BID             => I_BID           , -- I/O : 
            BVALID          => I_BVALID        , -- I/O : 
            BREADY          => I_BREADY        , -- In  :    
        ---------------------------------------------------------------------------
        -- シンクロ用信号
        ---------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => I_GPI           , -- In  :
            GPO             => I_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => I_REPORT        , -- Out :
            FINISH          => I_FINISH          -- Out :
    );
    ------------------------------------------------------------------------------
    -- AXI4_SLAVE_PLAYER
    ------------------------------------------------------------------------------
    O: AXI4_SLAVE_PLAYER
        generic map (
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => "O"             ,
            READ_ENABLE     => FALSE           ,
            WRITE_ENABLE    => TRUE            ,
            OUTPUT_DELAY    => DELAY           ,
            WIDTH           => O_WIDTH         ,
            SYNC_PLUG_NUM   => 3               ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FALSE
        )
        port map(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
            ACLK            => ACLK            , -- In  :
            ARESETn         => ARESETn         , -- In  :
        ---------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            ARADDR          => O_ARADDR        , -- In  :    
            ARLEN           => O_ARLEN         , -- In  :    
            ARSIZE          => O_ARSIZE        , -- In  :    
            ARBURST         => O_ARBURST       , -- In  :    
            ARLOCK          => O_ARLOCK        , -- In  :    
            ARCACHE         => O_ARCACHE       , -- In  :    
            ARPROT          => O_ARPROT        , -- In  :    
            ARQOS           => O_ARQOS         , -- In  :    
            ARREGION        => O_ARREGION      , -- In  :    
            ARUSER          => O_ARUSER        , -- In  :    
            ARID            => O_ARID          , -- In  :    
            ARVALID         => O_ARVALID       , -- In  :    
            ARREADY         => O_ARREADY       , -- I/O : 
        ---------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        ---------------------------------------------------------------------------
            RLAST           => O_RLAST         , -- I/O : 
            RDATA           => O_RDATA         , -- I/O : 
            RRESP           => O_RRESP         , -- I/O : 
            RUSER           => O_RUSER         , -- I/O : 
            RID             => O_RID           , -- I/O : 
            RVALID          => O_RVALID        , -- I/O : 
            RREADY          => O_RREADY        , -- In  :    
        ---------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        ---------------------------------------------------------------------------
            AWADDR          => O_AWADDR        , -- In  :    
            AWLEN           => O_AWLEN         , -- In  :    
            AWSIZE          => O_AWSIZE        , -- In  :    
            AWBURST         => O_AWBURST       , -- In  :    
            AWLOCK          => O_AWLOCK        , -- In  :    
            AWCACHE         => O_AWCACHE       , -- In  :    
            AWPROT          => O_AWPROT        , -- In  :    
            AWQOS           => O_AWQOS         , -- In  :    
            AWREGION        => O_AWREGION      , -- In  :    
            AWUSER          => O_AWUSER        , -- In  :    
            AWID            => O_AWID          , -- In  :    
            AWVALID         => O_AWVALID       , -- In  :    
            AWREADY         => O_AWREADY       , -- I/O : 
        ---------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        ---------------------------------------------------------------------------
            WLAST           => O_WLAST         , -- In  :    
            WDATA           => O_WDATA         , -- In  :    
            WSTRB           => O_WSTRB         , -- In  :    
            WUSER           => O_WUSER         , -- In  :    
            WID             => O_WID           , -- In  :    
            WVALID          => O_WVALID        , -- In  :    
            WREADY          => O_WREADY        , -- I/O : 
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
            BRESP           => O_BRESP         , -- I/O : 
            BUSER           => O_BUSER         , -- I/O : 
            BID             => O_BID           , -- I/O : 
            BVALID          => O_BVALID        , -- I/O : 
            BREADY          => O_BREADY        , -- In  :    
        ---------------------------------------------------------------------------
        -- シンクロ用信号
        ---------------------------------------------------------------------------
            SYNC(0)         => SYNC(0)         , -- I/O :
            SYNC(1)         => SYNC(1)         , -- I/O :
        --------------------------------------------------------------------------
        -- GPIO
        --------------------------------------------------------------------------
            GPI             => O_GPI           , -- In  :
            GPO             => O_GPO           , -- Out :
        --------------------------------------------------------------------------
        -- 各種状態出力.
        --------------------------------------------------------------------------
            REPORT_STATUS   => O_REPORT        , -- Out :
            FINISH          => O_FINISH          -- Out :
    );
    -------------------------------------------------------------------------------
    -- 
    -------------------------------------------------------------------------------
    process begin
        ACLK <= '0';
        wait for PERIOD / 2;
        ACLK <= '1';
        wait for PERIOD / 2;
    end process;

    ARESETn  <= '1' when (RESET = '0') else '0';
    C_GPI(0) <= I_IRQ;
    C_GPI(1) <= O_IRQ;
    C_GPI(C_GPI'high downto 2) <= (C_GPI'high downto 2 => '0');
    I_GPI    <= (others => '0');
    O_GPI    <= (others => '0');
    process
        variable L   : LINE;
        constant T   : STRING(1 to 7) := "  ***  ";
    begin
        wait until (C_FINISH'event and C_FINISH = '1');
        wait for DELAY;
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "ERROR REPORT " & NAME);                          WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ CSR ]");                                       WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,C_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,C_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,C_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ IN ]");                                        WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,I_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,I_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,I_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        WRITE(L,T & "[ OUT ]");                                       WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Error    : ");WRITE(L,O_REPORT.error_count   );WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Mismatch : ");WRITE(L,O_REPORT.mismatch_count);WRITELINE(OUTPUT,L);
        WRITE(L,T & "  Warning  : ");WRITE(L,O_REPORT.warning_count );WRITELINE(OUTPUT,L);
        WRITE(L,T);                                                   WRITELINE(OUTPUT,L);
        assert FALSE report "Simulation complete." severity FAILURE;
        wait;
    end process;
    
 -- SYNC_PRINT_0: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(0)")) port map (SYNC(0));
 -- SYNC_PRINT_1: SYNC_PRINT generic map(string'("AXI4_TEST_1:SYNC(1)")) port map (SYNC(1));
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------

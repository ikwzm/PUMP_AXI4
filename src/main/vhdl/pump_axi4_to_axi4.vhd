-----------------------------------------------------------------------------------
--!     @file    pump_axi4_to_axi4.vhd
--!     @brief   Pump Sample Module (AXI4 to AXI4)
--!     @version 0.0.8
--!     @date    2013/1/15
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
        I_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        I_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        I_ID_WIDTH      : integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
        I_AUSER_WIDTH   : integer range 1 to 32                  :=  4;
        I_RUSER_WIDTH   : integer range 1 to 32                  :=  4;
        O_ADDR_WIDTH    : integer range 1 to AXI4_ADDR_MAX_WIDTH := 32;
        O_DATA_WIDTH    : integer range 8 to AXI4_DATA_MAX_WIDTH := 32;
        O_ID_WIDTH      : integer range 1 to AXI4_ID_MAX_WIDTH   := AXI4_ID_MAX_WIDTH;
        O_AUSER_WIDTH   : integer range 1 to 32                  :=  4;
        O_WUSER_WIDTH   : integer range 1 to 32                  :=  4;
        O_BUSER_WIDTH   : integer range 1 to 32                  :=  4;
        I_AXI_ID        : integer                                :=  1;
        O_AXI_ID        : integer                                :=  2;
        BUF_DEPTH       : integer                                := 12;
        MAX_XFER_SIZE   : integer                                :=  8
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
use     PIPEWORK.PUMP_COMPONENTS.PUMP_COUNT_UP_REGISTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_COUNT_DOWN_REGISTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_CONTROL_REGISTER;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_INTAKE_VALVE;
use     PIPEWORK.PUMP_COMPONENTS.PUMP_OUTLET_VALVE;
architecture RTL of PUMP_AXI4_TO_AXI4 is
    ------------------------------------------------------------------------------
    -- リセット信号.
    ------------------------------------------------------------------------------
    signal   RST                : std_logic;
    constant CLR                : std_logic := '0';
    -------------------------------------------------------------------------------
    -- データバスのバイト数の２のべき乗値を計算する.
    -------------------------------------------------------------------------------
    function CALC_DATA_SIZE(WIDTH:integer) return integer is
        variable value : integer;
    begin
        value := 0;
        while (2**(value) < WIDTH) loop
            value := value + 1;
        end loop;
        return value;
    end function;
    ------------------------------------------------------------------------------
    -- アドレスレジスタのビット数.
    ------------------------------------------------------------------------------
    constant ADDR_REGS_BITS     : integer := 64;
    ------------------------------------------------------------------------------
    -- サイズレジスタのビット数.
    ------------------------------------------------------------------------------
    constant SIZE_REGS_BITS     : integer := 32;
    ------------------------------------------------------------------------------
    -- 各種サイズカウンタのビット数.
    ------------------------------------------------------------------------------
    constant SIZE_BITS          : integer := BUF_DEPTH+1;
    ------------------------------------------------------------------------------
    -- 最大転送バイト数.
    ------------------------------------------------------------------------------
    constant MAX_XFER_BYTES     : integer := 2**MAX_XFER_SIZE;
    ------------------------------------------------------------------------------
    -- バッファデータのビット幅.
    ------------------------------------------------------------------------------
    function MAX(A,B:integer) return integer is begin
        if (A > B) then return A;
        else            return B;
        end if;
    end function;
    constant BUF_DATA_WIDTH     : integer := MAX(O_DATA_WIDTH,I_DATA_WIDTH);
    ------------------------------------------------------------------------------
    -- バッファデータのバイト数(２のべき乗値).
    ------------------------------------------------------------------------------
    constant BUF_DATA_SIZE      : integer := CALC_DATA_SIZE(BUF_DATA_WIDTH);
    ------------------------------------------------------------------------------
    -- バッファのバイト数.
    ------------------------------------------------------------------------------
    constant BUF_BYTES          : std_logic_vector(SIZE_BITS-1 downto 0) := 
                                  std_logic_vector(to_unsigned(2**BUF_DEPTH  , SIZE_BITS));
    ------------------------------------------------------------------------------
    -- 入力側の閾値. フローカウンタがこの値以下の時に入力する.
    ------------------------------------------------------------------------------
    constant I_THRESHOLD_SIZE   : std_logic_vector(SIZE_BITS-1 downto 0) :=
                                  std_logic_vector(to_unsigned(2**BUF_DEPTH-MAX_XFER_BYTES, SIZE_BITS));
    ------------------------------------------------------------------------------
    -- 出力側の閾値. フローカウンタがこの値以上の時に出力する.
    ------------------------------------------------------------------------------
    constant O_THRESHOLD_SIZE   : std_logic_vector(SIZE_BITS-1 downto 0) :=
                                  std_logic_vector(to_unsigned(MAX_XFER_BYTES, SIZE_BITS));
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
    ------------------------------------------------------------------------------
    -- 入力側の各種定数.
    ------------------------------------------------------------------------------
    constant I_ID               : std_logic_vector(I_ID_WIDTH       -1 downto 0) :=
                                  std_logic_vector(to_unsigned(I_AXI_ID, I_ID_WIDTH));
    constant I_BURST_TYPE       : AXI4_ABURST_TYPE := AXI4_ABURST_INCR;
    constant I_LOCK             : AXI4_ALOCK_TYPE  := (others => '0');
    constant I_CACHE            : AXI4_ACACHE_TYPE := (others => '0');
    constant I_PROT             : AXI4_APROT_TYPE  := (others => '0');
    constant I_QOS              : AXI4_AQOS_TYPE   := (others => '0');
    constant I_REGION           : AXI4_AREGION_TYPE:= (others => '0');
    constant I_XFER_SIZE_SEL    : std_logic_vector(MAX_XFER_SIZE downto MAX_XFER_SIZE) := "1";
    constant I_SPECULATIVE      : std_logic        := '1';
    constant I_SAFETY           : std_logic        := '0';
    ------------------------------------------------------------------------------
    -- 入力側の各種信号群.
    ------------------------------------------------------------------------------
    signal   i_addr_up_ben      : std_logic_vector(I_ADDR_WIDTH     -1 downto 0);
    signal   i_req_addr         : std_logic_vector(I_ADDR_WIDTH     -1 downto 0);
    signal   i_req_size         : std_logic_vector(SIZE_REGS_BITS   -1 downto 0);
    signal   i_req_buf_ptr      : std_logic_vector(BUF_DEPTH        -1 downto 0);
    signal   i_req_first        : std_logic;
    signal   i_req_last         : std_logic;
    signal   i_req_valid        : std_logic;
    signal   i_req_ready        : std_logic;
    signal   i_xfer_busy        : std_logic;
    signal   i_ack_valid        : std_logic;
    signal   i_ack_error        : std_logic;
    signal   i_ack_next         : std_logic;
    signal   i_ack_last         : std_logic;
    signal   i_ack_stop         : std_logic;
    signal   i_ack_none         : std_logic;
    signal   i_ack_size         : std_logic_vector(SIZE_BITS        -1 downto 0);
    signal   i_flow_pause       : std_logic;
    signal   i_flow_stop        : std_logic;
    signal   i_flow_last        : std_logic;
    signal   i_flow_size        : std_logic_vector(SIZE_BITS        -1 downto 0);
    signal   i_open             : std_logic;
    signal   i_running          : std_logic;
    signal   i_done             : std_logic;
    signal   i_stat_in          : std_logic_vector(5 downto 0);
    ------------------------------------------------------------------------------
    -- 出力側の各種定数.
    ------------------------------------------------------------------------------
    constant O_ID               : std_logic_vector(O_ID_WIDTH       -1 downto 0) := 
                                  std_logic_vector(to_unsigned(O_AXI_ID, O_ID_WIDTH));
    constant O_BURST_TYPE       : AXI4_ABURST_TYPE := AXI4_ABURST_INCR;
    constant O_LOCK             : AXI4_ALOCK_TYPE  := (others => '0');
    constant O_CACHE            : AXI4_ACACHE_TYPE := (others => '0');
    constant O_PROT             : AXI4_APROT_TYPE  := (others => '0');
    constant O_QOS              : AXI4_AQOS_TYPE   := (others => '0');
    constant O_REGION           : AXI4_AREGION_TYPE:= (others => '0');
    constant O_XFER_SIZE_SEL    : std_logic_vector(MAX_XFER_SIZE downto MAX_XFER_SIZE) := "1";
    constant O_SPECULATIVE      : std_logic        := '1';
    constant O_SAFETY           : std_logic        := '0';
    ------------------------------------------------------------------------------
    -- 出力側の各種信号群.
    ------------------------------------------------------------------------------
    signal   o_addr_up_ben      : std_logic_vector(I_ADDR_WIDTH     -1 downto 0);
    signal   o_req_addr         : std_logic_vector(I_ADDR_WIDTH     -1 downto 0);
    signal   o_req_size         : std_logic_vector(SIZE_REGS_BITS   -1 downto 0);
    signal   o_req_buf_ptr      : std_logic_vector(BUF_DEPTH        -1 downto 0);
    signal   o_req_first        : std_logic;
    signal   o_req_last         : std_logic;
    signal   o_req_valid        : std_logic;
    signal   o_req_ready        : std_logic;
    signal   o_xfer_busy        : std_logic;
    signal   o_ack_valid        : std_logic;
    signal   o_ack_error        : std_logic;
    signal   o_ack_next         : std_logic;
    signal   o_ack_last         : std_logic;
    signal   o_ack_stop         : std_logic;
    signal   o_ack_none         : std_logic;
    signal   o_ack_size         : std_logic_vector(SIZE_BITS        -1 downto 0);
    signal   o_flow_pause       : std_logic;
    signal   o_flow_stop        : std_logic;
    signal   o_flow_last        : std_logic;
    signal   o_flow_size        : std_logic_vector(SIZE_BITS        -1 downto 0);
    signal   o_open             : std_logic;
    signal   o_running          : std_logic;
    signal   o_done             : std_logic;
    signal   o_stat_in          : std_logic_vector(5 downto 0);
    ------------------------------------------------------------------------------
    -- フローカウンタ制御用信号群.
    ------------------------------------------------------------------------------
    signal   push_valid         : std_logic;
    signal   push_error         : std_logic;
    signal   push_last          : std_logic;
    signal   push_size          : std_logic_vector(SIZE_BITS        -1 downto 0);
    signal   pull_valid         : std_logic;
    signal   pull_error         : std_logic;
    signal   pull_last          : std_logic;
    signal   pull_size          : std_logic_vector(SIZE_BITS        -1 downto 0);
    ------------------------------------------------------------------------------
    -- バッファへのアクセス用信号群.
    ------------------------------------------------------------------------------
    constant BUF_INIT_PTR       : std_logic_vector(BUF_DEPTH        -1 downto 0) := (others => '0');
    constant BUF_UP_BEN         : std_logic_vector(BUF_DEPTH        -1 downto 0) := (others => '1');
    signal   i_buf_ptr_init     : std_logic_vector(BUF_DEPTH        -1 downto 0);
    signal   o_buf_ptr_init     : std_logic_vector(BUF_DEPTH        -1 downto 0);
    signal   buf_wdata          : std_logic_vector(BUF_DATA_WIDTH   -1 downto 0);
    signal   buf_ben            : std_logic_vector(BUF_DATA_WIDTH/8 -1 downto 0);
    signal   buf_we             : std_logic_vector(BUF_DATA_WIDTH/8 -1 downto 0);
    signal   buf_wptr           : std_logic_vector(BUF_DEPTH        -1 downto 0);
    signal   buf_wen            : std_logic;
    constant buf_wready         : std_logic := '1';
    signal   buf_rdata          : std_logic_vector(BUF_DATA_WIDTH   -1 downto 0);
    signal   buf_rptr           : std_logic_vector(BUF_DEPTH        -1 downto 0);
    constant buf_rready         : std_logic := '1';
    ------------------------------------------------------------------------------
    -- レジスタのアドレスマップ.
    ------------------------------------------------------------------------------
    constant O_ADDR_REGS_ADDR   : integer := 16#00#;
    constant O_SIZE_REGS_ADDR   : integer := 16#08#;
    constant O_CTRL_REGS_ADDR   : integer := 16#0C#;
    constant I_ADDR_REGS_ADDR   : integer := 16#10#;
    constant I_SIZE_REGS_ADDR   : integer := 16#18#;
    constant I_CTRL_REGS_ADDR   : integer := 16#1C#;
    constant O_ADDR_REGS_LO     : integer := 8*O_ADDR_REGS_ADDR;
    constant O_ADDR_REGS_HI     : integer := 8*O_ADDR_REGS_ADDR + ADDR_REGS_BITS-1;
    constant O_SIZE_REGS_LO     : integer := 8*O_SIZE_REGS_ADDR;
    constant O_SIZE_REGS_HI     : integer := 8*O_SIZE_REGS_ADDR + SIZE_REGS_BITS-1;
    constant O_CTRL_MODE_LO     : integer := 8*O_CTRL_REGS_ADDR +  0;
    constant O_CTRL_MODE_HI     : integer := 8*O_CTRL_REGS_ADDR + 15;
    constant O_CTRL_DONE_POS    : integer := 8*O_CTRL_REGS_ADDR + 16;
    constant O_CTRL_ERROR_POS   : integer := 8*O_CTRL_REGS_ADDR + 17;
    constant O_CTRL_STAT_LO     : integer := 8*O_CTRL_REGS_ADDR + 18;
    constant O_CTRL_STAT_HI     : integer := 8*O_CTRL_REGS_ADDR + 23;
    constant O_CTRL_START_POS   : integer := 8*O_CTRL_REGS_ADDR + 24;
    constant O_CTRL_FIRST_POS   : integer := 8*O_CTRL_REGS_ADDR + 25;
    constant O_CTRL_LAST_POS    : integer := 8*O_CTRL_REGS_ADDR + 26;
    constant O_CTRL_EVREQ_POS   : integer := 8*O_CTRL_REGS_ADDR + 27;
    constant O_CTRL_RESV_POS    : integer := 8*O_CTRL_REGS_ADDR + 28;
    constant O_CTRL_STOP_POS    : integer := 8*O_CTRL_REGS_ADDR + 29;
    constant O_CTRL_PAUSE_POS   : integer := 8*O_CTRL_REGS_ADDR + 30;
    constant O_CTRL_RESET_POS   : integer := 8*O_CTRL_REGS_ADDR + 31;
    constant I_ADDR_REGS_LO     : integer := 8*I_ADDR_REGS_ADDR;
    constant I_ADDR_REGS_HI     : integer := 8*I_ADDR_REGS_ADDR + ADDR_REGS_BITS-1;
    constant I_SIZE_REGS_LO     : integer := 8*I_SIZE_REGS_ADDR;
    constant I_SIZE_REGS_HI     : integer := 8*I_SIZE_REGS_ADDR + SIZE_REGS_BITS-1;
    constant I_CTRL_MODE_LO     : integer := 8*I_CTRL_REGS_ADDR +  0;
    constant I_CTRL_MODE_HI     : integer := 8*I_CTRL_REGS_ADDR + 15;
    constant I_CTRL_DONE_POS    : integer := 8*I_CTRL_REGS_ADDR + 16;
    constant I_CTRL_ERROR_POS   : integer := 8*I_CTRL_REGS_ADDR + 17;
    constant I_CTRL_STAT_LO     : integer := 8*I_CTRL_REGS_ADDR + 18;
    constant I_CTRL_STAT_HI     : integer := 8*I_CTRL_REGS_ADDR + 23;
    constant I_CTRL_START_POS   : integer := 8*I_CTRL_REGS_ADDR + 24;
    constant I_CTRL_FIRST_POS   : integer := 8*I_CTRL_REGS_ADDR + 25;
    constant I_CTRL_LAST_POS    : integer := 8*I_CTRL_REGS_ADDR + 26;
    constant I_CTRL_EVREQ_POS   : integer := 8*I_CTRL_REGS_ADDR + 27;
    constant I_CTRL_RESV_POS    : integer := 8*I_CTRL_REGS_ADDR + 28;
    constant I_CTRL_STOP_POS    : integer := 8*I_CTRL_REGS_ADDR + 29;
    constant I_CTRL_PAUSE_POS   : integer := 8*I_CTRL_REGS_ADDR + 30;
    constant I_CTRL_RESET_POS   : integer := 8*I_CTRL_REGS_ADDR + 31;
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
    I_IF: AXI4_MASTER_READ_INTERFACE
        generic map (
            AXI4_ADDR_WIDTH => I_ADDR_WIDTH    ,
            AXI4_DATA_WIDTH => I_DATA_WIDTH    ,
            AXI4_ID_WIDTH   => I_ID_WIDTH      ,
            VAL_BITS        => 1               ,
            SIZE_BITS       => SIZE_BITS       ,
            REQ_SIZE_BITS   => SIZE_REGS_BITS  ,
            REQ_SIZE_VALID  => 1               ,
            FLOW_VALID      => 1               ,
            BUF_DATA_WIDTH  => BUF_DATA_WIDTH  ,
            BUF_PTR_BITS    => BUF_DEPTH       ,
            XFER_MIN_SIZE   => MAX_XFER_SIZE   ,
            XFER_MAX_SIZE   => MAX_XFER_SIZE   ,
            QUEUE_SIZE      => 2
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
            ARID            => I_ARID          , -- Out :
            ARADDR          => I_ARADDR        , -- Out :
            ARLEN           => I_ARLEN         , -- Out :
            ARSIZE          => I_ARSIZE        , -- Out :
            ARBURST         => I_ARBURST       , -- Out :
            ARLOCK          => I_ARLOCK        , -- Out :
            ARCACHE         => I_ARCACHE       , -- Out :
            ARPROT          => I_ARPROT        , -- Out :
            ARQOS           => I_ARQOS         , -- Out :
            ARREGION        => I_ARREGION      , -- Out :
            ARVALID         => I_ARVALID       , -- Out :
            ARREADY         => I_ARREADY       , -- In  :
            ----------------------------------------------------------------------
            -- AXI4 Read Data Channel Signals.
            ----------------------------------------------------------------------
            RID             => I_RID           , -- In  :
            RDATA           => I_RDATA         , -- In  :
            RRESP           => I_RRESP         , -- In  :
            RLAST           => I_RLAST         , -- In  :
            RVALID          => I_RVALID        , -- In  :
            RREADY          => I_RREADY        , -- Out :
            -----------------------------------------------------------------------
            -- Command Request Signals.
            -----------------------------------------------------------------------
            REQ_ADDR        => i_req_addr      , -- In  :
            REQ_SIZE        => i_req_size      , -- In  :
            REQ_ID          => I_ID            , -- In  :
            REQ_BURST       => I_BURST_TYPE    , -- In  :
            REQ_LOCK        => I_LOCK          , -- In  :
            REQ_CACHE       => I_CACHE         , -- In  :
            REQ_PROT        => I_PROT          , -- In  :
            REQ_QOS         => I_QOS           , -- In  :
            REQ_REGION      => I_REGION        , -- In  :
            REQ_BUF_PTR     => i_req_buf_ptr   , -- In  :
            REQ_FIRST       => i_req_first     , -- In  :
            REQ_LAST        => i_req_last      , -- In  :
            REQ_SPECULATIVE => I_SPECULATIVE   , -- In  :
            REQ_SAFETY      => I_SAFETY        , -- In  :
            REQ_VAL(0)      => i_req_valid     , -- In  :
            REQ_RDY         => i_req_ready     , -- Out :
            XFER_SIZE_SEL   => I_XFER_SIZE_SEL , -- In  :
            XFER_BUSY       => i_xfer_busy     , -- Out :
            -----------------------------------------------------------------------
            -- Response Signals.
            -----------------------------------------------------------------------
            ACK_VAL(0)      => i_ack_valid     , -- Out :
            ACK_ERROR       => i_ack_error     , -- Out :
            ACK_NEXT        => i_ack_next      , -- Out :
            ACK_LAST        => i_ack_last      , -- Out :
            ACK_STOP        => i_ack_stop      , -- Out :
            ACK_NONE        => i_ack_none      , -- Out :
            ACK_SIZE        => i_ack_size      , -- Out :
            -----------------------------------------------------------------------
            -- Flow Control Signals.
            -----------------------------------------------------------------------
            FLOW_PAUSE      => i_flow_pause    , -- In  :
            FLOW_STOP       => i_flow_stop     , -- In  :
            FLOW_LAST       => i_flow_last     , -- In  :
            FLOW_SIZE       => i_flow_size     , -- In  :
            -----------------------------------------------------------------------
            -- Reserve Size Signals.
            -----------------------------------------------------------------------
            RESV_VAL        => open            , -- Out :
            RESV_SIZE       => open            , -- Out :
            RESV_LAST       => open            , -- Out :
            RESV_ERROR      => open            , -- Out :
            -----------------------------------------------------------------------
            -- Push Size Signals.
            -----------------------------------------------------------------------
            PUSH_VAL(0)     => push_valid      , -- Out :
            PUSH_SIZE       => push_size       , -- Out :
            PUSH_LAST       => push_last       , -- Out :
            PUSH_ERROR      => push_error      , -- Out :
            -----------------------------------------------------------------------
            -- Read Buffer Interface Signals.
            -----------------------------------------------------------------------
            BUF_WEN(0)      => buf_wen         , -- Out :
            BUF_BEN         => buf_ben         , -- Out :
            BUF_DATA        => buf_wdata       , -- Out :
            BUF_PTR         => buf_wptr        , -- Out :
            BUF_RDY         => buf_wready        -- In  :
        );
    I_ARUSER <= (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_IF: AXI4_MASTER_WRITE_INTERFACE
        generic map (
            AXI4_ADDR_WIDTH => O_ADDR_WIDTH    ,
            AXI4_DATA_WIDTH => O_DATA_WIDTH    ,
            AXI4_ID_WIDTH   => O_ID_WIDTH      ,
            VAL_BITS        => 1               ,
            SIZE_BITS       => SIZE_BITS       ,
            REQ_SIZE_BITS   => SIZE_REGS_BITS  ,
            REQ_SIZE_VALID  => 1               ,
            FLOW_VALID      => 1               ,
            BUF_DATA_WIDTH  => BUF_DATA_WIDTH  ,
            BUF_PTR_BITS    => BUF_DEPTH       ,
            XFER_MIN_SIZE   => MAX_XFER_SIZE   ,
            XFER_MAX_SIZE   => MAX_XFER_SIZE   ,
            QUEUE_SIZE      => 1
        )
        port map (
            ----------------------------------------------------------------------
            -- Clock and Reset Signals.
            ----------------------------------------------------------------------
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
            ----------------------------------------------------------------------
            -- AXI4 Write Address Channel Signals.
            ----------------------------------------------------------------------
            AWID            => O_AWID          , -- Out :
            AWADDR          => O_AWADDR        , -- Out :
            AWLEN           => O_AWLEN         , -- Out :
            AWSIZE          => O_AWSIZE        , -- Out :
            AWBURST         => O_AWBURST       , -- Out :
            AWLOCK          => O_AWLOCK        , -- Out :
            AWCACHE         => O_AWCACHE       , -- Out :
            AWPROT          => O_AWPROT        , -- Out :
            AWQOS           => O_AWQOS         , -- Out :
            AWREGION        => O_AWREGION      , -- Out :
            AWVALID         => O_AWVALID       , -- Out :
            AWREADY         => O_AWREADY       , -- In  :
            ----------------------------------------------------------------------
            -- AXI4 Write Data Channel Signals.
            ----------------------------------------------------------------------
            WID             => O_WID           , -- Out :
            WDATA           => O_WDATA         , -- Out :
            WSTRB           => O_WSTRB         , -- Out :
            WLAST           => O_WLAST         , -- Out :
            WVALID          => O_WVALID        , -- Out :
            WREADY          => O_WREADY        , -- In  :
            ----------------------------------------------------------------------
            -- AXI4 Write Response Channel Signals.
            ----------------------------------------------------------------------
            BID             => O_BID           , -- In  :
            BRESP           => O_BRESP         , -- In  :
            BVALID          => O_BVALID        , -- In  :
            BREADY          => O_BREADY        , -- Out :
            -----------------------------------------------------------------------
            -- Command Request Signals.
            -----------------------------------------------------------------------
            REQ_ADDR        => o_req_addr      , -- In  :
            REQ_SIZE        => o_req_size      , -- In  :
            REQ_ID          => O_ID            , -- In  :
            REQ_BURST       => O_BURST_TYPE    , -- In  :
            REQ_LOCK        => O_LOCK          , -- In  :
            REQ_CACHE       => O_CACHE         , -- In  :
            REQ_PROT        => O_PROT          , -- In  :
            REQ_QOS         => O_QOS           , -- In  :
            REQ_REGION      => O_REGION        , -- In  :
            REQ_BUF_PTR     => o_req_buf_ptr   , -- In  :
            REQ_FIRST       => o_req_first     , -- In  :
            REQ_LAST        => o_req_last      , -- In  :
            REQ_SPECULATIVE => O_SPECULATIVE   , -- In  :
            REQ_SAFETY      => O_SAFETY        , -- In  :
            REQ_VAL(0)      => o_req_valid     , -- In  :
            REQ_RDY         => o_req_ready     , -- Out :
            XFER_SIZE_SEL   => O_XFER_SIZE_SEL , -- In  :
            XFER_BUSY       => o_xfer_busy     , -- Out :
            -----------------------------------------------------------------------
            -- Response Signals.
            -----------------------------------------------------------------------
            ACK_VAL(0)      => o_ack_valid     , -- Out :
            ACK_ERROR       => o_ack_error     , -- Out :
            ACK_NEXT        => o_ack_next      , -- Out :
            ACK_LAST        => o_ack_last      , -- Out :
            ACK_STOP        => o_ack_stop      , -- Out :
            ACK_NONE        => o_ack_none      , -- Out :
            ACK_SIZE        => o_ack_size      , -- Out :
            -----------------------------------------------------------------------
            -- Flow Control Signals.
            -----------------------------------------------------------------------
            FLOW_PAUSE      => o_flow_pause    , -- In  :
            FLOW_STOP       => o_flow_stop     , -- In  :
            FLOW_LAST       => o_flow_last     , -- In  :
            FLOW_SIZE       => o_flow_size     , -- In  :
            -----------------------------------------------------------------------
            -- Reserve Size Signals.
            -----------------------------------------------------------------------
            RESV_VAL        => open            , -- Out :
            RESV_SIZE       => open            , -- Out :
            RESV_LAST       => open            , -- Out :
            RESV_ERROR      => open            , -- Out :
            -----------------------------------------------------------------------
            -- Pull Size Signals.
            -----------------------------------------------------------------------
            PULL_VAL(0)     => pull_valid      , -- Out :
            PULL_SIZE       => pull_size       , -- Out :
            PULL_LAST       => pull_last       , -- Out :
            PULL_ERROR      => pull_error      , -- Out :
            -----------------------------------------------------------------------
            -- Read Buffer Interface Signals.
            -----------------------------------------------------------------------
            BUF_REN         => open            , -- Out :
            BUF_DATA        => buf_rdata       , -- In  :
            BUF_PTR         => buf_rptr        , -- Out :
            BUF_RDY         => buf_rready
        );
    O_AWUSER <= (others => '0');
    O_WUSER  <= (others => '0');
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
    I_ADDR_REGS: PUMP_COUNT_UP_REGISTER
        generic map (
            VALID           => 1               ,
            BITS            => I_ADDR_WIDTH    ,
            REGS_BITS       => ADDR_REGS_BITS
        )
        port map (
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => regs_wen (I_ADDR_REGS_HI downto I_ADDR_REGS_LO),
            REGS_WDATA      => regs_wbit(I_ADDR_REGS_HI downto I_ADDR_REGS_LO),
            REGS_RDATA      => regs_rbit(I_ADDR_REGS_HI downto I_ADDR_REGS_LO),
            UP_ENA          => i_running       ,
            UP_VAL          => i_ack_valid     ,
            UP_BEN          => i_addr_up_ben   ,
            UP_SIZE         => i_ack_size      ,
            COUNTER         => i_req_addr
       );
    i_addr_up_ben <= (others => '1') when (I_BURST_TYPE = AXI4_ABURST_INCR) else (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    I_SIZE_REGS: PUMP_COUNT_DOWN_REGISTER
        generic map (
            VALID           => 1               ,
            BITS            => SIZE_REGS_BITS  ,
            REGS_BITS       => SIZE_REGS_BITS  
        )
        port map (
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => regs_wen (I_SIZE_REGS_HI downto I_SIZE_REGS_LO),
            REGS_WDATA      => regs_wbit(I_SIZE_REGS_HI downto I_SIZE_REGS_LO),
            REGS_RDATA      => regs_rbit(I_SIZE_REGS_HI downto I_SIZE_REGS_LO),
            DN_ENA          => i_running       ,
            DN_VAL          => i_ack_valid     ,
            DN_SIZE         => i_ack_size      ,
            COUNTER         => i_req_size      ,
            ZERO            => open            ,
            NEG             => open
       );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    I_BUF_PTR: PUMP_COUNT_UP_REGISTER
        generic map (
            VALID           => 1               ,
            BITS            => BUF_DEPTH       ,
            REGS_BITS       => BUF_DEPTH
        )
        port map (
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => i_buf_ptr_init  ,
            REGS_WDATA      => BUF_INIT_PTR    ,
            REGS_RDATA      => open            ,
            UP_ENA          => i_running       ,
            UP_VAL          => i_ack_valid     ,
            UP_BEN          => BUF_UP_BEN      ,
            UP_SIZE         => i_ack_size      ,
            COUNTER         => i_req_buf_ptr
       );
    i_buf_ptr_init <= (others => '1') when (i_open = '0') else (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    I_CTRL_REGS: PUMP_CONTROL_REGISTER
        generic map (
            MODE_BITS               => 18              ,
            STAT_BITS               =>  6              
        )
        port map (
            CLK                     => ACLK            ,
            RST                     => RST             ,
            CLR                     => CLR             ,
            RESET_WRITE             => regs_wen (I_CTRL_RESET_POS),
            RESET_WDATA             => regs_wbit(I_CTRL_RESET_POS),
            RESET_RDATA             => regs_rbit(I_CTRL_RESET_POS),
            START_WRITE             => regs_wen (I_CTRL_START_POS),
            START_WDATA             => regs_wbit(I_CTRL_START_POS),
            START_RDATA             => regs_rbit(I_CTRL_START_POS),
            STOP_WRITE              => regs_wen (I_CTRL_STOP_POS ),
            STOP_WDATA              => regs_wbit(I_CTRL_STOP_POS ),
            STOP_RDATA              => regs_rbit(I_CTRL_STOP_POS ),
            PAUSE_WRITE             => regs_wen (I_CTRL_PAUSE_POS),
            PAUSE_WDATA             => regs_wbit(I_CTRL_PAUSE_POS),
            PAUSE_RDATA             => regs_rbit(I_CTRL_PAUSE_POS),
            FIRST_WRITE             => regs_wen (I_CTRL_FIRST_POS),
            FIRST_WDATA             => regs_wbit(I_CTRL_FIRST_POS),
            FIRST_RDATA             => regs_rbit(I_CTRL_FIRST_POS),
            LAST_WRITE              => regs_wen (I_CTRL_LAST_POS ),
            LAST_WDATA              => regs_wbit(I_CTRL_LAST_POS ),
            LAST_RDATA              => regs_rbit(I_CTRL_LAST_POS ),
            DONE_WRITE              => regs_wen (I_CTRL_DONE_POS ),
            DONE_WDATA              => regs_wbit(I_CTRL_DONE_POS ),
            DONE_RDATA              => regs_rbit(I_CTRL_DONE_POS ),
            ERROR_WRITE             => regs_wen (I_CTRL_ERROR_POS),
            ERROR_WDATA             => regs_wbit(I_CTRL_ERROR_POS),
            ERROR_RDATA             => regs_rbit(I_CTRL_ERROR_POS),
            MODE_WRITE(15 downto  0)=> regs_wen (I_CTRL_MODE_HI downto I_CTRL_MODE_LO),
            MODE_WRITE(16)          => regs_wen (I_CTRL_EVREQ_POS),
            MODE_WRITE(17)          => regs_wen (I_CTRL_RESV_POS ),
            MODE_WDATA(15 downto  0)=> regs_wbit(I_CTRL_MODE_HI downto I_CTRL_MODE_LO),
            MODE_WDATA(16)          => regs_wbit(I_CTRL_EVREQ_POS),
            MODE_WDATA(17)          => regs_wbit(I_CTRL_RESV_POS ),
            MODE_RDATA(15 downto  0)=> regs_rbit(I_CTRL_MODE_HI downto I_CTRL_MODE_LO),
            MODE_RDATA(16)          => regs_rbit(I_CTRL_EVREQ_POS),
            MODE_RDATA(17)          => regs_rbit(I_CTRL_RESV_POS ),
            STAT_WRITE( 5 downto  0)=> regs_wen (I_CTRL_STAT_HI downto I_CTRL_STAT_LO),
            STAT_WDATA( 5 downto  0)=> regs_wbit(I_CTRL_STAT_HI downto I_CTRL_STAT_LO),
            STAT_RDATA( 5 downto  0)=> regs_rbit(I_CTRL_STAT_HI downto I_CTRL_STAT_LO),
            STAT                    => i_stat_in       ,
            REQ_VALID               => i_req_valid     ,
            REQ_FIRST               => i_req_first     ,
            REQ_LAST                => i_req_last      ,
            REQ_READY               => i_req_ready     ,
            ACK_VALID               => i_ack_valid     ,
            ACK_ERROR               => i_ack_error     ,
            ACK_NEXT                => i_ack_next      ,
            ACK_LAST                => i_ack_last      ,
            ACK_STOP                => i_ack_stop      ,
            ACK_NONE                => i_ack_none      ,
            VALVE_OPEN              => i_open          ,
            XFER_DONE               => i_done          ,
            XFER_RUNNING            => i_running       
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    I_VALVE: PUMP_INTAKE_VALVE 
        generic map (
            COUNT_BITS              => SIZE_BITS       ,
            SIZE_BITS               => SIZE_BITS       
        )
        port map (
            CLK                     => ACLK            ,
            RST                     => RST             ,
            CLR                     => CLR             ,
            BUFFER_SIZE             => BUF_BYTES       ,
            THRESHOLD_SIZE          => I_THRESHOLD_SIZE,
            I_OPEN                  => i_open          ,
            O_OPEN                  => o_open          ,
            RESET                   => regs_rbit(I_CTRL_RESET_POS),
            PAUSE                   => regs_rbit(I_CTRL_PAUSE_POS),
            STOP                    => regs_rbit(I_CTRL_STOP_POS ),
            PUSH_VAL                => i_ack_valid     ,
            PUSH_LAST               => i_ack_last      ,
            PUSH_SIZE               => i_ack_size      ,
            PULL_VAL                => pull_valid      ,
            PULL_LAST               => pull_last       ,
            PULL_SIZE               => pull_size       ,
            FLOW_PAUSE              => i_flow_pause    ,
            FLOW_STOP               => i_flow_stop     ,
            FLOW_LAST               => i_flow_last     ,
            FLOW_SIZE               => i_flow_size     ,
            FLOW_COUNT              => open            ,
            FLOW_NEG                => open            ,
            PAUSED                  => open            
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    i_stat_in(0) <= '1' when (i_done = '1' and regs_rbit(I_CTRL_EVREQ_POS) = '1') else '0';
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
            if (regs_rbit(I_CTRL_MODE_LO+0) = '1' and regs_rbit(I_CTRL_DONE_POS  ) = '1') or
               (regs_rbit(I_CTRL_MODE_LO+1) = '1' and regs_rbit(I_CTRL_ERROR_POS ) = '1') or
               (regs_rbit(I_CTRL_MODE_LO+2) = '1' and regs_rbit(I_CTRL_STAT_LO +0) = '1') then
                I_IRQ <= '1';
            else
                I_IRQ <= '0';
            end if;
        end if;
    end process;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_ADDR_REGS: PUMP_COUNT_UP_REGISTER
        generic map (
            VALID           => 1               ,
            BITS            => O_ADDR_WIDTH    ,
            REGS_BITS       => ADDR_REGS_BITS
        )
        port map (
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => regs_wen (O_ADDR_REGS_HI downto O_ADDR_REGS_LO),
            REGS_WDATA      => regs_wbit(O_ADDR_REGS_HI downto O_ADDR_REGS_LO),
            REGS_RDATA      => regs_rbit(O_ADDR_REGS_HI downto O_ADDR_REGS_LO),
            UP_ENA          => o_running       ,
            UP_VAL          => o_ack_valid     ,
            UP_BEN          => o_addr_up_ben   ,
            UP_SIZE         => o_ack_size      ,
            COUNTER         => o_req_addr
       );
    o_addr_up_ben <= (others => '1') when (O_BURST_TYPE = AXI4_ABURST_INCR) else (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_SIZE_REGS: PUMP_COUNT_DOWN_REGISTER
        generic map (
            VALID           => 1               ,
            BITS            => SIZE_REGS_BITS  ,
            REGS_BITS       => SIZE_REGS_BITS
        )
        port map (
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => regs_wen (O_SIZE_REGS_HI downto O_SIZE_REGS_LO),
            REGS_WDATA      => regs_wbit(O_SIZE_REGS_HI downto O_SIZE_REGS_LO),
            REGS_RDATA      => regs_rbit(O_SIZE_REGS_HI downto O_SIZE_REGS_LO),
            DN_ENA          => o_running       ,
            DN_VAL          => o_ack_valid     ,
            DN_SIZE         => o_ack_size      ,
            COUNTER         => o_req_size      ,
            ZERO            => open            ,
            NEG             => open
       );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_BUF_PTR: PUMP_COUNT_UP_REGISTER
        generic map (
            VALID           => 1               ,
            BITS            => BUF_DEPTH       ,
            REGS_BITS       => BUF_DEPTH
        )
        port map (
            CLK             => ACLK            ,
            RST             => RST             ,
            CLR             => CLR             ,
            REGS_WEN        => o_buf_ptr_init  ,
            REGS_WDATA      => BUF_INIT_PTR    ,
            REGS_RDATA      => open            ,
            UP_ENA          => o_running       ,
            UP_VAL          => o_ack_valid     ,
            UP_BEN          => BUF_UP_BEN      ,
            UP_SIZE         => o_ack_size      ,
            COUNTER         => o_req_buf_ptr
       );
    o_buf_ptr_init <= (others => '1') when (o_open = '0') else (others => '0');
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_CTRL_REGS: PUMP_CONTROL_REGISTER
        generic map (
            MODE_BITS               => 18              ,
            STAT_BITS               =>  6              
        )
        port map (
            CLK                     => ACLK            ,
            RST                     => RST             ,
            CLR                     => CLR             ,
            RESET_WRITE             => regs_wen (O_CTRL_RESET_POS),
            RESET_WDATA             => regs_wbit(O_CTRL_RESET_POS),
            RESET_RDATA             => regs_rbit(O_CTRL_RESET_POS),
            START_WRITE             => regs_wen (O_CTRL_START_POS),
            START_WDATA             => regs_wbit(O_CTRL_START_POS),
            START_RDATA             => regs_rbit(O_CTRL_START_POS),
            STOP_WRITE              => regs_wen (O_CTRL_STOP_POS ),
            STOP_WDATA              => regs_wbit(O_CTRL_STOP_POS ),
            STOP_RDATA              => regs_rbit(O_CTRL_STOP_POS ),
            PAUSE_WRITE             => regs_wen (O_CTRL_PAUSE_POS),
            PAUSE_WDATA             => regs_wbit(O_CTRL_PAUSE_POS),
            PAUSE_RDATA             => regs_rbit(O_CTRL_PAUSE_POS),
            FIRST_WRITE             => regs_wen (O_CTRL_FIRST_POS),
            FIRST_WDATA             => regs_wbit(O_CTRL_FIRST_POS),
            FIRST_RDATA             => regs_rbit(O_CTRL_FIRST_POS),
            LAST_WRITE              => regs_wen (O_CTRL_LAST_POS ),
            LAST_WDATA              => regs_wbit(O_CTRL_LAST_POS ),
            LAST_RDATA              => regs_rbit(O_CTRL_LAST_POS ),
            DONE_WRITE              => regs_wen (O_CTRL_DONE_POS ),
            DONE_WDATA              => regs_wbit(O_CTRL_DONE_POS ),
            DONE_RDATA              => regs_rbit(O_CTRL_DONE_POS ),
            ERROR_WRITE             => regs_wen (O_CTRL_ERROR_POS),
            ERROR_WDATA             => regs_wbit(O_CTRL_ERROR_POS),
            ERROR_RDATA             => regs_rbit(O_CTRL_ERROR_POS),
            MODE_WRITE(15 downto  0)=> regs_wen (O_CTRL_MODE_HI downto O_CTRL_MODE_LO),
            MODE_WRITE(16)          => regs_wen (O_CTRL_EVREQ_POS),
            MODE_WRITE(17)          => regs_wen (O_CTRL_RESV_POS ),
            MODE_WDATA(15 downto  0)=> regs_wbit(O_CTRL_MODE_HI downto O_CTRL_MODE_LO),
            MODE_WDATA(16)          => regs_wbit(O_CTRL_EVREQ_POS),
            MODE_WDATA(17)          => regs_wbit(O_CTRL_RESV_POS ),
            MODE_RDATA(15 downto  0)=> regs_rbit(O_CTRL_MODE_HI downto O_CTRL_MODE_LO),
            MODE_RDATA(16)          => regs_rbit(O_CTRL_EVREQ_POS),
            MODE_RDATA(17)          => regs_rbit(O_CTRL_RESV_POS ),
            STAT_WRITE( 5 downto  0)=> regs_wen (O_CTRL_STAT_HI downto O_CTRL_STAT_LO),
            STAT_WDATA( 5 downto  0)=> regs_wbit(O_CTRL_STAT_HI downto O_CTRL_STAT_LO),
            STAT_RDATA( 5 downto  0)=> regs_rbit(O_CTRL_STAT_HI downto O_CTRL_STAT_LO),
            STAT                    => o_stat_in       ,
            REQ_VALID               => o_req_valid     ,
            REQ_FIRST               => o_req_first     ,
            REQ_LAST                => o_req_last      ,
            REQ_READY               => o_req_ready     ,
            ACK_VALID               => o_ack_valid     ,
            ACK_ERROR               => o_ack_error     ,
            ACK_NEXT                => o_ack_next      ,
            ACK_LAST                => o_ack_last      ,
            ACK_STOP                => o_ack_stop      ,
            ACK_NONE                => o_ack_none      ,
            VALVE_OPEN              => o_open          ,
            XFER_DONE               => o_done          ,
            XFER_RUNNING            => o_running       
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    O_VALVE: PUMP_OUTLET_VALVE 
        generic map (
            COUNT_BITS              => SIZE_BITS       ,
            SIZE_BITS               => SIZE_BITS       
        )
        port map (
            CLK                     => ACLK            ,
            RST                     => RST             ,
            CLR                     => CLR             ,
            THRESHOLD_SIZE          => I_THRESHOLD_SIZE,
            I_OPEN                  => i_open          ,
            O_OPEN                  => o_open          ,
            RESET                   => regs_rbit(O_CTRL_RESET_POS),
            PAUSE                   => regs_rbit(O_CTRL_PAUSE_POS),
            STOP                    => regs_rbit(O_CTRL_STOP_POS ),
            PUSH_VAL                => push_valid      ,
            PUSH_LAST               => push_last       ,
            PUSH_SIZE               => push_size       ,
            PULL_VAL                => o_ack_valid     ,
            PULL_LAST               => o_ack_last      ,
            PULL_SIZE               => o_ack_size      ,
            FLOW_PAUSE              => o_flow_pause    ,
            FLOW_STOP               => o_flow_stop     ,
            FLOW_LAST               => o_flow_last     ,
            FLOW_SIZE               => o_flow_size     ,
            FLOW_COUNT              => open            ,
            FLOW_NEG                => open            ,
            PAUSED                  => open            
        );
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    o_stat_in(0) <= '1' when (o_done = '1' and regs_rbit(O_CTRL_EVREQ_POS) = '1') else '0';
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
            if (regs_rbit(O_CTRL_MODE_LO+0) = '1' and regs_rbit(O_CTRL_DONE_POS  ) = '1') or
               (regs_rbit(O_CTRL_MODE_LO+1) = '1' and regs_rbit(O_CTRL_ERROR_POS ) = '1') or
               (regs_rbit(O_CTRL_MODE_LO+2) = '1' and regs_rbit(O_CTRL_STAT_LO +0) = '1') then
                O_IRQ <= '1';
            else
                O_IRQ <= '0';
            end if;
        end if;
    end process;
    ------------------------------------------------------------------------------
    -- 
    ------------------------------------------------------------------------------
    RAM: SDPRAM 
        generic map(
            DEPTH       => BUF_DEPTH+3         ,
            RWIDTH      => BUF_DATA_SIZE       , --
            WWIDTH      => BUF_DATA_SIZE       , --
            WEBIT       => BUF_DATA_SIZE-3     , --
            ID          => 0                     -- 
        )                                        -- 
        port map (                               -- 
            WCLK        => ACLK                , -- In  :
            WE          => buf_we              , -- In  :
            WADDR       => buf_wptr(BUF_DEPTH-1 downto BUF_DATA_SIZE-3), -- In  :
            WDATA       => buf_wdata           , -- In  :
            RCLK        => ACLK                , -- In  :
            RADDR       => buf_rptr(BUF_DEPTH-1 downto BUF_DATA_SIZE-3), -- In  :
            RDATA       => buf_rdata             -- Out :
        );
    buf_we <= buf_ben when (buf_wen = '1') else (others => '0');
end RTL;

-----------------------------------------------------------------------------------
--!     @file    pump_axi4_to_axi4_test_bench_64_32.vhd
--!     @brief   Test Bench for Pump Sample Module (AXI4 to AXI4)
--!     @version 0.7.0
--!     @date    2014/3/29
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2014 Ichiro Kawazome
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
entity  PUMP_AXI4_TO_AXI4_TEST_BENCH_64_32 is
end     PUMP_AXI4_TO_AXI4_TEST_BENCH_64_32;
architecture MODEL of PUMP_AXI4_TO_AXI4_TEST_BENCH_64_32 is
    component  PUMP_AXI4_TO_AXI4_TEST_BENCH
        generic (
            NAME            : STRING;
            SCENARIO_FILE   : STRING;
            I_DATA_WIDTH    : integer;
            O_DATA_WIDTH    : integer;
            MAX_XFER_SIZE   : integer
        );
    end component;
begin
    TB: PUMP_AXI4_TO_AXI4_TEST_BENCH
        generic map (
            NAME            => string'("PUMP_AXI4_TO_AXI4_TEST_BENCH_64_32"),
            SCENARIO_FILE   => string'("pump_axi4_to_axi4_test_bench_64_32.snr"),
            I_DATA_WIDTH    => 64,
            O_DATA_WIDTH    => 32,
            MAX_XFER_SIZE   =>  6
        );        
end MODEL;


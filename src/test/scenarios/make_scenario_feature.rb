#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
#
#       Version     :   1.5.5
#       Created     :   2014/3/20
#       File name   :   make_scneario_feature.rb
#       Author      :   Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
#       Description :   PUMP-AXI4用シナリオ生成スクリプト
#
#---------------------------------------------------------------------------------
#
#       Copyright (C) 2012-2014 Ichiro Kawazome
#       All rights reserved.
# 
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions
#       are met:
# 
#         1. Redistributions of source code must retain the above copyright
#            notice, this list of conditions and the following disclaimer.
# 
#         2. Redistributions in binary form must reproduce the above copyright
#            notice, this list of conditions and the following disclaimer in
#            the documentation and/or other materials provided with the
#            distribution.
# 
#       THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#       "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#       LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#       A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
#       OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#       SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#       LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#       DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#       THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#       OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
#---------------------------------------------------------------------------------
require 'optparse'
require 'pp'
require_relative "../../../../Dummy_Plug/tools/Dummy_Plug/ScenarioWriter/axi4"
require_relative "../../../../Dummy_Plug/tools/Dummy_Plug/ScenarioWriter/number-generater"
class ScenarioGenerater
  #-------------------------------------------------------------------------------
  # インスタンス変数
  #-------------------------------------------------------------------------------
  attr_reader   :program_name, :program_version
  attr_accessor :name   , :file_name, :test_items
  attr_accessor :c_model
  attr_accessor :m_model
  attr_accessor :i_model
  attr_accessor :o_model
  #-------------------------------------------------------------------------------
  # initialize
  #-------------------------------------------------------------------------------
  def initialize
    @program_name      = "make_scenario(feature)"
    @program_version   = "1.5.5"
    @c_axi4_addr_width = 32
    @i_axi4_addr_width = 32
    @o_axi4_addr_width = 32
    @m_axi4_addr_width = 32
    @c_axi4_data_width = 32
    @i_axi4_data_width = 32
    @o_axi4_data_width = 32
    @m_axi4_data_width = 32
    @c_max_xfer_size   = 16
    @i_max_xfer_size   = 64
    @o_max_xfer_size   = 64
    @m_max_xfer_size   = 16
    @id_width          = 4
    @c_model           = nil
    @i_model           = nil
    @o_model           = nil
    @m_model           = nil
    @c_id              = 0
    @i_id              = 1
    @o_id              = 2
    @m_id              = 3
    @no                = 0
    @name              = "PUMP_AXI4_TEST"
    @file_name         = nil
    @test_items        = []
    @timeout           = 10000
    @opt               = OptionParser.new do |opt|
      opt.program_name = @program_name
      opt.version      = @program_version
      opt.on("--verbose"              ){|val| @verbose           = true     }
      opt.on("--name       STRING"    ){|val| @name              = val      }
      opt.on("--output     FILE_NAME" ){|val| @file_name         = val      }
      opt.on("--c_width    INTEGER"   ){|val| @c_axi4_data_width = val.to_i }
      opt.on("--i_width    INTEGER"   ){|val| @i_axi4_data_width = val.to_i }
      opt.on("--o_width    INTEGER"   ){|val| @o_axi4_data_width = val.to_i }
      opt.on("--m_width    INTEGER"   ){|val| @m_axi4_data_width = val.to_i }
      opt.on("--i_max_size INTEGER"   ){|val| @i_max_xfer_size   = val.to_i }
      opt.on("--o_max_size INTEGER"   ){|val| @o_max_xfer_size   = val.to_i }
      opt.on("--m_max_size INTEGER"   ){|val| @m_max_xfer_size   = val.to_i }
      opt.on("--timeout    INTEGER"   ){|val| @timeout           = val.to_i }
      opt.on("--test_item  INTEGER"   ){|val| @test_items.push(val.to_i)    }
    end
  end
  #-------------------------------------------------------------------------------
  # parse_options
  #-------------------------------------------------------------------------------
  def parse_options(argv)
    @opt.parse(argv)
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def  gen_simple_read(io, model, address, data, resp)
    pos = 0
    max_xfer_size = model.read_transaction.max_transaction_size
    while (pos < data.length)
      len = max_xfer_size - (address % max_xfer_size)
      if (pos + len > data.length)
          len = data.length - pos
      end
      io.print model.read( {:Address => address, :Data => data[pos..pos+len-1], :Response => resp})
      pos     += len
      address += len
    end
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def  gen_simple_write(io, model, address, data, resp)
    pos = 0
    max_xfer_size = model.write_transaction.max_transaction_size
    while (pos < data.length)
      len = max_xfer_size - (address % max_xfer_size)
      if (pos + len > data.length)
          len = data.length - pos
      end
      io.print model.write({:Address => address, :Data => data[pos..pos+len-1], :Response => resp})
      pos     += len
      address += len
    end
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def  gen_pipeline_read(io, model, address, data, resp)
    pos           = 0
    max_xfer_size = model.read_transaction.max_transaction_size
    data_xfer_pattern_1 = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([32,0])
    data_xfer_pattern_2 = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([ 3,0])
    while (pos < data.length)
      len = max_xfer_size - (address % max_xfer_size)
      if (pos + len > data.length)
          len = data.length - pos
      end
      io.print model.read( {
               :Address         => address, 
               :Data            => data[pos..pos+len-1], 
               :Response        => resp, 
               :DataStartEvent  => (pos == 0) ? :ADDR_VALID         : :NO_WAIT,
               :DataXferPattern => (pos == 0) ? data_xfer_pattern_1 : data_xfer_pattern_2
      })
      pos     += len
      address += len
    end
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def  gen_pipeline_write(io, model, address, data, resp)
    pos           = 0
    max_xfer_size = model.read_transaction.max_transaction_size
    data_xfer_pattern = Dummy_Plug::ScenarioWriter::GenericNumberGenerater.new([3,0])
    while (pos < data.length)
      len = max_xfer_size - (address % max_xfer_size)
      if (pos + len > data.length)
          len = data.length - pos
      end
      io.print model.write( {
               :Address           => address, 
               :Data              => data[pos..pos+len-1], 
               :Response          => resp, 
               :DataStartEvent    => (pos == 0) ? :ADDR_VALID    : :NO_WAIT,
               :DataXferPattern   => data_xfer_pattern,
               :ResponseStartEvent=> (pos == 0) ? :LAST_DATA_XFER: :NO_WAIT,
               :ResponseDelayCycle=> (pos == 0) ? 40             : 20

      })
      pos     += len
      address += len
    end
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def gen_ctrl_regs(arg)
    ctrl_regs  = 0
    ctrl_regs |= (0x80000000) if (arg.index(:Reset))
    ctrl_regs |= (0x40000000) if (arg.index(:Pause))
    ctrl_regs |= (0x20000000) if (arg.index(:Stop ))
    ctrl_regs |= (0x10000000) if (arg.index(:Start))
    ctrl_regs |= (0x04000000) if (arg.index(:Done_Enable))
    ctrl_regs |= (0x02000000) if (arg.index(:First))
    ctrl_regs |= (0x01000000) if (arg.index(:Last ))
    ctrl_regs |= (0x00020000) if (arg.index(:Error))
    ctrl_regs |= (0x00010000) if (arg.index(:Done ))
    ctrl_regs |= (0x00008000) if (arg.index(:Safety))
    ctrl_regs |= (0x00004000) if (arg.index(:Speculative))
    ctrl_regs |= (0x00000002) if (arg.index(:Error_Enable))
    ctrl_regs |= (0x00000001) if (arg.index(:Done_Enable))
    return ctrl_regs
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def gen_op_code(arg)
    op_code  = 0
    op_code |= (0xC0000000) if (arg.index(:Transfer))
    op_code |= (0xD0000000) if (arg.index(:Link))
    op_code |= (0x08000000) if (arg.index(:End))
    op_code |= (0x04000000) if (arg.index(:Fetch))
    op_code |= (0x02000000) if (arg.index(:First))
    op_code |= (0x01000000) if (arg.index(:Last ))
    op_code |= (0x00008000) if (arg.index(:Safety))
    op_code |= (0x00004000) if (arg.index(:Speculative))
    return op_code
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def simple_test(title, io, i_address, o_address, i_size, o_size)
    size   = i_size
    data   = (1..size).collect{rand(256)}
    i_mode = gen_ctrl_regs([:Last,:First,:Done_Enable,:Error_Enable])
    o_mode = gen_ctrl_regs([:Last,:First,:Done_Enable,:Error_Enable])
    done   = gen_ctrl_regs([:Done])
    start  = gen_ctrl_regs([:Start])
    io.print "---\n"
    io.print "- MARCHAL : \n"
    io.print "  - SAY : ", title, "\n"
    io.print @c_model.write({
               :Address => 0x00000000, 
               :Data    => [sprintf("0x%08X", o_address)     ,
                            "0x00000000"                     , 
                            sprintf("0x%08X", o_size)        ,
                            sprintf("0x%08X", o_mode | start),
                            sprintf("0x%08X", i_address)     ,
                            "0x00000000"                     ,
                            sprintf("0x%08X", i_size)        ,
                            sprintf("0x%08X", o_mode | start)
                           ]
             })
    io.print "  - WAIT  : {GPI(0) : 1, GPI(1) : 1, TIMEOUT: ", @timeout.to_s, "}\n"
    io.print "  - SYNC  : {PORT : LOCAL}\n"
    io.print @c_model.read({
               :Address => 0x00000000, 
               :Data    => [sprintf("0x%08X", o_address+size),
                            "0x00000000"                     , 
                            sprintf("0x%08X", o_size-size   ),
                            sprintf("0x%08X", o_mode | done ),
                            sprintf("0x%08X", i_address+size),
                            "0x00000000"                     ,
                            sprintf("0x%08X", i_size-size   ),
                            sprintf("0x%08X", o_mode | done )
                           ]
             })
    io.print "  - SYNC  : {PORT : LOCAL}\n"
    io.print @c_model.write({
               :Address => 0x00000000, 
               :Data    => ["0x00000000"                     ,
                            "0x00000000"                     , 
                            "0x00000000"                     , 
                            "0x00000000"                     , 
                            "0x00000000"                     , 
                            "0x00000000"                     , 
                            "0x00000000"                     , 
                            "0x00000000"                     
                           ]
             })
    io.print "  - WAIT  : {GPI(0) : 0, GPI(1) : 0, TIMEOUT: ", @timeout.to_s, "}\n"
    io.print "  - SYNC  : {PORT : LOCAL}\n"
    gen_simple_read( io, @i_model, i_address, data, "OKAY")
    gen_simple_write(io, @o_model, o_address, data, "OKAY")
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def pipeline_test(title, io, i_address, o_address, i_size, o_size)
    size   = i_size
    data   = (1..size).collect{rand(256)}
    i_mode = gen_ctrl_regs([:Last,:First,:Done_Enable,:Error_Enable,:Speculative])
    o_mode = gen_ctrl_regs([:Last,:First,:Done_Enable,:Error_Enable,:Speculative])
    done   = gen_ctrl_regs([:Done])
    start  = gen_ctrl_regs([:Start])
    io.print "---\n"
    io.print "- MARCHAL : \n"
    io.print "  - SAY : ", title, "\n"
    io.print @c_model.write({
               :Address => 0x00000000, 
               :Data    => [sprintf("0x%08X", o_address)     ,
                            "0x00000000"                     , 
                            sprintf("0x%08X", o_size)        ,
                            sprintf("0x%08X", o_mode | start),
                            sprintf("0x%08X", i_address)     ,
                            "0x00000000"                     ,
                            sprintf("0x%08X", i_size)        ,
                            sprintf("0x%08X", i_mode | start)
                           ]
             })
    io.print "  - WAIT  : {GPI(0) : 1, GPI(1) : 1, TIMEOUT: ", @timeout.to_s, "}\n"
    io.print "  - SYNC  : {PORT : LOCAL}\n"
    io.print @c_model.read({
               :Address => 0x00000000, 
               :Data    => [sprintf("0x%08X", o_address+size),
                            "0x00000000"                     , 
                            sprintf("0x%08X", o_size-size   ),
                            sprintf("0x%08X", o_mode | done ),
                            sprintf("0x%08X", i_address+size),
                            "0x00000000"                     ,
                            sprintf("0x%08X", i_size-size   ),
                            sprintf("0x%08X", i_mode | done )
                           ]
             })
    io.print "  - SYNC  : {PORT : LOCAL}\n"
    io.print @c_model.write({
               :Address => 0x00000000, 
               :Data    => ["0x00000000"                     ,
                            "0x00000000"                     , 
                            "0x00000000"                     , 
                            "0x00000000"                     , 
                            "0x00000000"                     , 
                            "0x00000000"                     , 
                            "0x00000000"                     , 
                            "0x00000000"                     
                           ]
             })
    io.print "  - WAIT  : {GPI(0) : 0, GPI(1) : 0, TIMEOUT: ", @timeout.to_s, "}\n"
    io.print "  - SYNC  : {PORT : LOCAL}\n"
    gen_pipeline_read( io, @i_model, i_address, data, "OKAY")
    gen_pipeline_write(io, @o_model, o_address, data, "OKAY")
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def test_8(io)
    test_num = 0
    # [1,2,3,4,5,6,7,8,9,10,16,21,32,49,64,71,85,99,110,128,140,155,189,200,212,234,256].each{|size|
    [250].each{|size|
      (0xFC00..0xFC00).each {|i_address|
      (0x1000..0x1000).each {|o_address|
        title = @name.to_s + ".8." + test_num.to_s
        pipeline_test(title, io, i_address, o_address, size, size)
        test_num += 1
      }}
    }
    [32,51,64,69,81,97,110,128,140,155,189,200,212,234,256].each{|size|
      (0x7030..0x7033).each {|i_address|
      (0x1020..0x1023).each {|o_address|
        title = @name.to_s + ".8." + test_num.to_s
        pipeline_test(title, io, i_address, o_address, size, size)
        test_num += 1
      }}
    }
  end
  #-------------------------------------------------------------------------------
  # 
  #-------------------------------------------------------------------------------
  def generate
    if @file_name == nil then
        @file_name = sprintf("pump_axi4_to_axi4_test_bench_%d_%d_feature.snr", @i_axi4_data_width, @o_axi4_data_width)
    end
    if @test_items == []
      @test_items = [8]
    end
    if @c_model == nil
      @c_model = Dummy_Plug::ScenarioWriter::AXI4::Master.new("CSR", {
        :ID            => @c_id,
        :ID_WIDTH      => 4,
        :ADDR_WIDTH    => @c_axi4_addr_width,
        :DATA_WIDTH    => @c_axi4_data_width,
        :MAX_TRAN_SIZE => @c_max_xfer_size  
      })
    end
    if @i_model == nil
      @i_model = Dummy_Plug::ScenarioWriter::AXI4::Slave.new("I", {
        :ID            => @i_id,
        :ID_WIDTH      => 4,
        :ADDR_WIDTH    => @i_axi4_addr_width,
        :DATA_WIDTH    => @i_axi4_data_width,
        :MAX_TRAN_SIZE => @i_max_xfer_size  
      })
    end
    if @o_model == nil
      @o_model = Dummy_Plug::ScenarioWriter::AXI4::Slave.new("O", {
        :ID            => @o_id,
        :ID_WIDTH      => 4,
        :ADDR_WIDTH    => @o_axi4_addr_width,
        :DATA_WIDTH    => @o_axi4_data_width,
        :MAX_TRAN_SIZE => @o_max_xfer_size  
      })
    end
    if @m_model == nil
      @m_model = Dummy_Plug::ScenarioWriter::AXI4::Slave.new("M", {
        :ID            => @m_id,
        :ID_WIDTH      => 4,
        :ADDR_WIDTH    => @m_axi4_addr_width,
        :DATA_WIDTH    => @m_axi4_data_width,
        :MAX_TRAN_SIZE => @m_max_xfer_size  
      })
    end
    title = @name.to_s + 
            " I_DATA_WIDTH="    + @i_axi4_data_width.to_s + 
            " O_DATA_WIDTH="    + @o_axi4_data_width.to_s +
            " I_MAX_XFER_SIZE=" + @i_max_xfer_size.to_s   +
            " O_MAX_XFER_SIZE=" + @o_max_xfer_size.to_s
    io = open(@file_name, "w")
    io.print "---\n"
    io.print "- N : \n"
    io.print "  - SAY : ", title, "\n"
    @test_items.each {|item|
        test_8(io) if (item == 8)
    }
  end
end
gen = ScenarioGenerater.new
gen.parse_options(ARGV)
gen.generate

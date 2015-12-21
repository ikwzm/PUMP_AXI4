#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#---------------------------------------------------------------------------------
require 'optparse'
require 'pp'
class ScenarioGenerater
  class IOScenarioGenerater
    def initialize(name, command, axi4_data_width, max_xfer_size, id)
      @name            = name
      @axi4_data_width = axi4_data_width
      @axi4_data_size  = (Math.log2(@axi4_data_width)).to_i
      @max_xfer_size   = max_xfer_size
      @command         = command
      @id              = id
    end

    def  generate(io, command, address, data, resp)
      io.print "- ", @name , " : \n"
      pos = 0
      while (pos < data.length)
        len = @max_xfer_size - (address % @max_xfer_size)
        if (pos + len > data.length)
            len = data.length - pos
        end
        io.print "  - ", command, " : \n"
        io.print "      ADDR : ", sprintf("0x%08X", address), "\n"
        io.print "      SIZE : ", @axi4_data_width/8, "\n"
        io.print "      BURST: INCR\n"
        io.print "      ID   : ", @id, "\n"
        io.print "      DATA : [", (data[pos..pos+len-1].collect{ |d| sprintf("0x%02X",d)}).join(',') ,"]\n"
        io.print "      RESP : ", resp, "\n"
        pos     += len
        address += len
      end
    end

    def read_byte (io, address, data, resp)
      generate(io, "READ" , address, data, resp)
    end

    def write_byte(io, address, data, resp)
      generate(io, "WRITE", address, data, resp)
    end

    def read_word (io, address, data, resp)
      byte_data = []
      data.each{|word|
        byte_data.concat([word&0xFF, (word>>8)&0xFF, (word>>16)&0xFF, (word>>24)&0xFF])
      }
      generate(io, "READ", address, byte_data, resp)
    end
  end

  def initialize
    @program_name      = "make_scenario"
    @program_version   = "0.0.4"
    @i_gen             = nil
    @o_gen             = nil
    @m_gen             = nil
    @timeout           = 10000
    @no                = 0
    @i_id              = 1
    @o_id              = 2
    @m_id              = 3
    @i_axi4_data_width = 32
    @o_axi4_data_width = 32
    @m_axi4_data_width = 32
    @name              = "PUMP_AXI4_TO_AXI4_TEST"
    @file_name         = "pump_axi4_to_axi4_test_bench_32_32.snr"
    @i_max_xfer_size   = 64
    @o_max_xfer_size   = 64
    @m_max_xfer_size   = 16
    @test_items        = []
    @opt               = OptionParser.new do |opt|
      opt.program_name = @program_name
      opt.version      = @program_version
      opt.on("--verbose"             ){|val| @verbose           = true     }
      opt.on("--name      STRING"    ){|val| @name              = val      }
      opt.on("--output    FILE_NAME" ){|val| @file_name         = val      }
      opt.on("--i_width   INTEGER"   ){|val| @i_axi4_data_width = val.to_i }
      opt.on("--o_width   INTEGER"   ){|val| @o_axi4_data_width = val.to_i }
      opt.on("--timeout   INTEGER"   ){|val| @timeout           = val.to_i }
      opt.on("--max_size  INTEGER"   ){|val| @i_max_xfer_size   = val.to_i 
                                             @o_max_xfer_size   = val.to_i }
      opt.on("--test_item INTEGER"   ){|val| @test_items.push(val.to_i)    }
    end
  end

  def parse_options(argv)
    @opt.parse(argv)
  end

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
    ctrl_regs |= (0x00008000) if (arg.index(:Speculative))
    ctrl_regs |= (0x00004000) if (arg.index(:Safety))
    ctrl_regs |= (0x00000002) if (arg.index(:Error_Enable))
    ctrl_regs |= (0x00000001) if (arg.index(:Done_Enable))
    return ctrl_regs
  end

  def gen_op_code(arg)
    op_code  = 0
    op_code |= (0xC0000000) if (arg.index(:Transfer))
    op_code |= (0xD0000000) if (arg.index(:Link))
    op_code |= (0x08000000) if (arg.index(:End))
    op_code |= (0x04000000) if (arg.index(:Fetch))
    op_code |= (0x02000000) if (arg.index(:First))
    op_code |= (0x01000000) if (arg.index(:Last ))
    op_code |= (0x00008000) if (arg.index(:Speculative))
    op_code |= (0x00004000) if (arg.index(:Safety))
    return op_code
  end

  def gen1(title, io, i_address, o_address, i_size, o_size)
    size   = i_size
    data   = (1..size).collect{rand(256)}
    i_mode = gen_ctrl_regs([:Last,:First,:Done_Enable,:Error_Enable])
    o_mode = gen_ctrl_regs([:Last,:First,:Done_Enable,:Error_Enable])
    done   = gen_ctrl_regs([:Done])
    start  = gen_ctrl_regs([:Start])
    io.print "---\n"
    io.print "- MARCHAL : \n"
    io.print "  - SAY : ", title, "\n"
    io.print "- CSR : \n"
    io.print "  - WRITE : \n"
    io.print "      ADDR : 0x00000000\n"
    io.print "      ID   : 10\n"
    io.print "      DATA : - ", sprintf("0x%08X", o_address)     , " # O_ADDR[31:00]\n"
    io.print "             - 0x00000000"                         , " # O_ADDR[63:32]\n"                  
    io.print "             - ", sprintf("0x%08X", o_size)        , " # O_SIZE[31:00]\n"
    io.print "             - ", sprintf("0x%08X", o_mode | start), " # O_CTRL[31:00]\n"
    io.print "             - ", sprintf("0x%08X", i_address)     , " # I_ADDR[31:00]\n"
    io.print "             - 0x00000000"                         , " # I_ADDR[63:32]\n"
    io.print "             - ", sprintf("0x%08X", i_size)        , " # I_SIZE[31:00]\n"
    io.print "             - ", sprintf("0x%08X", o_mode | start), " # I_CTRL[31:00]\n"
    io.print "      RESP : OKAY\n"
    io.print "  - WAIT  : {GPI(0) : 1, GPI(1) : 1, TIMEOUT: ", @timeout.to_s, "}\n"
    io.print "  - READ  : \n"
    io.print "      ADDR : 0x00000000\n"
    io.print "      ID   : 10\n"
    io.print "      DATA : - ", sprintf("0x%08X", o_address+size), " # O_ADDR[31:00]\n"
    io.print "             - 0x00000000"                         , " # O_ADDR[63:32]\n"                  
    io.print "             - ", sprintf("0x%08X", o_size-size   ), " # O_SIZE[31:00]\n"
    io.print "             - ", sprintf("0x%08X", o_mode | done ), " # O_CTRL[31:00]\n"
    io.print "             - ", sprintf("0x%08X", i_address+size), " # I_ADDR[31:00]\n"
    io.print "             - 0x00000000"                         , " # I_ADDR[63:32]\n"                  
    io.print "             - ", sprintf("0x%08X", i_size-size   ), " # I_SIZE[31:00]\n"
    io.print "             - ", sprintf("0x%08X", i_mode | done ), " # I_CTRL[31:00]\n"
    io.print "      RESP : OKAY\n"
    io.print "  - WRITE : \n"
    io.print "      ADDR : 0x00000000\n"
    io.print "      ID   : 10\n"
    io.print "      DATA : - 0x00000000"                         , " # O_ADDR[31:00]\n"
    io.print "             - 0x00000000"                         , " # O_ADDR[63:32]\n"                  
    io.print "             - 0x00000000"                         , " # O_SIZE[31:00]\n"
    io.print "             - 0x00000000"                         , " # O_CTRL[31:00]\n"
    io.print "             - 0x00000000"                         , " # I_ADDR[31:00]\n"
    io.print "             - 0x00000000"                         , " # I_ADDR[63:32]\n"                  
    io.print "             - 0x00000000"                         , " # I_SIZE[31:00]\n"
    io.print "             - 0x00000000"                         , " # I_CTRL[31:00]\n"
    io.print "      RESP : OKAY\n"
    io.print "  - WAIT  : {GPI(0) : 0, GPI(1) : 0, TIMEOUT: ", @timeout.to_s, "}\n"
    @i_gen.read_byte(io, i_address, data, "OKAY")
    @o_gen.write_byte(io, o_address, data, "OKAY")
  end

  def test_1(io)
    test_num = 0
    [1,2,3,4,5,6,7,8,9,10,16,21,32,49,64,71,85,99,110,128,140,155,189,200,212,234,256].each{|size|
      (0xFC00..0xFC07).each {|i_address|
      (0x1000..0x1007).each {|o_address|
        title = @name.to_s + ".1." + test_num.to_s
        gen1(title, io, i_address, o_address, size, size)
        test_num += 1
      }}
    }
  end

  def test_2(io)
    test_num = 0
    [1,2,3,4,5,6,7,8,9,10,16,21,32,49,64,71,85,99,110,128,140,155,189,200,212,234,256].each{|size|
      (0xFC00..0xFC07).each {|i_address|
      (0x1000..0x1007).each {|o_address|
        title = @name.to_s + ".2." + test_num.to_s
        gen1(title, io, i_address, o_address, size, size+15)
        test_num += 1
      }}
    }
  end

  def test_3(io)
    (1..200).each {|num|  
      title     = @name.to_s + ".3." + num.to_s
      size      = num + 1024
      data      = (1..size).collect{rand(256)}
      o_address = 0x1000+rand(16)
      o_size    = size
      o_mode    = gen_ctrl_regs([:Last,:First,:Done_Enable,:Error_Enable])
      o_mode_sel= rand(10)
      o_mode   |= gen_ctrl_regs([:Speculative]) if (o_mode_sel >= 7)
      o_mode   |= gen_ctrl_regs([:Safety])      if (o_mode_sel <= 2)
      done      = gen_ctrl_regs([:Done])
      start     = gen_ctrl_regs([:Start])
      io.print "---\n"
      io.print "- MARCHAL : \n"
      io.print "  - SAY : ", title, "\n"
      io.print "- CSR : \n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x00000000\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X", o_address     ), " # O_ADDR[31:00]\n"
      io.print "             - 0x00000000"                         , " # O_ADDR[63:32]\n"                  
      io.print "             - ", sprintf("0x%08X", o_size        ), " # O_SIZE[31:00]\n"
      io.print "             - ", sprintf("0x%08X", o_mode | start), " # O_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      count = 0
      first = 1
      last  = 0
      while (count < size) 
        i_address = 0x2000+rand(16)
        i_size    = rand(1023) + 1
        if (count + i_size >= size)
          i_size = size-count
          last   = 1
        end
        i_mode_sel= rand(10)
        i_mode  = gen_ctrl_regs([:Done_Enable,:Error_Enable])
        i_mode |= gen_ctrl_regs([:First]) if (first > 0)
        i_mode |= gen_ctrl_regs([:Last ]) if (last  > 0)
        i_mode |= gen_ctrl_regs([:Speculative]) if (i_mode_sel >= 7)
        i_mode |= gen_ctrl_regs([:Safety])      if (i_mode_sel <= 2)
        io.print "- CSR : \n"
        io.print "  - WRITE : \n"
        io.print "      ADDR : 0x00000010\n"
        io.print "      ID   : 10\n"
        io.print "      DATA : - ", sprintf("0x%08X", i_address     ), " # I_ADDR[31:00]\n"
        io.print "             - 0x00000000"                         , " # I_ADDR[63:32]\n"                  
        io.print "             - ", sprintf("0x%08X", i_size        ), " # I_SIZE[31:00]\n"
        io.print "             - ", sprintf("0x%08X", i_mode | start), " # I_CTRL[31:00]\n"
        io.print "      RESP : OKAY\n"
        io.print "  - WAIT  : {GPI(0) : 1, TIMEOUT: ", @timeout.to_s, "}\n"
        io.print "  - WRITE : \n"
        io.print "      ADDR : 0x0000001C\n"
        io.print "      ID   : 10\n"
        io.print "      DATA : - ", sprintf("0x%08X", i_mode        ), " # I_CTRL[31:00]\n"
        io.print "      RESP : OKAY\n"
        io.print "  - WAIT  : {GPI(0) : 0, TIMEOUT: ", @timeout.to_s, "}\n"
        @i_gen.read_byte(io, i_address, data[count..count+i_size-1], "OKAY")
        count += i_size
        first = 0
      end 
      @o_gen.write_byte(io, o_address, data, "OKAY")
      io.print "- CSR : \n"
      io.print "  - WAIT  : {GPI(1) : 1, TIMEOUT: ", @timeout.to_s, "}\n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x0000000C\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X", o_mode          ), " # O_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      io.print "  - WAIT  : {GPI(1) : 0, TIMEOUT: ", @timeout.to_s, "}\n"
    }
  end

  def test_4(io)
    (1..200).each {|num|  
      title     = @name.to_s + ".4." + num.to_s
      size      = num + 1024
      data      = (1..size).collect{rand(256)}
      i_address = 0x1000+rand(16)
      i_size    = size
      i_mode_sel= rand(10)
      i_mode    = gen_ctrl_regs([:Last,:First,:Done_Enable,:Error_Enable])
      i_mode   |= gen_ctrl_regs([:Speculative]) if (i_mode_sel >= 7)
      i_mode   |= gen_ctrl_regs([:Safety])      if (i_mode_sel <= 2)
      done      = gen_ctrl_regs([:Done])
      start     = gen_ctrl_regs([:Start])
      io.print "---\n"
      io.print "- MARCHAL : \n"
      io.print "  - SAY : ", title, "\n"
      io.print "- CSR : \n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x00000010\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X", i_address     ), " # I_ADDR[31:00]\n"
      io.print "             - 0x00000000"                         , " # I_ADDR[63:32]\n"                  
      io.print "             - ", sprintf("0x%08X", i_size        ), " # I_SIZE[31:00]\n"
      io.print "             - ", sprintf("0x%08X", i_mode | start), " # I_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      @i_gen.read_byte(io, i_address, data, "OKAY")
      count = 0
      first = 1
      last  = 0
      while (count < size) 
        o_address = 0x2000+rand(16)
        o_size    = rand(1023) + 1
        if (count + o_size >= size)
          o_size = size-count
          last   = 1
        end
        o_mode_sel= rand(10)
        o_mode  = gen_ctrl_regs([:Done_Enable,:Error_Enable])
        o_mode |= gen_ctrl_regs([:First]) if (first > 0)
        o_mode |= gen_ctrl_regs([:Last ]) if (last  > 0)
        o_mode |= gen_ctrl_regs([:Speculative]) if (o_mode_sel >= 7)
        o_mode |= gen_ctrl_regs([:Safety])      if (o_mode_sel <= 2)
        io.print "- CSR : \n"
        io.print "  - WRITE : \n"
        io.print "      ADDR : 0x00000000\n"
        io.print "      ID   : 10\n"
        io.print "      DATA : - ", sprintf("0x%08X", o_address     ), " # O_ADDR[31:00]\n"
        io.print "             - 0x00000000"                         , " # O_ADDR[63:32]\n"                  
        io.print "             - ", sprintf("0x%08X", o_size        ), " # O_SIZE[31:00]\n"
        io.print "             - ", sprintf("0x%08X", o_mode | start), " # O_CTRL[31:00]\n"
        io.print "      RESP : OKAY\n"
        io.print "  - WAIT  : {GPI(1) : 1, TIMEOUT: ", @timeout.to_s, "}\n"
        io.print "  - WRITE : \n"
        io.print "      ADDR : 0x0000000C\n"
        io.print "      ID   : 10\n"
        io.print "      DATA : - ", sprintf("0x%08X", o_mode        ), " # O_CTRL[31:00]\n"
        io.print "      RESP : OKAY\n"
        io.print "  - WAIT  : {GPI(1) : 0, TIMEOUT: ", @timeout.to_s, "}\n"
        @o_gen.write_byte(io, o_address, data[count..count+o_size-1], "OKAY")
        count += o_size
        first = 0
      end 
      io.print "- CSR : \n"
      io.print "  - WAIT  : {GPI(0) : 1, TIMEOUT: ", @timeout.to_s, "}\n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x0000001C\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X",i_mode           ), " # I_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      io.print "  - WAIT  : {GPI(0) : 0, TIMEOUT: ", @timeout.to_s, "}\n"
    }
  end

  def test_5(io)
    (1..200).each {|num|  
      title     = @name.to_s + ".5." + num.to_s
      size      = num + 1024
      data      = (1..size).collect{rand(256)}
      m_address = 0x4100
      m_mode    = gen_ctrl_regs([:Done_Enable])
      o_address = 0x1000+rand(16)
      o_size    = size
      o_mode    = gen_ctrl_regs([:Last,:First,:Done_Enable,:Error_Enable])
      o_mode_sel= rand(10)
      o_mode   |= gen_ctrl_regs([:Speculative]) if (o_mode_sel >= 7)
      o_mode   |= gen_ctrl_regs([:Safety])      if (o_mode_sel <= 2)
      done      = gen_ctrl_regs([:Done])
      start     = gen_ctrl_regs([:Start])
      io.print "---\n"
      io.print "- MARCHAL : \n"
      io.print "  - SAY : ", title, "\n"
      io.print "- CSR : \n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x00000000\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X", o_address     ), " # CO_ADDR[31:00]\n"
      io.print "             - 0x00000000"                         , " # CO_ADDR[63:32]\n"                  
      io.print "             - ", sprintf("0x%08X", o_size        ), " # CO_SIZE[31:00]\n"
      io.print "             - ", sprintf("0x%08X", o_mode | start), " # CO_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x00000030\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X", m_address     ), " # PO_ADDR[31:00]\n"
      io.print "             - 0x00000000"                         , " # PO_ADDR[63:32]\n"                  
      io.print "             - 0x00000000"                         , " # PO_MODE[31:00]\n"
      io.print "             - ", sprintf("0x%08X", m_mode | start), " # PO_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      count = 0
      first = 1
      last  = 0
      while (count < size) 
        i_address = 0x2000+rand(16)
        i_size    = rand(1023) + 1
        if (count + i_size >= size)
          i_size = size-count
          last   = 1
        end
        i_mode_sel= rand(10)
        i_mode  = gen_op_code([:Transfer   ])
        i_mode |= gen_op_code([:First      ]) if (first > 0)
        i_mode |= gen_op_code([:Last,:End  ]) if (last  > 0)
        i_mode |= gen_op_code([:Speculative]) if (i_mode_sel >= 7)
        i_mode |= gen_op_code([:Safety     ]) if (i_mode_sel <= 2)
        if (rand(10) <= 1)
            l_address = 0x4000+rand(16)
            l_mode    = m_mode | gen_op_code([:Link])
            @m_gen.read_word(io, m_address, [l_address, 0x00000000, 0x00000000, l_mode], "OKAY")
            m_address = l_address
        end
        @m_gen.read_word(io, m_address, [i_address, 0x0000000, i_size, i_mode], "OKAY")
        @i_gen.read_byte(io, i_address, data[count..count+i_size-1], "OKAY")
        count += i_size
        first = 0
        m_address += 0x10
      end 
      @o_gen.write_byte(io, o_address, data, "OKAY")
      io.print "- CSR : \n"
      io.print "  - WAIT  : {GPI(0) : 1, TIMEOUT: ", @timeout.to_s, "}\n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x0000003C\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X", m_mode          ), " # PI_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      io.print "  - WAIT  : {GPI(0) : 0, TIMEOUT: ", @timeout.to_s, "}\n"
      io.print "  - WAIT  : {GPI(1) : 1, TIMEOUT: ", @timeout.to_s, "}\n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x0000000C\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X", o_mode          ), " # CO_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      io.print "  - WAIT  : {GPI(1) : 0, TIMEOUT: ", @timeout.to_s, "}\n"
    }
  end

  def test_6(io)
    (1..200).each {|num|  
      title     = @name.to_s + ".6." + num.to_s
      size      = num + 1024
      data      = (1..size).collect{rand(256)}
      m_address = 0x4100
      m_mode    = gen_ctrl_regs([:Done_Enable])
      i_address = 0x1000+rand(16)
      i_size    = size
      i_mode_sel= rand(10)
      i_mode    = gen_ctrl_regs([:Last,:First,:Done_Enable,:Error_Enable])
      i_mode   |= gen_ctrl_regs([:Speculative]) if (i_mode_sel >= 7)
      i_mode   |= gen_ctrl_regs([:Safety])      if (i_mode_sel <= 2)
      done      = gen_ctrl_regs([:Done])
      start     = gen_ctrl_regs([:Start])
      io.print "---\n"
      io.print "- MARCHAL : \n"
      io.print "  - SAY : ", title, "\n"
      io.print "- CSR : \n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x00000010\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X", i_address     ), " # CI_ADDR[31:00]\n"
      io.print "             - 0x00000000"                         , " # CI_ADDR[63:32]\n"                  
      io.print "             - ", sprintf("0x%08X", i_size        ), " # CI_SIZE[31:00]\n"
      io.print "             - ", sprintf("0x%08X", i_mode | start), " # CI_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x00000020\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X", m_address     ), " # PO_ADDR[31:00]\n"
      io.print "             - 0x00000000"                         , " # PO_ADDR[63:32]\n"                  
      io.print "             - 0x00000000"                         , " # PO_MODE[31:00]\n"
      io.print "             - ", sprintf("0x%08X", m_mode | start), " # PO_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      @i_gen.read_byte(io, i_address, data, "OKAY")
      count = 0
      first = 1
      last  = 0
      while (count < size) 
        o_address = 0x2000+rand(16)
        o_size    = rand(1023) + 1
        if (count + o_size >= size)
          o_size = size-count
          last   = 1
        end
        o_mode_sel= rand(10)
        o_mode  = gen_op_code([:Transfer   ])
        o_mode |= gen_op_code([:First      ]) if (first > 0)
        o_mode |= gen_op_code([:Last,:End  ]) if (last  > 0)
        o_mode |= gen_op_code([:Speculative]) if (o_mode_sel >= 7)
        o_mode |= gen_op_code([:Safety     ]) if (o_mode_sel <= 2)
        if (rand(10) <= 1)
            l_address = 0x4000+rand(16)
            l_mode    = m_mode | gen_op_code([:Link])
            @m_gen.read_word(io, m_address, [l_address, 0x00000000, 0x00000000, l_mode], "OKAY")
            m_address = l_address
        end
        @m_gen.read_word( io, m_address, [o_address, 0x0000000, o_size, o_mode], "OKAY")
        @o_gen.write_byte(io, o_address, data[count..count+o_size-1]           , "OKAY")
        count += o_size
        first = 0
        m_address += 0x10
      end 
      io.print "- CSR : \n"
      io.print "  - WAIT  : {GPI(0) : 1, TIMEOUT: ", @timeout.to_s, "}\n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x0000001C\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X",i_mode           ), " # PI_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      io.print "  - WAIT  : {GPI(0) : 0, TIMEOUT: ", @timeout.to_s, "}\n"
      io.print "  - WAIT  : {GPI(1) : 1, TIMEOUT: ", @timeout.to_s, "}\n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x0000002C\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X", m_mode          ), " # CO_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      io.print "  - WAIT  : {GPI(1) : 0, TIMEOUT: ", @timeout.to_s, "}\n"
    }
  end

  def test_7(io)
    test_num = 0
    [0x10000].each{|size|
      (0x00012000..0x00012007).each {|i_address|
      (0xFF000000..0xFF000007).each {|o_address|
        title = @name.to_s + ".7." + test_num.to_s
        gen1(title, io, i_address, o_address, size, size)
        test_num += 1
      }}
    }
  end

  def generate
    io = open(@file_name, "w")
    if @test_items == []
      @test_items = [1,2,3,4,5,6]
    end
    if @i_gen == nil
      @i_gen = IOScenarioGenerater.new("I", "READ" , @i_axi4_data_width, @i_max_xfer_size, @i_id)
    end
    if @o_gen == nil
      @o_gen = IOScenarioGenerater.new("O", "WRITE", @o_axi4_data_width, @o_max_xfer_size, @o_id)
    end
    if @m_gen == nil
      @m_gen = IOScenarioGenerater.new("M", "READ" , @m_axi4_data_width, @m_max_xfer_size, @m_id)
    end
    title     = @name.to_s + 
                " I_DATA_WIDTH="  + @i_axi4_data_width.to_s + 
                " O_DATA_WIDTH="  + @o_axi4_data_width.to_s +
                " MAX_XFER_SIZE=" + @i_max_xfer_size.to_s
    io.print "---\n"
    io.print "- MARCHAL : \n"
    io.print "  - SAY : ", title, "\n"
    @test_items.each {|item|
        test_1(io) if (item == 1)
        test_2(io) if (item == 2)
        test_3(io) if (item == 3)
        test_4(io) if (item == 4)
        test_5(io) if (item == 5)
        test_6(io) if (item == 6)
        test_7(io) if (item == 7)
    }
  end
end


gen = ScenarioGenerater.new
gen.parse_options(ARGV)
gen.generate

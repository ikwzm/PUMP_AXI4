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
    def  generate(io, address, data, resp)
      io.print "- ", @name , " : \n"
      pos = 0
      while (pos < data.length)
        len = @max_xfer_size - (address % @max_xfer_size)
        if (pos + len > data.length)
            len = data.length - pos
        end
        io.print "  - ", @command, " : \n"
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
  end

  def initialize
    @program_name      = "make_scenario"
    @program_version   = "0.0.3"
    @i_gen             = nil
    @o_gen             = nil
    @no                = 0
    @id                = 10
    @i_axi4_data_width = 32
    @o_axi4_data_width = 32
    @name              = "PUMP_AXI4_TO_AXI4_TEST"
    @file_name         = "pump_axi4_to_axi4_test_bench_32_32.snr"
    @max_xfer_size     = 64
    @opt               = OptionParser.new do |opt|
      opt.program_name = @program_name
      opt.version      = @program_version
      opt.on("--verbose"             ){|val| @verbose           = true     }
      opt.on("--name     STRING"     ){|val| @name              = val      }
      opt.on("--output   FILE_NAME"  ){|val| @file_name         = val      }
      opt.on("--i_width  INTEGER"    ){|val| @i_axi4_data_width = val.to_i }
      opt.on("--o_width  INTEGER"    ){|val| @o_axi4_data_width = val.to_i }
      opt.on("--max_size INTEGER"    ){|val| @max_xfer_size     = val.to_i }
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
    io.print "  - WAIT  : {GPI(0) : 1, GPI(1) : 1, TIMEOUT: 10000}\n"
    io.print "  - SYNC  : {PORT : LOCAL}\n"
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
    io.print "  - SYNC  : {PORT : LOCAL}\n"
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
    io.print "  - WAIT  : {GPI(0) : 1, GPI(1) : 1, TIMEOUT: 10000}\n"
    io.print "  - SYNC  : {PORT : LOCAL}\n"
    @i_gen.generate(io, i_address, data, "OKAY")
    @o_gen.generate(io, o_address, data, "OKAY")
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
      io.print "  - SYNC  : {PORT : LOCAL}\n"
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
        io.print "  - WAIT  : {GPI(0) : 1, TIMEOUT: 10000}\n"
        io.print "  - SYNC  : {PORT : LOCAL}\n"
        io.print "  - WRITE : \n"
        io.print "      ADDR : 0x0000001C\n"
        io.print "      ID   : 10\n"
        io.print "      DATA : - ", sprintf("0x%08X", i_mode        ), " # I_CTRL[31:00]\n"
        io.print "      RESP : OKAY\n"
        io.print "  - WAIT  : {GPI(0) : 0, TIMEOUT: 10000}\n"
        io.print "  - SYNC  : {PORT : LOCAL}\n"
        @i_gen.generate(io, i_address, data[count..count+i_size-1], "OKAY")
        count += i_size
        first = 0
      end 
      @o_gen.generate(io, o_address, data, "OKAY")
      io.print "- CSR : \n"
      io.print "  - WAIT  : {GPI(1) : 1, TIMEOUT: 10000}\n"
      io.print "  - SYNC  : {PORT : LOCAL}\n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x0000000C\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X", o_mode          ), " # O_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      io.print "  - WAIT  : {GPI(1) : 0, TIMEOUT: 10000}\n"
      io.print "  - SYNC  : {PORT : LOCAL}\n"
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
      @i_gen.generate(io, i_address, data, "OKAY")
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
        io.print "  - WAIT  : {GPI(1) : 1, TIMEOUT: 10000}\n"
        io.print "  - SYNC  : {PORT : LOCAL}\n"
        io.print "  - WRITE : \n"
        io.print "      ADDR : 0x0000000C\n"
        io.print "      ID   : 10\n"
        io.print "      DATA : - ", sprintf("0x%08X", o_mode        ), " # O_CTRL[31:00]\n"
        io.print "      RESP : OKAY\n"
        io.print "  - WAIT  : {GPI(1) : 0, TIMEOUT: 10000}\n"
        io.print "  - SYNC  : {PORT : LOCAL}\n"
        @o_gen.generate(io, o_address, data[count..count+o_size-1], "OKAY")
        count += o_size
        first = 0
      end 
      io.print "- CSR : \n"
      io.print "  - WAIT  : {GPI(0) : 1, TIMEOUT: 10000}\n"
      io.print "  - SYNC  : {PORT : LOCAL}\n"
      io.print "  - WRITE : \n"
      io.print "      ADDR : 0x0000001C\n"
      io.print "      ID   : 10\n"
      io.print "      DATA : - ", sprintf("0x%08X",i_mode           ), " # I_CTRL[31:00]\n"
      io.print "      RESP : OKAY\n"
      io.print "  - WAIT  : {GPI(0) : 0, TIMEOUT: 10000}\n"
      io.print "  - SYNC  : {PORT : LOCAL}\n"
    }
  end

  def generate
    io = open(@file_name, "w")
    if @i_gen == nil
      @i_gen = IOScenarioGenerater.new("I", "READ" , @i_axi4_data_width, @max_xfer_size, 1)
    end
    if @o_gen == nil
      @o_gen = IOScenarioGenerater.new("O", "WRITE", @o_axi4_data_width, @max_xfer_size, 2)
    end
    title     = @name.to_s + 
                " I_DATA_WIDTH="  + @i_axi4_data_width.to_s + 
                " O_DATA_WIDTH="  + @o_axi4_data_width.to_s +
                " MAX_XFER_SIZE=" + @max_xfer_size.to_s
    io.print "---\n"
    io.print "- MARCHAL : \n"
    io.print "  - SAY : ", title, "\n"
    test_1(io)
    test_2(io)
    test_3(io)
    test_4(io)
  end
end


gen = ScenarioGenerater.new
gen.parse_options(ARGV)
gen.generate

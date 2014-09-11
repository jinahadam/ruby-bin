class BinParser
  #port of https://gist.github.com/jinahadam/a3fcd82166fd5b5bb72f
  
  
  HEAD_BYTE1 = 0xA3
  HEAD_BYTE2 = 0x95
  
  
   def initialize(uri)
    
     file = File.open(uri) 
     log_step = 0
     file.each_byte { |c| 
       
       case log_step
       when 0
         if c == HEAD_BYTE1
           log_step = log_step + 1
         end
       when 1
         if c == HEAD_BYTE2
           log_step = log_step + 1
         else
           log_step = 0
         end
       when 2
         log_step = 0
         line = log_entry(c,file)
         #print c, ' ' 
       else
         puts "bad binary" 
       end
       
     }
     
   end
   
   
   def log_entry(packettype,file)
     case packettype
     when 0x80 #FMT
       len = 86
       
       data = file.read(len)
       type =  data[0..1].unpack('C')[0]
       length =  data[1..2].unpack('C')[0]
       name = data[2..5].unpack('Z*')[0]
       format = data[5..21].unpack('M*')[0]
       labels = data[21..86].unpack('M*')[0].delete('\0')
       
       puts "FMT, #{type}, #{length}, #{name}, #{format}, #{labels}"

     else
     
     end
   end
   

    
   
    
end
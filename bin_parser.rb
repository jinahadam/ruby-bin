require 'debugger'

class BinParser
  #port of https://gist.github.com/jinahadam/a3fcd82166fd5b5bb72f
  
  HEAD_BYTE1 = 0xA3
  HEAD_BYTE2 = 0x95
  
  attr_accessor :logformat, :lines
  
   def initialize(uri)
    
     file = File.open(uri) 
     log_step = 0
     @logformat = []
     @lines = []
     
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
   
   def lines
     @lines
   end
   
   def log_entry(packettype,file)
     type = ""
     
     case packettype
     when 0x80 #FMT
       len = 86
       
       data = file.read(len)
       type =  data[0..1].unpack('C')[0]
       length =  data[1..2].unpack('C')[0]
       name = data[2..5].unpack('Z*')[0]
       format = data[5..21].unpack('M*')[0]
       labels = data[21..86].unpack('M*')[0].delete('\0')

       lg = Hash.new
       lg[:name]= name
       lg[:type]= type
       lg[:format] = format
       lg[:length] = length
       
      # if lg[:name] == "GPS" ||  lg[:name] == "ATT" 
         @logformat << lg
      # end
       @lines << "FMT, #{type}, #{length}, #{name}, #{format}, #{labels}"
       
     else 
       format = ""
       name = ""
       size = 0
       
       
       @logformat.each do |item|
        # puts item[:name]
        if item[:type] == packettype
        #  puts "match"
          name = item[:name]
          format = item[:format]
          size = item[:length]   
         # puts "#{size} >>> length"
          #break  
          if size != 0 
             @lines << process_message(file.read(size -2), name, format)
          end
             
        end
        
       
        
       end
     end
   end
   
   
   
   def process_message(message, name, format) 
     offset = 0
     line = "#{name}"
     format.split("").each do |item|
        case item
        when 'b'
          line = "#{line}, #{message[offset..message.length-1].unpack('C')[0]}"
          offset = offset + 1
        when 'B'
          line = "#{line}, #{message[offset..message.length-1].unpack('C')[0]}"
          offset = offset + 1          
        when 'h' #BitConverter.ToInt16
          line = "#{line}, #{int16_t(offset,message)}"
          offset = offset + 2
        when 'H' #BitConverter.ToUInt16
          line = "#{line}, #{uint16_t(offset,message)}"
          offset = offset + 2
        when 'i' #BitConverter.ToInt32
          line = "#{line}, #{int32_t(offset,message)}"
          offset = offset + 4
        when 'I' #BitConverter.ToUInt32
         line = "#{line}, #{uint32_t(offset,message)}"
         offset = offset + 4
        when 'f' #BitConverter.ToSingle
          line = "#{line}, #{float(offset,message)}"
          offset = offset + 4
        when 'c' #BitConverter.ToInt16
          line = "#{line}, #{int16_t(offset,message)}"
          offset = offset + 2
        when 'C' #BitConverter.ToUInt16
          line = "#{line}, #{uint16_t(offset,message)}"
          offset = offset + 2
        when 'e' #BitConverter.ToInt32 
          line = "#{line}, #{int32_t(offset,message).to_f/100}"
          offset = offset + 4
        when 'E' #BitConverter.ToUInt32 
          line = "#{line}, #{uint32_t(offset,message).to_f/100}"
          offset = offset + 4
        when 'L' #(double)BitConverter.ToInt32
          line = "#{line}, #{int32_t(offset,message).to_f/10000000}"
          offset = offset + 4 
        when 'n' #ASCIIEncoding.ASCII.GetString
          line = "#{line}, #{string(offset,message)}"
          offset = offset + 4 
        when 'N' #ASCIIEncoding.ASCII.GetString
          line = "#{line}, #{string(offset,message)}"
          offset = offset + 16 
        when 'M' 
        when 'Z' #ASCIIEncoding.ASCII.GetString
          line = "#{line}, #{string(offset,message)}"
          offset = offset + 64 
        else
        end
     end
     
     line  
   end
   
   def float(offset,message)
      result = 0
      if message[offset..message.length-1] != nil       
        result = message[offset..message.length-1].unpack('e')[0]
      end
      result
   end

   def int8_t(offset,message)
     result = 0
     if message[offset..message.length-1] != nil       
       result = message[offset..message.length-1].unpack('c')[0]
     end
     result
   end

   def uint8_t(offset,message)
     result = 0
     if message[offset..message.length-1] != nil       
       result = message[offset..message.length-1].unpack('C')[0]
     end
     result
   end

   def int16_t(offset,message)
     result = 0
     if message[offset..message.length-1] != nil       
       result = message[offset..message.length-1].unpack('s<')[0]
     end
     result
   end

   def uint16_t(offset,message)
     result = 0
     if message[offset..message.length-1] != nil       
       result = message[offset..message.length-1].unpack('S<')[0]
     end
     result
   end

   def int32_t(offset,message)
     result = 0
     if message[offset..message.length-1] != nil       
       result = message[offset..message.length-1].unpack('l<')[0]
     end
     result
   end

   def uint32_t(offset,message)
     result = 0
     if message[offset..message.length-1] != nil       
       result = message[offset..message.length-1].unpack('L<')[0]
     end
     result  
   end

   def uint64_t(offset,message)
     result = 0
     if message[offset..message.length-1] != nil       
       result = message[offset..message.length-1].unpack('Q<')[0]
     end
     result    
   end

   def string(offset,message)
     result = 0
     if message[offset..message.length-1] != nil       
       result = message[offset..message.length-1].unpack('Z*')[0]
     end
     result   
   end
  
end
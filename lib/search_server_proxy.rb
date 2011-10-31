require 'timeout'

module XNavi
  class Config
    attr_accessor :server_host, :port
  end
  
  class SearchServerProxy
    @@config = XNavi::Config.new
    @@instance = nil
    
    def self.config
      @@config
    end
    
    def self.instance
      @@instance = self.new if @@instance.nil?
      @@instance
    end

    def initialize

      @socket = nil
      connect
    end
    
    def correct(word, city)
      return nil if word.nil? or word.blank?
      try_times = 0
      utf_gbk = Iconv.new 'GBK', 'utf-8'
      begin
        ++ try_times
        puts try_times
        connect
        unless @socket.nil?
          word_to_output = utf_gbk.iconv(word)
          puts word_to_output.unpack("C#{word_to_output.length}").join(',')
          puts "#{word_to_output}|#{city.id}"
          timeout(20) do
            @socket.puts "#{word_to_output}|#{city.id}"
          end
        end
      rescue Exception => ex
        puts ex.message
        @socket.close
        @socket = nil
        retry if try_times <= 1
      rescue TimeoutError
        @socket.close
        @socket = nil?
        retry if try_times <= 1
      end
      return nil if @socket.nil?
      gbk_utf = Iconv.new 'utf-8', 'GBK'
      begin
        timeout(20) do
          result = @socket.gets
        end
      rescue TimeoutError
        @socket=nil
        return word
      end
      #puts "result without chop is #{result}"
      #puts result.unpack("C#{result.length}").join(",")

      result = gbk_utf.iconv(result)
      result.chop!
      #puts result.unpack("C#{result.length}").join(",")
     #puts "result length is #{result.length}"
      #puts "result = #{result}"
      @socket = nil
      return result
    end
    
    private
    def connect
      return unless @socket.nil? 
      begin
        @socket = TCPSocket.open @@config.server_host, @@config.port
      rescue Exception => ex
        @socket = nil
        puts ex.message
      end
    end
  end
end

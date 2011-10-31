require 'fileutils'
require 'RMagick' 
                 
module Imon
  class ImageSpliter          
    BLOCK_WIDTH = 256
    BLOCK_HEIGHT = 256
    include Magick

    def initialize(options={})          
      @options = {:dest_path => '.',
                 :block_width => BLOCK_WIDTH,
                 :block_height => BLOCK_HEIGHT }.merge(options)
    end           
  
    def split(file_path)
      dir = @options[:dest_path]    
      FileUtils.mkdir_p(dir) unless File.exist?(dir)
      @image=Image::read(file_path).first
      block_width = @options[:block_width]
      block_height = @options[:block_height]
      0.step(@image.columns-1, block_width) do |x|
        0.step(@image.rows-1, block_height) do |y|
          img=@image.crop x,y, block_width, block_height
          file_name= File.join(@options[:dest_path], "x#{x/block_width}_y#{y/block_height}.jpg")
          img.write(file_name) { self.quality=40 }
        end  
      end
    end
  end        

end

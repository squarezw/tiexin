class Captcha

    require 'RMagick' 
    include Magick
                             
    CAPTCHA_CHARS='345678ABCEFGHJKLMNPQRTUVWXY'
    CHARS_NUM=CAPTCHA_CHARS.length

    attr_reader :code, :code_img
    
    def initialize(len)
      canvas=Image.new(140, 50)
      x=0

      text=Draw.new
      text.font_family='arial'
      text.gravity=CenterGravity
      text.stroke_linejoin 'round'
      text.stroke_linecap 'round'
      
      @code=''
      
      len.times do
        ch=CAPTCHA_CHARS[rand(CHARS_NUM)].chr
        y=rand(30)-10
        text.annotate(canvas, 40, 50, x, y, ch) { 
          self.pointsize=25+rand(15)
          self.fill="rgb(#{rand(150)}, #{rand(150)}, #{rand(150)})"
          self.font_weight=(rand(7)+1)*100
          self.rotation=rand(20)-10
          self.density='100x50'
        }                           
        x = x+30
        
        @code << ch
      end       

      canvas=canvas.wave(10, 120+rand(20)-10).swirl(10).frame(4,4,4,4,0,0)
   
      @code_img=canvas.to_blob { self.format='JPG' }
    end      
    
    def valid?(code)
      @code == code.upcase
    end
end
module XNavi
  class Coordinate
    COORDINATE_PER_KM = 130005.2
    
    attr_reader :x, :y
    
    def initialize(x, y=nil)
      if x.is_a?(Hash) 
        @x, @y = x[:x].to_s.to_f, x[:y].to_s.to_f
      else
        @x, @y = x, y
      end
    end
    
    # Caculate coordinate of northwest and southeast point of the rectangle which use self as center point and '2*scope' as side length
    def arround_square(scope = 1)
      sl = scope * COORDINATE_PER_KM
      return [XNavi::Coordinate.new(@x - sl, @y - sl), XNavi::Coordinate.new(@x+sl, @y+sl)]
    end
    
    def distance_to(point)
      Math.sqrt( ((@x - point.x) * 0.007692) ** 2 + ((@y-point.y) * 0.007692) ** 2)
    end
    
    def [](idx)
      case idx
      when 0
        return @x
      when 1
        return @y
      else
        raise ArgumentError, "index out of bounds."
      end
    end
    
    def to_s
      "(#{@x}, #{@y})"
    end
  end
end
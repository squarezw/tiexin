module Imon
  class LatitudeLongitude
    LATITUDE_PER_KM = 0.00854700854700854700
    LONGITUDE_PER_KM = 0.01041666666666666666
    
    attr_reader :latitude
    attr_reader :longitude
    
    def initialize(a, b=nil)
      if a.is_a?(Hash)
        @latitude = a[:latitude].to_f
        @longitude = a[:longitude].to_f
      else
        @latitude = a.to_f
        @longitude = b.to_f
      end
    end
    
    # caculate the latitudes and longitudes of NW and SE point of a square, which use this point as center and scope as side length
    # the result is in an array.
    # the unit of side_lenght is KM.
    def square(side_length)
      lat_min = latitude - LATITUDE_PER_KM * side_length / 2
      lat_max = latitude + LATITUDE_PER_KM * side_length / 2
      lng_min = longitude - LONGITUDE_PER_KM * side_length / 2
      lng_max = longitude + LONGITUDE_PER_KM * side_length / 2
      return [LatitudeLongitude.new(lat_max, lng_min), LatitudeLongitude.new(lat_min, lng_max)]
    end

    def to_s
      return "(#{@latitude}, #{@longitude})"
    end
    
    def [](idx)
      case idx
      when 0
        @latitude
      when 1
        @longitude
      else
        raise ArgumentError
      end
    end

  end # class LatitudeLongitude
  
end



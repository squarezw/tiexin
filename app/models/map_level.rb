class MapLevel < ActiveRecord::Base
  belongs_to :city
  
  def map_block_contains(point)
    block_width, block_height = block_size
    row = (point[1] / block_height).to_i
    column = (point[0] / block_width).to_i
    {  :no => self.no,
       :x => column,
       :y => row,
       :nw_x => (block_width * column).to_i,
       :nw_y => (block_height * row).to_i,
       :width => block_width,
       :height => block_height }    
  end
  
  def map_block_contains?(map_block, point)
    (map_block[:nw_x]..(map_block[:nw_x] + map_block[:width])).include?(point[0]) &&
    (map_block[:nw_y]..(map_block[:nw_y] + map_block[:height])).include?(point[1])
  end
  
  def map_block_at(column, row)
    block_width, block_height = block_size
    {
      :no => self.no,
      :x => column,
      :y => row,
      :nw_x => (block_width * column).to_i,    
      :nw_y => (block_height * row).to_i, 
      :width => block_width,
      :height => block_height 
    }
  end
  
  private
  def block_size
    return [self.city.width.to_f / self.column, 
            self.city.height.to_f / self.row]
  end
end

class AddCityShanghai < ActiveRecord::Migration
  def self.up
    City.create(:name_zh_cn=>'上海', 
                :name_en=>'Shanghai',
                :width=>20784655,
                :height=>20683967,
                :x0 => 13410777.44,
                :y0 => 3748128.75,
                :start_point_x => 11074101,
                :start_point_y => 10725247)
  end

  def self.down
    City.find(2).destroy 
  end
end

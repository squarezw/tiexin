class CreateCities < ActiveRecord::Migration           
  class City < ActiveRecord::Base; end  
    
  def self.up  
    create_table :cities, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true  do |t|  
      t.column  :name_en,    :string,    :limit => 180 
      t.column  :name_zh_cn, :string,    :limit => 180
      # 在X-Navi坐标系中，该城市地图范围的宽度（东西方向）和高度（南北方向）
      t.column  :width,  :integer
      t.column  :height, :integer
    end                                    
    
    City.create(:name_zh_cn=>'北京', 
                :name_en=>'Beijing',
                :width=>47754452,
                :height=>47583359)
  end

  def self.down             
    drop_table :cities       
  end
end

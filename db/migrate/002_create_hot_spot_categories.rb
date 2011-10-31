class CreateHotSpotCategories < ActiveRecord::Migration
  def self.up    
    create_table :hot_spot_categories, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true do |t|                                                                                              
      t.column    :name_en,      :string,      :limit=>60
      t.column    :name_zh_cn,   :string,      :limit=>60 
      t.column    :parent_id, :integer
      t.column    :icon,      :string
      t.column    :icon_mime_type, :string
      t.column    :icon_filesize,  :string          
    end
    
    HotSpotCategory.create(:name_zh_cn=>'交通', :parent_id => nil )
    HotSpotCategory.create(:name_zh_cn=>'景点', :parent_id => nil )
    HotSpotCategory.create(:name_zh_cn=>'住宿', :parent_id => nil )
    HotSpotCategory.create(:name_zh_cn=>'办公', :parent_id => nil )
    HotSpotCategory.create(:name_zh_cn=>'购物', :parent_id => nil )
    HotSpotCategory.create(:name_zh_cn=>'餐饮', :parent_id => nil )
    HotSpotCategory.create(:name_zh_cn=>'休闲', :parent_id => nil )
    HotSpotCategory.create(:name_zh_cn=>'金融', :parent_id => nil )
    HotSpotCategory.create(:name_zh_cn=>'医药', :parent_id => nil )
    HotSpotCategory.create(:name_zh_cn=>'机构', :parent_id => nil )
    HotSpotCategory.create(:name_zh_cn=>'出行', :parent_id => nil )
  end

  def self.down   
    drop_table :hot_spot_categories
  end
end
                                               
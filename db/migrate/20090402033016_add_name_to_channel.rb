class AddNameToChannel < ActiveRecord::Migration
  def self.up
    add_column :channels, :name_zh_cn, :string, :limit=>60
    add_column :channels, :name_en, :string, :limit=>60
    Channel.find(:all).each { |channel| 
      channel.name_zh_cn = channel.hot_spot_category.name_zh_cn
      channel.name_en = channel.hot_spot_category.name_en
      channel.save(false)
    }
    
    change_column :channels, :name_zh_cn, :string, :null=>false
    change_column :channels, :name_en, :string, :null=>false
  end

  def self.down
  end
end

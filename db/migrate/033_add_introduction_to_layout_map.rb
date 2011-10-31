class AddIntroductionToLayoutMap < ActiveRecord::Migration
  def self.up
    add_column :layout_maps, :introduction_zh_cn, :string, :limit=>3000
    add_column :layout_maps, :introduction_en, :string, :limit=>3000
  end

  def self.down
    remove_column :layout_maps, :introduction_zh_cn
    remove_column :layout_maps, :introduction_en    
  end
end

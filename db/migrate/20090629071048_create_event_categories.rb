class CreateEventCategories < ActiveRecord::Migration
  def self.up
    create_table :event_categories, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true  do |t|
      t.string :name_zh_cn, :limit=>60
      t.string :name_en, :limit=>60
      t.timestamps
    end
    EventCategory.create :name_zh_cn=>'文娱演出', :name_en=>'Show'
    EventCategory.create :name_zh_cn=>'体育比赛', :name_en=>'Sports Game'
    EventCategory.create :name_zh_cn=>'展览会', :name_en=>'Exhibition'
    EventCategory.create :name_zh_cn=>'旅游活动', :name_en=>'Tourism Event'
    EventCategory.create :name_zh_cn=>'电影', :name_en=>'Cinema'
    EventCategory.create :name_zh_cn=>'促销', :name_en=>'Promotion'
  end

  def self.down
    drop_table :event_categories
  end
end

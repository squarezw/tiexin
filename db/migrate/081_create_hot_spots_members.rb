class CreateHotSpotsMembers < ActiveRecord::Migration
  def self.up
    #多对多关系表-中间表
    create_table :hot_spots_members,:id => false, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :hot_spot_id,:int,:null => false        #对应城市id
      t.column :member_id,:int,:null => false   #对应促销信息id
    end
  end

  def self.down
    drop_table :hot_spots_members
  end
end

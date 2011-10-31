class CreateHotSpotTags < ActiveRecord::Migration
  def self.up
    create_table :hot_spot_tags, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :tag, :string
      t.column :description, :string, :limit=>3000
      t.column :member_id, :integer
      t.column :hot_spot_id, :integer, :null=>false
      t.column :created_at,   :datetime
      t.column :updated_at,   :datetime
    end
  end

  def self.down
    drop_table :hot_spot_tags
  end
end

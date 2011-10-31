class CreateRecommendedTags < ActiveRecord::Migration
  def self.up
    create_table :recommended_tags, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.string :tag, :limit=>255, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :recommended_tags
  end
end

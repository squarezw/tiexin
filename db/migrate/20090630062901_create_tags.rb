class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.string :tag, :limit=>90, :null=>false
    end
  end

  def self.down
    drop_table :tags
  end
end

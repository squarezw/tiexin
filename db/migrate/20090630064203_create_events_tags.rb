class CreateEventsTags < ActiveRecord::Migration
  def self.up
    create_table :events_tags, :id=>false, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.integer :event_id, :null=>false
      t.integer :tag_id, :null=>false
    end
    
  end

  def self.down
    drop_table :events_tags
  end
end

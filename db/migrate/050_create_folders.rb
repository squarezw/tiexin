class CreateFolders < ActiveRecord::Migration
  def self.up
    create_table :folders,:options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :name, :string, :limit=>90, :null=>false
      t.column :member_id, :integer, :null=>false
    end
  end

  def self.down
    drop_table :folders
  end
end

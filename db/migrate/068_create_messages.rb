class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true  do |t|
      t.column :from_id, :integer,:null=>false
      t.column :to_id, :integer,:null=>false
      t.column :title, :string, :limit=>300, :null=>false
      t.column :content, :string, :limit=>3000
      t.column :readed, :boolean, :null=>false, :default=>false
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :messages
  end
end

class CreateIpSources < ActiveRecord::Migration
  def self.up
    create_table :ip_sources, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.decimal :ip_begin, :null=>false, :precision=>11
      t.decimal :ip_end, :null=>false, :precision=>11
      t.integer :city_id 
      t.string :source
    end
    add_index :ip_sources, [:ip_begin, :ip_end]
  end

  def self.down
    drop_table :ip_sources
  end
end

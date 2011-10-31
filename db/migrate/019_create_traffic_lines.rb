class CreateTrafficLines < ActiveRecord::Migration
  def self.up
    create_table :traffic_lines, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true  do |t|
      t.column :name_zh_cn,     :string, :limit=>300
      t.column :name_en,        :string, :limit=>300
      t.column :line_type,     :integer, :default=>1, :null=>false
      t.column :introduction_zh_cn, :string, :limit=>3000
      t.column :introduction_en, :string, :limit=>3000
    end
  end

  def self.down
    drop_table :traffic_lines
  end
end

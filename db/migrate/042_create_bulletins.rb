class CreateBulletins < ActiveRecord::Migration
  def self.up
    create_table :bulletins, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :title, :string, :limit=>90, :null=>false
      t.column :language, :string, :limit=>10, :null=>false, :default=>'zh_cn'
      t.column :content, :text
      t.column :expire_date, :date
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :bulletins
  end
end

class CreateArticlesHotSpots < ActiveRecord::Migration
  def self.up
    create_table :articles_hot_spots,:id => false, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column :article_id,:int,:null => false
      t.column :hot_spot_id,:int,:null => false
    end
  end

  def self.down
    drop_table :articles_hot_spots
  end
end

class CreateCampaigns < ActiveRecord::Migration
  def self.up
    create_table :campaigns, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.string :name, :limit=>300, :null=> false
      t.integer :trigger, :null=>false, :default=>1
      t.integer :bonus_experience, :default=> 0
      t.integer :bonus_credit, :default=> 0
      t.date    :expire_date, :null=>false
      t.string :confirm_message, :limit=>1000, :null=>false
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :campaigns
  end
end

class CreateCouponTemplates < ActiveRecord::Migration
  def self.up
    create_table :coupon_templates, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.string :content, :limit=>90, :null=>false
    end
  end

  def self.down
    drop_table :coupon_templates
  end
end

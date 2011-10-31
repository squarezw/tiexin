class CreatePromotions < ActiveRecord::Migration
  def self.up
    create_table :promotions, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t| 
        t.column      :vendor_type, :string, :limit => 20, :null => true
        t.column      :vendor_id,    :integer
        t.column      :member_id,    :integer
        t.column      :summary_en,   :string, :limit=>3000, :null=>false
        t.column      :summary_zh_cn,:string, :limit=>3000, :null=>false
        t.column      :content_en,   :text
        t.column      :content_zh_cn,:text
        t.column      :begin_date,   :datetime   #开始日期
        t.column      :end_date,     :datetime   #结束日期
        t.column      :banner,       :string, :limit => 500
        t.column      :created_at,   :datetime
        t.column      :updated_at,   :datetime
    end
  end

  def self.down
    drop_table :promotions
  end
end

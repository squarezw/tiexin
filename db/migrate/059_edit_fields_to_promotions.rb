class EditFieldsToPromotions < ActiveRecord::Migration
  def self.up
    change_column :promotions, :begin_date, :date
    change_column :promotions, :end_date, :date
  end

  def self.down
  end
end

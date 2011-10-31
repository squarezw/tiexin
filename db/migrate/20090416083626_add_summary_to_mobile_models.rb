class AddSummaryToMobileModels < ActiveRecord::Migration
  def self.up
    add_column :mobile_models, :summary,  :string, :limit=>3000
  end

  def self.down
    remove_column :mobile_models, :summary
  end
end

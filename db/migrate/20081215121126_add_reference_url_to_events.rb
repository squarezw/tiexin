class AddReferenceUrlToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :reference_url, :string, :limit=>2048
  end

  def self.down
    remove_column :events, :reference_url
  end
end

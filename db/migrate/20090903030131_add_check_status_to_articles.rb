class AddCheckStatusToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :check_status, :integer, :default=>0
    execute 'update articles set check_status = 1'
  end

  def self.down
    remove_column :articles, :check_status
  end
end

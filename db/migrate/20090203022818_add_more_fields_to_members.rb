class AddMoreFieldsToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :used_experience, :integer, :default=>0
    add_column :members, :used_credit, :integer, :default=> 0
    add_column :members, :city, :string, :limit=>200
    add_column :members, :address, :string, :limit=>900
    add_column :members, :post_code, :string, :limit=>10
    add_column :members, :phone_number2, :string, :limit=>15
    add_column :members, :real_name, :string, :limit=>300
    add_column :members, :certificate_type, :string, :limit=>90
    add_column :members, :certificate_no, :string, :limit=>30
  end

  def self.down
    remove_column :members, :used_experience
    remove_column :members, :used_credit
    remove_column :members, :city
    remove_column :members, :address
    remove_column :members, :post_code
    remove_column :members, :phone_number2
    remove_column :members, :real_name
    remove_column :members, :certificate_type
    remove_column :members, :certificate_no
    
  end
end

class CreateTabooWords < ActiveRecord::Migration
  def self.up 
    create_table :taboo_words, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force => true do |t|               
      t.column  :word,      :string,    :limit=>30, :null=>false
      t.column  :regexp,    :string,    :limit=>180
      t.column  :active,    :boolean,   :default=>true   
    end 
  end

  def self.down
    drop_table :taboo_words
  end
end

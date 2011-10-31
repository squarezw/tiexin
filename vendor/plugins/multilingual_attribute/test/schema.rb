ActiveRecord::Schema.define :version => 0 do
  create_table :attribute_holders, :force => true do |t|     
    t.column :name_en,      :string
    t.column :name_jp,      :string
    t.column :name_zh_CN,   :string
  end
end


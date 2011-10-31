class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members, :options => 'ENGINE InnoDB DEFAULT CHARSET=UTF8', :force=>true do |t|
      t.column  :login_name,    :string,    :null=>false                      #登录名
      t.column  :password_hash,     :string,    :null=>false                      #密码
      t.column  :mail,          :string,    :null=>false                      #电子邮件(登录名)
      t.column  :nick_name,     :string                                       #昵称
      t.column  :created_at,     :datetime,  :null=>false      #注册时间
      t.column  :is_admin,      :boolean, :default=>false, :null=>false
      t.column  :confirmed,      :boolean, :default=>false
    	t.column  :confirm_code,   :string, :limit=>100    
    	t.column  :favorite_lang,  :string, :limit=>5
      t.column  :logo,           :string,  :limit=>255
      t.column  :logo_mime_type, :string, :limit=>50
    end
    Member.create(:mail=>'admin@x-navi.com',
                  :password=>'password',
                  :nick_name=>'admin',
                  :login_name=>'admin',
                  :is_admin => true,
                  :confirmed => true  )   
  end

  def self.down
    drop_table :members
  end
end

class Partner < ActiveRecord::Base
  has_password
  
  validates_presence_of :name
  validates_length_of :name, :maximum=>100, :allow_nil=>true
  validates_uniqueness_of :name
  validates_presence_of :code
  validates_length_of :code, :maximum=>8, :allow_nil=>true
  validates_uniqueness_of :code
  validates_presence_of :phone_number
  validates_length_of :phone_number, :maximum=>20, :allow_nil=>true
  validates_length_of :contact_person, :maximum=>20, :allow_nil=>true
  validates_length_of :mail, :maximum=>50, :allow_nil=>true
  validates_presence_of :password, :on => :create
  validates_length_of :password, :within => 6..15, :allow_nil=>true
  validates_format_of :password, :with=> /^([_\-.A-z0-9]*)$/, :message=> N_('contains invalid character'), :allow_nil=>true 
  
  def self.login(code, password)
    self.find_by_code_and_password_hash(code, Imon::ActiveRecord::Password::encrypt(password))
  end
  
  
end

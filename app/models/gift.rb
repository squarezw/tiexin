class Gift < ActiveRecord::Base
  QUANTITY_UNLIMITED = -1
  
  attr_protected :sold_quantity, :booked_quantity
  
  has_many   :photos, :as => :owner, :class_name=>'NaviPhoto', :dependent=>:destroy
  has_many   :comments, :as => :commentable, :dependent=>:delete_all
  belongs_to :partner
  
  image_column :picture,
    :versions => {:thumb=>'128x128'},
    :force_format => 'jpg',
    :store_dir => 
       proc { |inst, attr| 
         time = inst.created_at.nil? ? Time.now : inst.created_at
         File.join(time.year.to_s, time.month.to_s, time.day.to_s,
         ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
       },
    :filename=> proc{|inst, original, ext| original + ( ext.blank? ? '' : ".#{ext}" ).downcase },
    :validate_integrity=>true
  
  validates_presence_of :name
  validates_length_of :name, :maximum=>100, :allow_nil=>true
  validates_presence_of :description
  validates_numericality_of :experience, :only_integer=>true, :greater_than_or_equal_to => 0, :message=>_('Must be zero or positive integer.')
  validates_numericality_of :credit, :only_integer=>true, :greater_than_or_equal_to => 0, :message=>_('Must be zero or positive integer.')
  validates_numericality_of :cash, :greater_than_or_equal_to => 0, :message=>_('Must be zero or positive number.')
  validates_numericality_of :delivery_fee, :greater_than_or_equal_to => 0, :message=>_('Must be zero or positive integer.')
  validates_numericality_of :total_quantity, :only_integer=>true, :greater_than_or_equal_to => -1, :message=>_('Must be zero or positive integer, or -1 for unlimited quantity.')
  validates_numericality_of :reference_price, :message=>_('Must be zero or positive integer.')

  def initialize(attributes={})
    default_values = { "experience" => 0,
            "credit" => 0,
            "cash" => 0,
            "delivery_fee" => 0,
            "total_quantity" => QUANTITY_UNLIMITED }
    super default_values.merge(attributes)
    self.total_quantity = 0
    self.sold_quantity = 0
  end
  
  def before_save
    self.delivery_fee = 0 if self.support_deliver_method == GiftOrder::DELIVER_FETCH
  end
  
  def validate
    if (self.experience.nil? or self.experience == 0) and 
       (self.credit.nil? or self.credit == 0) and
       (self.cash.nil? or self.cash == 0)
      errors.add :bonus_experience, _('Experience, credit and cash can not be 0 at same time.')
    end
  end
  
  
end

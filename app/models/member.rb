require 'digest/sha1'    
require 'xnavi_exceptions'

class Member < ActiveRecord::Base  
  LOCK_TIME_OPTIONS= [[_('One Day'), 1.day],
                      [_('Three Days'), 3.day],
                      [_('Ten Days'), 10.day],
                      [_('Ten Years'), 10.year]]
  DEFAULT_LOCK_TIME= 3.day

  FAVORITE_OPEN_OPTIONS= [[_('Private'), 1],
                      [_('Open Only To Friends'), 2],
                      [_('Open All'), 3]]
  DEFAULT_FAVORITE_OPEN= 1
  
  CAPABILITY_MARKED_HOT_SPOT = 1
  CAPABILITY_OWNED_HOT_SPOT = 2
  CAPABILITY_OWNED_BRAND = 3
  CAPABILITY_FRIEND_RECOMMENDATIONS = 4
  CAPABILITY_RECEIVED_MESSAGE = 5
  CAPABILITY_UNREAD_MESSAGE = 6
  CAPABILITY_FAVORITES = 7
 
  PRIVILEGES = [:modify_hot_spot, :approve_hot_spot, :manage_member, :manage_forum, :manage_blog, :manage_brand, :manage_area, :manage_events, :manage_gift_orders, :manage_coupons, :edit_daily_content]

  N_('modify_hot_spot')
  N_('approve_hot_spot')
  N_('manage_member')
  N_('manage_forum')
  N_('manage_blog')
  N_('manage_brand')
  N_('manage_area')
  N_('manage_events')
  N_('manage_gift_orders')
  N_('manage_coupons')
  N_('edit_daily_content')
  
  has_password     
                  
  image_column :logo, 
               :old_files => :delete,
               :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                        ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    },
                :filename=> proc{|inst, original, ext| original + ( ext.blank? ? '' : ".#{ext}" ).downcase },
                :validate_integrity=>true
  
  belongs_to :city_for_mobile, :class_name => 'City', :foreign_key => 'city_for_mobile' 
#  belongs_to :inviter, :class_name=>"Member", :foreign_key => 'inviter_id'
  belongs_to :invitation
  belongs_to :inviter, :class_name=>'Member', :foreign_key => 'inviter_id'
  has_one :blog, :foreign_key=>'owner_id'
  has_many :pictures
  has_many :owner_applications, :dependent=> :delete_all
  has_many :owned_hot_spots, :class_name=>'HotSpot', :foreign_key=>'owner_id', :dependent=>:nullify, :order=>'city_id'
  has_many :articles, :dependent=> :delete_all
  has_many :folders, :dependent=> :delete_all
#  has_many :owned_hot_spots, :dependent=>:nullify, :class_name=>'HotSpot', :foreign_key=>'owner_id'
  has_many :owned_brands, :dependent=>:nullify, :class_name=>'Brand', :foreign_key=>'owner_id'
  has_many :created_brands, :dependent=>:nullify, :class_name=>'Brand', :foreign_key=>'creator_id'
  has_many :posts, :dependent=> :delete_all
  has_many :promotions, :dependent=> :delete_all
  has_many :hot_spot_access_logs, :dependent=> :delete_all
  has_many :hot_spot_tags, :dependent=> :delete_all
  has_many :sent_messages,:class_name=>'Message', :dependent=> :delete_all, :foreign_key=>'from_id'
  has_many :received_messages,:class_name=>'Message', :dependent=> :delete_all, :foreign_key=>'to_id'
  has_many :friends, :dependent=>:delete_all, :foreign_key=>'owner_id'
  has_many :friend_members, :through=>:friends, :source=>:member, :conditions=>'pending = false'
  has_many :pending_friends, :foreign_key=>'owner_id', :class_name=>'Friend', :conditions=>'pending = true', :order=>'created_at desc'
  has_many :be_friends, :dependent=>:delete_all, :class_name=>'Friend', :foreign_key=>'member_id'
  has_many :pending_be_friends, :foreign_key=>'member_id', :class_name=>'Friend', :conditions=>'pending = true'
  has_many :invitations, :dependent=>:delete_all
  has_many :friend_recommendations, :class_name=>'RecommendedHotSpot', :dependent=>:destroy
  has_many :new_friend_recommendations, :class_name=>'RecommendedHotSpot', :conditions=>['readed = ? ', false]
  has_many :member_privileges
  has_many :coupons, :dependent=>:destroy
  has_many :received_coupons, :dependent=>:delete_all
  has_many :hotel_reservations
  has_many :subscription_message_sent_logs, :dependent=>:delete_all
  
  has_and_belongs_to_many :hot_spots
  has_and_belongs_to_many :recommendation_to_friends, 
                          :class_name=>'RecommendedHotSpot', 
                          :join_table=>'members_recommended_hot_spots'
  has_and_belongs_to_many :forums
  has_and_belongs_to_many :blacklist_to_forums, :join_table => :bbs_blacklists, :class_name => 'Forum'
  
  has_many :gift_orders
  
  attr_protected :used_experience, :used_credit, :mobile_register
  
  validates_presence_of :login_name
  validates_length_of :login_name, :within => 3..40, :allow_nil=>true
  validates_uniqueness_of :login_name, :allow_nil=>true
  validates_presence_of :mail, :if=>Proc.new{ |member| ! member.mobile_register }
  validates_length_of :mail, :maximum=>100, :allow_nil=>true
  validates_format_of :mail, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message=> N_('is not a valid e-mail address.'), :if=>Proc.new{ |member| ! member.mobile_register }         
  validates_uniqueness_of :mail, :allow_nil=>true, :if=>Proc.new{ |member| ! (member.mail.nil? or member.mail.empty?) }
  validates_uniqueness_of :nick_name, :allow_nil=>true
  validates_length_of :nick_name, :maximum=>80, :allow_nil=>true
  validates_presence_of :password, :on => :create
  validates_length_of :password, :within => 6..15, :allow_nil=>true
  validates_format_of :password, :with=> /^([_\-.A-z0-9]*)$/, :message=> N_('contains invalid character'), :allow_nil=>true 
  validates_length_of :sign, :maximum=>1000, :allow_nil=>true
  
  before_create :generate_confirm_code 
  
  untranslate :password_hash, :city_for_mobile   
  
  def self.login(name, password)
    self.find_by_login_name_and_password_hash_and_confirmed(name, Imon::ActiveRecord::Password::encrypt(password), true)
  end
  
  def before_validation
    self.nick_name = self.login_name if self.nick_name.nil? or self.nick_name.empty?
  end
  
  def is_password_correct?(password)
    return Imon::ActiveRecord::Password::encrypt(password) == self.password_hash
  end
  
  def logo_after_assign
    logger.info "after_assign_logo"
    self.logo.resize! '96x96'
  end
  
  def generate_confirm_code
    self.confirm_code=Digest::SHA1.hexdigest("#{self.mail}#{Time.now.to_s}#{rand(1024)}")
  end                                               
  
  def confirmed!
    self.confirmed=true
  end           
  
  def generate_mail_confirm_code
    self.mail_confirm_code=Digest::SHA1.hexdigest("#{self.mail}#{Time.now.to_s}#{rand(1024)}")
  end
  
  def confirmed_mail!
    self.mail = self.mail_confirm
  end  
  
  def modifiable_to?(member)
    self == member
  end
  
  def locked?
    ! (self.locked_until.nil? or ( (Time.now <=> self.locked_until) > 0))
  end
  
  def lock!(time=DEFAULT_LOCK_TIME)
    time = DEFAULT_LOCK_TIME if time <= 0
    self.update_attribute(:locked_until, Time.now + time)
  end
  
  def unlock!
    self.update_attribute(:locked_until, nil)
  end
  
  def open_option!(option=DEFAULT_LOCK_TIME)
    self.update_attribute(:favorite_open_option, option)
  end
  
  def score!(type, score=0)          
    raise ArgumentError, 'type is not a symbol' unless type.is_a?(Symbol) 
    raise ArgumentError, 'unknown score type!' unless [:experience, :credit].include?(type)
    current = attributes[type.to_s] 
    current = 0 if current.nil?
    update_attribute_with_validation_skipping(type, current + score)
  end
  
  def digest
    Digest::SHA1.hexdigest("#{self.mail}:#{self.login_name}:#{self.password_hash}")
  end
  
  def hot_spot_count
    HotSpot.count :conditions=>['creator_id = ?', self.id]
  end
  
  def comment_count
    Comment.count :conditions=>['member_id = ?', self.id]
  end
  
  def revise_count
    Revise.count :conditions=>['member_id = ?', self.id]
  end
  
  def photo_count
    NaviPhoto.count :conditions=>['uploader_id = ?', self.id]
  end
  
  def product_count
    Product.count :conditions=>['creator_id = ?', self.id]    
  end

  def tag_count
    HotSpotTag.connection.select_value("select count(*) from (select distinct tag from hot_spot_tags where member_id = #{self.id}) tags")
  end
  
  def has_not_read_count
    self.received_messages.count :conditions=>'readed = false'
  end  
  
  def post_count(current_user=nil)
    unless current_user && self.id == current_user.id
      conditions = [" check_status = ? and deleted = 0",Post::STATUS_CHECKED]
    end
     
    self.posts.count :conditions=>conditions
  end
  
  def has_pending_owner_applications(target)
    a = self.owner_applications.find :first, 
                                     :conditions=>['target_type = ? and target_id = ? and status = ?', 
                                                   target.class.to_s, 
                                                   target.id, 
                                                   OwnerApplication::STATUS_PENDING]
  end
  
  def make_merchant!
    self.update_attribute_with_validation_skipping :is_merchant, true unless self.is_merchant == true
  end
  
  def latest_posts(limit=5,current_user=nil)
    unless current_user && self.id == current_user.id
      conditions = "check_status = ? and deleted = 0",Post::STATUS_CHECKED
    end
    
    self.posts.find :all, :order=>'updated_at desc, created_at desc', :limit=>limit,:conditions => conditions
  end
  
  def latest_owned_hot_spots(limit=5)
    self.owned_hot_spots.find(:all, :limit=>limit, :order=>'created_at desc')
  end
  
  def latest_owned_brands(limit=5)
    self.owned_brands.find(:all, :limit=>limit, :order=>'created_at desc')
  end

  def latest_owned_promotions(limit=5)
    self.promotions.find(:all, :limit=>limit, :order=>'created_at desc')
  end  
  
  def recent_access_hot_spots(city, limit=5)
    HotSpotAccessLog.member_recent_access_hot_spots self, city, limit
  end
  
  def score_weight
    [[self.experience/1000, 3].min + [self.credit/200, 5].min, 1].max
  end
  
  def add_friend(member, need_confirm=true)
    need_confirm = false if member.has_friend?(self)
    self.friends.create :member=>member, :pending=>need_confirm
  end
  
  def has_friend?(member)
    !(self.friends.find :first, :conditions=>['member_id = ? and pending = ?', member.id, false]).nil?
  end

  def has_pending_friend?(member)
    !(self.friends.find :first, :conditions=>['member_id = ? and pending = ?', member.id, true]).nil?
  end
  
  def receive_message(from, title, content, content_args)
    fav_locale = self.favorite_lang || 'zh_cn'
    old_locale = Locale.current
    set_locale(fav_locale)
    self.received_messages.create :member_from=>from, 
                                  :title=>_(title),
                                  :content=>_(content) % content_args,
                                  :readed=>false
    set_locale(old_locale)
  end
  
  def random_friend_members(limit=10)
    # 原来用的:order => rand() 要改进
    self.friend_members.find :all, :limit=>limit
  end
  
  def have_favorite(hot_spot_id)
    self.connection.select_value("select count(*) from hot_spots_members where member_id = #{self.id} and hot_spot_id = #{hot_spot_id.to_i}").to_i > 0
  end
  
  def friend_recommendation_for(hot_spot)
    self.friend_recommendations.find_by_hot_spot_id hot_spot.id
  end
  
  def recommend_hot_spot_by_friend(hot_spot, recommender)
    recommendation = self.friend_recommendations.find_or_create_by_hot_spot_id hot_spot.id
    recommendation.update_attribute_with_validation_skipping :last_recommended_at, Time.now
    recommendation.add_recommender recommender
    recommendation
  end
  
  def has_privilege(priv)
    granted_privileges.include? priv
  end
  
  def granted_privileges
    @granted_privileges ||= self.member_privileges.collect {|mp| mp.privilege.to_sym }
  end
  
  def can_post_article? 
    self.is_merchant? or self.is_staff
  end
  
  def role_string
    role = ''
    role << 'A' if self.is_admin
    role << 'S' if self.is_staff
    role << 'M' if self.is_merchant
    role 
  end
  
  def send_box
    self.sent_messages.find(:all, :conditions => "sender_deleted = 0")
  end
  
  def received_box
    self.received_messages.find(:all, :conditions => "receiver_deleted = 0")
  end
  
  def available_experience
    self.experience - self.used_experience
  end

  def available_credit
    self.credit - self.used_credit
  end
  
  def use_point(exp, cred)
    raise XNavi::NoEnoughPointException if self.available_experience < exp or self.available_credit < cred
    self.used_experience += exp
    self.used_credit += cred
  end
  
  def capabilities
    capabilities = []
    capabilities << CAPABILITY_MARKED_HOT_SPOT if self.hot_spot_count > 0
    capabilities << CAPABILITY_OWNED_HOT_SPOT if self.owned_hot_spots.count > 0
    capabilities << CAPABILITY_OWNED_BRAND if self.owned_brands.count > 0
    capabilities << CAPABILITY_FRIEND_RECOMMENDATIONS if self.friend_recommendations.count > 0
    capabilities << CAPABILITY_RECEIVED_MESSAGE if self.received_messages.count > 0
    capabilities << CAPABILITY_UNREAD_MESSAGE if self.has_not_read_count > 0
    capabilities << CAPABILITY_FAVORITES if self.hot_spots.count > 0
    return capabilities
  end
  
  def is_moderator?(forum = nil)
    forums = self.forums
    if self.forums
      if forum
        return forums.include?(forum)
      else
        return true
      end
    else
      return false
    end
  end
end

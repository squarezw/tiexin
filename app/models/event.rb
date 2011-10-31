require 'uri'
require 'dynamic_query'

class Event < ActiveRecord::Base
  include Imon::DynamicQuery
  self.extend Imon::DynamicQuery
  belongs_to :member
  belongs_to :event_category
  has_and_belongs_to_many :cities
  belongs_to :vendor, :polymorphic => true
  has_one :coupon, :dependent=>:nullify
  has_and_belongs_to_many :tags, :uniq=>true
  acts_as_multilingual_attribute :summary
  acts_as_multilingual_attribute :content
  
  validates_presence_of :begin_date, :summary
  validates_length_of_multilingual_attribute :summary, :lang => XNavi::SUPPORT_LANGS, :within=>0..300, :allow_nil => true
  validates_format_of :reference_url, :with => Regexp.new(URI::REGEXP::PATTERN::ABS_URI), :message => _('is not a valid URL'), :unless=>'reference_url.nil? or reference_url.empty?'
  
  
  image_column :banner, :validate_integrity=>false,
                 :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                        ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    }
                    
  image_column :post, :validate_integrity=>false,
                 :store_dir => 
                    proc { |inst, attr| 
                      time = inst.created_at.nil? ? Time.now : inst.created_at
                      File.join(time.year.to_s, time.month.to_s, time.day.to_s,
                        ActiveSupport::Inflector.underscore(inst.class).to_s, attr.to_s, inst.id.to_s)
                    },
                :versions=>{:thumb=>'180x240'}
  
  def self.per_page
    10
  end

  def self.random_events(current_city,limit=1)
#       return Event.find(:all,  
#          :conditions => ["(events.allcity=1 or (events.hot_spot_id is not null and exists(select * from hot_spots where hot_spots.id = events.hot_spot_id and hot_spots.city_id = ?)) or exists (select * from cities_events c where c.event_id = events.id and c.city_id = ?)) and end_date >= ?", current_city.id, current_city.id, Time.now.to_date], :order => "rand()" ,:limit=>limit)
# 原来用的:order => rand() 要改进
    Event.find :all, :conditions=>["(events.allcity=1 or exists (select * from cities_events c where c.event_id = events.id and c.city_id = ?)) and end_date >= ?", current_city.id, Date.today], :limit=>limit
  end
  
  def self.effective_for_city(city, conditions, options={})
    options = {:page=>1, :order=>'created_at desc'}.merge(options)
    options[:conditions] = self.find_event_conditions(city, conditions)
    self.paginate options
  end
  
  def self.events_of_today(city, limit=5)
    return self.random_effective_for_city_of_date(city, Date.today, limit)
  end
  
  def self.random_effective_for_city_of_date(city, date, limit=1)
    # 原来用的:order => rand() 要改进
    return self.effective_for_city city, :date=>date, :per_page=>limit, :page=>1
  end
  
  def self.effective_for_city_of_date(city, date, limit=1)
    return self.effective_for_city city, :date=>date, :per_page=>limit, :page=>1
  end
  
  def self.tags(city, conditions={})
    conditions[:month] = Date.today unless conditions.has_key?(:date) or conditions.has_key?(:month)
    Tag.find :all, :include=>'events', :conditions=>find_event_conditions(city, conditions), :select=>'distinct tags.*', :order=>'tags.tag'
  end
  
  def self.date_ranges(city, conditions={})
    city_id = city.is_a?(City) ? city.id : city.to_s.to_i
    exps = [self.or(self.equal(:allcity, true), 
                   self.exists('select * from cities_events c where c.event_id = events.id and c.city_id = ?', city_id))]
    if (date = conditions.delete(:date))
      exps << self.greater_or_equal(:end_date, date.beginning_of_month)
      exps << self.less_or_equal(:begin_date, date.end_of_month)
    end
    exps << self.equal(:event_category_id, conditions[:event_category_id]) if conditions[:event_category_id]
    exps << self.exists("select * from events_tags et where et.event_id = events.id and et.tag_id = ?", conditions[:tag_id]) unless conditions[:tag_id].nil? or conditions[:tag_id].empty?
    rows = self.find :all, :conditions=>self.and(exps).conditions, :select=>'distinct events.begin_date, events.end_date'
    rows.collect { |event| [event.begin_date, event.end_date]}
  end
  
  def before_validation
    self.end_date = self.begin_date if self.end_date.nil?
    self.cities << self.vendor.city if self.vendor.respond_to?(:city)
  end
  
  def validate
    if self.end_date && self.begin_date and self.end_date < self.begin_date 
      errors.add(:end_date, _("The end date could not before the start date "))  
    end
    if self.cities.empty?
      errors.add(:cities, _("The event must applied to at least one city."))
    end
  end
  
  def host
    self.vendor
  end
    
  def banner_after_assign
    self.banner.process! do |image|
      image.resize_to_fit 190, 70
    end
  end
  
  def modifiable_to?(user)
    user and (user.has_privilege(:manage_events) or self.vendor.owner_id == user.id)
  end
  
  def is_on_day?(day)
    (self.begin_date..self.end_date).include? day
  end
  
  def tags_string
    (self.tags.collect { |tag| tag.tag }).join(',')
  end
  
  def tags_string=(str)
    if str.nil? or str.empty?
      self.tags.clear
      return
    end
    
    new_tags = str.strip.split(/\s*[,，]\s*/)
    self.tags.each do |old_tag|
      self.tags.delete(old_tag) unless new_tags.include?(old_tag.tag)
    end
    
    new_tags.each do |new_tag|
      tag = Tag.find_or_create_by_tag new_tag
      self.tags << tag unless self.tags.include?(tag)
    end
  end

  def self.find_event_conditions(city, conditions)
    city_id = city.is_a?(City) ? city.id : city.to_s.to_i
    exps = [self.or(self.equal(:allcity, true), 
                   self.exists('select * from cities_events c where c.event_id = events.id and c.city_id = ?', city_id))]
    if (date = conditions.delete(:date))
      exps << self.greater_or_equal(:end_date, date)
      exps << self.less_or_equal(:begin_date, date)
    elsif (date = conditions.delete(:month))
      exps << self.less_or_equal(:begin_date, date.end_of_month)
      exps << self.greater_or_equal(:end_date, date.beginning_of_month)
    else
      exps << self.greater_or_equal(:end_date, Date.today)
    end
    exps << self.equal(:event_category_id, conditions[:event_category_id]) if conditions[:event_category_id]
    exps << self.exists("select * from events_tags et where et.event_id = events.id and et.tag_id = ?", conditions[:tag_id]) unless conditions[:tag_id].nil? or conditions[:tag_id].empty?
    self.and(exps).conditions
  end
end

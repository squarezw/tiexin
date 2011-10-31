require 'coordinate'
require 'dynamic_query'

class City < ActiveRecord::Base
  include Imon::DynamicQuery
  
  MOBILE_MAP_LEVELS = '(1,2,3,4,5,6,7,8,9)'
  FIRST_MOBILE_MAP_LEVEL = 8
  
  has_many  :hot_spots
  has_many  :areas
  has_many  :traffic_lines
  has_many  :map_levels, :order=>:no
  has_many :roads
  has_many :topics, :order=>'expire_date desc'
  has_many :districts
  
  has_and_belongs_to_many :events
  acts_as_multilingual_attribute :name
  
  image_column :photo, 
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
  validates_length_of_multilingual_attribute :name, :lang => XNavi::SUPPORT_LANGS, :within=>0..20, :allow_nil => true
  validates_numericality_of [:width,:height], :message => _('must be integer'), :allow_nil => true
  
  def map_levels_for_mobile
    self.map_levels.find(:all, :conditions => ["no in #{MOBILE_MAP_LEVELS}"], :order => 'no'  )
  end
  
  def default_map_level_for_mobile
    self.map_levels.find(:first, :conditions=>['no = ?', FIRST_MOBILE_MAP_LEVEL])
  end
  
  def hot_spot_count_in_map_block(map_block, category_id = nil)
    exps = []
    exps << self.between(:x, map_block[:nw_x], map_block[:nw_x] + map_block[:width])
    exps << self.between(:y, map_block[:nw_y], map_block[:nw_y] + map_block[:height])
    cat_exp = expression_for_category(category_id) unless category_id.nil?
    exps << cat_exp unless cat_exp.nil?
    self.hot_spots.count :conditions=>self.and(exps).conditions 
  end

  def hot_spots_in_map_block(map_block, order, category_id = nil, options={})
    exps = []
    exps << self.between(:x, map_block[:nw_x], map_block[:nw_x] + map_block[:width])
    exps << self.between(:y, map_block[:nw_y], map_block[:nw_y] + map_block[:height])
    cat_exp = expression_for_category(category_id) unless category_id.nil?
    exps << cat_exp unless cat_exp.nil?
    options = options.merge :conditions=>self.and(exps).conditions, :order => order
    self.hot_spots.find(:all, options )
  end

  def start_point
    self.start_point_x.nil? ? nil : XNavi::Coordinate.new(self.start_point_x, self.start_point_y)
  end
  
  def latest_hot_spot(limit=10)
    self.hot_spots.find(:all, :limit=>limit, :order=>'created_at desc')
  end
  
  def latest_hot_spot_of_category(category, limit=10)
    ids = category.id_of_all_children_include_self.join(',')
    self.hot_spots.find :all, :conditions=>"hot_spot_category_id in (#{ids})", :order=>'created_at desc', :limit=>limit
  end

  def recent_hotest_hot_spots(category=nil, limit=10, order='visit_count desc')
    unless category.nil?
      ids= category.id_of_all_children_include_self.join ','
      self.hot_spots.find :all, :conditions=>"hot_spot_category_id in (#{ids})", :order=>order, :limit=>limit
    else
      self.hot_spots.find(:all,:limit => limit,:order => order) 
    end
  end
  
  def hotest_areas(limit=10)
    self.areas.find(:all, :limit=>limit, :order=>'visit_count desc')
  end
  
  def coordinate_from_mercator(x, y)
    XNavi::Coordinate.new((x-self.x0)* 100, (y-self.y0)* -100)
  end
  
  def contract_hot_spots_count
    self.hot_spots.count :conditions=>'owner_id is not null'
  end
  
  def random_contract_hot_spots(limit=10)
    self.hot_spots.find :all, :conditions=> "ontop = true" ,:order=>'recommend_expire_at desc', :limit=>limit
  end
  
  private
  def expression_for_category(category_id)
    begin
      category = HotSpotCategory.find(category_id)
      ids = category.all_children_include_self.collect { |cat| cat.id }
      ids = ids.flatten.uniq.join(',')
      return self.raw("hot_spot_category_id in (#{ids})")
    rescue RecordNotFound
      return
    end
  end


end

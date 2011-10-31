require 'uri'
require 'coordinate'
require 'dynamic_query'

class HotSpot < ActiveRecord::Base   
  include PhotoOwner
  include URI::REGEXP::PATTERN;
  include Imon::DynamicQuery
  
  self.extend Imon::DynamicQuery
  
  HTTP_HTTPS_SCHEME="HTTP|HTTPS"
  HOME_PAGE_URI=Regexp.new("(#{HTTP_HTTPS_SCHEME}:(?:#{HIER_PART}|#{OPAQUE_PART}))|(^$)", true)
  
  PRICE_LEVEL_CHEAP = 1
  PRICE_LEVEL_NORMAL = 2
  PRICE_LEVEL_EXPENSIVE = 3
  PRICE_LEVELS = [PRICE_LEVEL_CHEAP, PRICE_LEVEL_NORMAL, PRICE_LEVEL_EXPENSIVE]
  N_("price_level|1")
  N_("price_level|2")
  N_("price_level|3")
  
  PARKING_SLOT_NONE = 1
  PARKING_SLOT_SMALL = 2 # less than 20
  PARKING_SLOT_20 = 3 # 20 - 50
  PARKING_SLOT_50 = 4 # 50 - 100
  PARKING_SLOT_100 = 5 # more than 100
  PARKING_SLOTS = [PARKING_SLOT_NONE, PARKING_SLOT_SMALL, PARKING_SLOT_20, PARKING_SLOT_50, PARKING_SLOT_100]
  N_('parking_slot|1')
  N_('parking_slot|2')
  N_('parking_slot|3')
  N_('parking_slot|4')
  N_('parking_slot|5')

  FORBIDDEN_CHARACTERS_IN_NAME = [['（', '('],
                                  ['）', ')'],
                                  ['─', '-']]
                                  
  # Capability Values
  CP_BASIC_INFORMATION = 128
  CP_ACCESS_TRAFFIC_LINE = 129
  CP_TRAFFIC_LINE_DETAIL = 130
  CP_PROMOTION = 131
  CP_BRAND_PROMOTION = 132
  CP_PRODUCTS = 133
  CP_PHOTOS = 134
  CP_COMMENTS = 135
  CP_INNER_HOT_SPOTS = 136
  CP_LAYOUT_MAPS = 137
  CP_CONTAINED_POSITIONS = 138
  CP_ARTICLES = 139
  CP_BRAND = 140

  cattr_reader :per_page                                  
  @@per_page = 10
                                  
  belongs_to :city   
  belongs_to :layout_map
  belongs_to :creator, :class_name=>'Member', :foreign_key=>'creator_id'  
  belongs_to :hot_spot_category                  
  belongs_to :container, :class_name=>'HotSpot', :foreign_key=>:container_id
  belongs_to :brand
  belongs_to :owner, :class_name => 'Member', :foreign_key=>'owner_id' 
  
  has_one      :hotel
  
  has_many   :layout_maps, :as=>:layoutable, :dependent=>:destroy       
  has_many   :positions, :dependent=>:delete_all
  has_many   :products, :dependent=>:destroy, :as=>:vendor  
  has_many   :events, :as=>:vendor, :dependent=>:destroy
  has_many   :promotions, :as=>:vendor
  has_many   :photos, :as => :owner, :class_name=>'NaviPhoto', :dependent=>:destroy
  has_many   :member_comments, :as => :commentable, :dependent=>:destroy, :class_name=>'Comment', :order=>'created_at'
  has_many   :revises, :dependent => :delete_all
  has_many   :traffic_stops, :dependent => :destroy
  has_many   :traffic_lines, :through =>:traffic_stops
  has_many   :hot_spots, :foreign_key=>:container_id, :dependent=>:nullify
  has_many   :owner_applications, :as=>:target, :dependent=>:delete_all
  has_many   :hot_spot_tags, :dependent=>:delete_all
  has_many   :hot_spot_scores
  has_many   :recommended_hot_spots, :dependent=>:destroy
  has_and_belongs_to_many :members
  has_and_belongs_to_many :articles
  has_and_belongs_to_many :topics

  acts_as_multilingual_attribute :name
  acts_as_multilingual_attribute :address
  acts_as_multilingual_attribute :introduction
  acts_as_multilingual_attribute :operation_time

   
  validates_presence_of :name
  validates_length_of :phone_number, :maximum=>60, :allow_nil => true              
  validates_presence_of :hot_spot_category
  validates_presence_of :city
  validates_inclusion_of :price_level, :in=>PRICE_LEVELS, :allow_nil=>true
  validates_length_of :price_memo, :maximum=>200, :allow_nil=>true, :message => _('Can not be longer than %{length}') % { :length=>200 }
  validates_inclusion_of :parking_slot, :in=>PARKING_SLOTS, :allow_nil=>true
  validates_length_of :home_page, :allow_nil=>true, :maximum=>150, :message => _('Can not be longer than %{length}') % { :length=>150 }
  validates_format_of :home_page, :with => HOME_PAGE_URI, :allow_nil=>true, :message => _('is not a valid HTTP/HTTPS URL')
    
  validates_length_of_multilingual_attribute :name, :lang => XNavi::SUPPORT_LANGS, :within=>0..60, :allow_nil=>true
  validates_length_of_multilingual_attribute :address, :lang => XNavi::SUPPORT_LANGS, :maximum=>100, :allow_nil => true, :message => _('Can not be longer than %{length}') % { :length=>100 }
  validates_length_of_multilingual_attribute :introduction, :lang => XNavi::SUPPORT_LANGS, :maximum=>1000, :allow_nil => true, :message => _('Can not be longer than %{length}') % { :length=>1000 }
  validates_length_of_multilingual_attribute :operation_time, :lang=>XNavi::SUPPORT_LANGS, :maximum=>200, :allow_nil=>true, :message => _('Can not be longer than %{length}') % { :length=>200 }
  
  untranslate :container, :ref
  
  def self.find_created_by(creator, except=nil, limit=5)
    where = 'creator_id = ?'
    cond = [creator.id]
    unless except.nil?
      where << ' and id <> ?'
      cond << except.id
    end

    self.find :all, 
              :conditions => [where].concat(cond),
              :limit=> limit,
              :order => 'created_at desc' 
  end
  
  @@default_search_options= { :page=>1, :order=>'name_zh_cn' }
  
  # Search hot spots without city specified. Other arguments are same as search2
  def self.search(city, spec, options={})
    spec[:city] = city
    self.search2(spec, options)
  end
  
  # Search hot spots in given city with given specification.
  # city: In which city to do search. Can be City or city id.
  # spec: Specification for search. Should be a hash. Key and meaning of value:
  #     name: if name field, at least one language, contains value.
  #     hot_spot_category: value is a HotSpotCategory or it's id. search hot_spots of this category or it's subcategory
  #     tag: search hot spots contains tag including value.
  #     area: value is an Area or it's id. Search hot_spots in this area.
  #     area_name: search hot spots located in area, whose name including value.
  #     exclude: valud is id of hot_spot, which should be excluded from search result.
  #     nearby: search hot spots near the point specified by value, which shoulb be a hash:
  #              :x => float, x of coordination
  #              :y => float, y of coordination
  #              :scope=> float, in KM, radius
  #     container_id: Contained in hot_spot whose id is specified by value.
  #     brand_id: value is id of a brand
  #     road_name : Name of road, search hot_spots which name contains it.
  #     layout_map: LayoutMap or it's id, search hot_spot on this layout map.
  #     city: City or id of city, search hot_spot in this city.
  #     creator: Member or id of member, search hot_spot created by this member.
  def self.search2(spec, options={})
    options = @@default_search_options.merge options
    exps = []
    exps.concat build_expressions(spec)
    options[:conditions] = self.and(exps).conditions
    self.paginate options
  end
  
  def self.count_by_spec(city, spec, options={})
    exps = []
    exps << expression_for_city(city)
    exps.concat build_expressions(spec)
    options[:conditions] = self.and(exps).conditions
    self.count options
  end
  
  
  def areas
    c = self.coordinate(true)
    return [] if c.nil?
    x, y = c.x, c.y
    self.city.areas.find(:all, :conditions => ['nw_x <= ? and nw_x + width >= ? and nw_y <= ? and nw_y + height >= ?', x, x, y, y] )
  end
  
  def inner_hot_spots_of_category(category, include_children=false, order='name_zh_cn')
    if include_children
      ids = category.id_of_all_children_include_self.join(',')
      self.hot_spots.find :all, :conditions=>"hot_spot_category_id in (#{ids})", :order=>order
    else
      children_hot_spots.select { |hot_spot| hot_spot.hot_spot_category_id == category.id }
    end
  end                                                
  
  def count_inner_hot_spots_of_category(category, include_children=false)
    if include_children
      ids = category.id_of_all_children_include_self.join(',')
      self.hot_spots.count :conditions=>"hot_spot_category_id in (#{ids})"
    else
      self.hot_spots.count :conditions=>['hot_spot_category_id = ?', category.id]
    end    
  end
  
  def children_hot_spots
    unless @children_hot_spots
      @children_hot_spots = (self.children_positions.collect { |position| position.hot_spot }).flatten.uniq
    end  
    return @children_hot_spots
  end
  
  def children_positions
    unless @child_positions
      @child_positions = (self.layout_maps.collect { |map| map.positions}).flatten
    end
    @child_positions
  end      
  
  def positions_for_inner_hot_spot(hot_spot)
    children_positions.find_all { |position| position.hot_spot_id == hot_spot.id }
  end
  
  def category_path
    [hot_spot_category, hot_spot_category.ancestors].flatten
  end                        
  
  def positions_in_hot_spot(container_hot_spot)
    self.positions.select { |pos| pos.layout_map.layoutable == container_hot_spot }
  end                
  
  def root_category
    self.hot_spot_category.root
  end             
  
  def modifiable_to(member)
    member and ( member.is_admin or 
                 member.has_privilege(:modify_hot_spot) or 
                 self.owner == member or 
               (! self.approved and self.creator == member) )
  end      
  
  def layout_maps_has_zoom_levels
    self.layout_maps.select { |may| ! may.zoom_levels.blank? }
  end
  
  def before_validation
    self.name.strip!
  end

  def before_save
    replace_forbidden_characters_in_name :name_zh_cn
    replace_forbidden_characters_in_name :name_en
  end

  def before_create
    self.approved = (! self.creator.nil? and self.creator.is_admin)   
    return true
  end

  def latest_products(limit=5)
    self.products.find(:all, :order=>'updated_at desc, created_at desc', 
                       :limit=>limit)
  end    
  
  def latest_comments(limit=10)
    self.comments.find :all, :order=>'created_at desc', :limit=>limit
  end
  
  def products_include_brands(options={})
    options = {:page=>1}.merge options
    exps = [self.and(self.equal(:vendor_type, 'HotSpot'), self.equal(:vendor_id, self.id))]
    exps << self.and(self.equal(:vendor_type, 'Brand'), self.equal(:vendor_id, self.brand_id)) if self.brand
    options[:conditions] = self.or(exps).conditions
    Product.paginate  options
  end
  
  def coordinate(heuristic=false)
    if self.x and self.y
      return XNavi::Coordinate.new(self.x, self.y)
    elsif heuristic and self.container
      return self.container.coordinate(true)
    else
      return nil
    end
  end

  def neighbour_area(scope=1)
    self.coordinate(true).arround_square(scope * 2)
  end
  
  def neighbour_traffic_stops(scope=0.2)
    coordinate = self.coordinate(true)
    HotSpot.find(:all,
                 :conditions => ["sqrt(pow((x-?) * 0.007692 , 2) + pow((y - ?) * 0.007692, 2) ) <= ? and (hot_spot_categories.traffic_stop_type != ?)", coordinate.x, coordinate.y, scope * 1000, TrafficLine::TYPE_NONE],
                 :include=>:hot_spot_category
#                 :conditions => ['(x between ? and ?) and (y between ? and ?) and (hot_spot_category_id in (select id from hot_spot_categories where traffic_stop_type != ?))', nw.x, se.x, nw.y, se.y, TrafficLine::TYPE_NONE]
                 )
  end
  
  def is_traffic_stop?
    self.hot_spot_category.is_traffic_stop?
  end
  
  def access_traffic_lines
    lines=self.neighbour_traffic_stops(0.5).collect { |stop| stop.traffic_lines}
    lines.flatten.uniq - self.traffic_lines
  end
  
  def recent_comments(limit=5)
    self.member_comments.find(:all,
                       :order => 'created_at desc', 
                       :limit => limit )
  end
  
  def pending_revises(limit=10)
    self.revises.find(:all,
                      :conditions => ['status = ?', Revise::STATUS_PENDING],
                      :limit=>limit,
                      :order => 'created_at desc')
  end
  
  def pending_revises_count
    self.revises.count(:conditions =>['status = ?', Revise::STATUS_PENDING])
  end
  
  def inner_hot_spots_not_on_layout_map
    self.hot_spots.find(:all, :conditions=>["not exists (select * from positions p, layout_maps l where l.layoutable_type='HotSpot' and l.layoutable_id = ? and p.layout_map_id = l.id and p.hot_spot_id = hot_spots.id)", self.id])
  end
  
  def random_inner_hot_spots(limit=10)
    # 原来用的:order => rand() 要改进
    self.hot_spots.find :all, :limit=>limit
  end
 
  def merge_from(source)
    Comment.connection.execute("update comments set commentable_id = #{self.id} where commentable_type= 'HotSpot' and commentable_id=#{source.id}")
    NaviPhoto.connection.execute("update navi_photos set owner_id = #{self.id} where owner_type='HotSpot' and owner_id=#{source.id}")
    Product.connection.execute("update products set vendor_id = #{self.id} where vendor_type = 'HotSpot' and vendor_id = #{source.id}")
    Revise.connection.execute("update revises set hot_spot_id = #{self.id} where hot_spot_id = #{source.id}")
    HotSpot.connection.execute("update hot_spots set container_id = #{self.id} where container_id = #{source.id}")
    HotSpotTag.connection.execute "update hot_spot_tags set hot_spot_id = #{self.id} where hot_spot_id = #{source.id}"
    
    if source.is_traffic_stop? and self.is_traffic_stop?
      source.traffic_stops.each  do |stop|
        unless self.traffic_stops.find(:first, :conditions=>['traffic_line_id = ?', stop.traffic_line_id])
          position = stop.position
          line = stop.traffic_line
          TrafficStop.connection.execute("update traffic_stops set position = position + 1 where position >= #{position} and traffic_line_id = #{line.id}")
          TrafficStop.connection.execute("INSERT INTO traffic_stops (`traffic_line_id`, `hot_spot_id`, `position`) VALUES(#{line.id}, #{self.id}, #{position})")
        end
      end
    end
    source.destroy
  end
  
  def vendor_id
    self.id
  end
  
  def visited!
    self.update_attribute_with_validation_skipping :visit_count, self.visit_count + 1
  end
  
  def random_photo
    return nil if self.photos.empty?
    # 原来用的:order => rand() 要改进
    self.photos.find :first
  end
  
  def nearby_similar_hot_spots(distance=1000, limit=5)
    cat_ids = self.hot_spot_category.id_of_all_children_include_self
    HotSpot.find :all,
                 :conditions=>["city_id = ? and distance(x,y,?,?)<? and id <> ? and hot_spot_category_id in (#{cat_ids.flatten.join(',')})",
                               self.city_id, self.x, self.y, distance, self.id],
                 :limit=> limit
  end
  
  def most_frequent_tags(limit = 10)
#    self.hot_spot_tags.find_by_sql(["select *,count(tag) as cnt from hot_spot_tags where hot_spot_id = ? group by tag order by cnt desc limit ?",id,limit])
     sql = "select tag, count(tag) count from hot_spot_tags where hot_spot_id = #{self.id} group by tag order by count desc"
     HotSpotTag.connection.add_limit! sql, :limit=>limit unless limit.nil?
     rows = HotSpotTag.find_by_sql sql
  end
  
  def find_a_zoom_level
    layout_map = self.layout_maps.detect { |l| !l.zoom_levels.empty? }
    layout_map ? layout_map.zoom_levels[0] : nil
  end
  
  def capabilities
    capabilities = []
    capabilities << CP_BASIC_INFORMATION if has_basic_information?
    capabilities << CP_ACCESS_TRAFFIC_LINE unless self.access_traffic_lines.empty?
    capabilities << CP_TRAFFIC_LINE_DETAIL if self.is_traffic_stop? and !self.traffic_lines.empty?
    capabilities << CP_PROMOTION if self.effective_events_count > 0
    capabilities << CP_BRAND_PROMOTION if self.brand and !self.brand.promotions_for_city(self.city).empty?
    capabilities << CP_PRODUCTS if self.has_products?(true) 
    capabilities << CP_COMMENTS unless self.comments.size <= 0
    capabilities << CP_PHOTOS unless self.photos.empty?
    capabilities << CP_INNER_HOT_SPOTS unless self.hot_spots.empty?
    capabilities << CP_LAYOUT_MAPS unless self.layout_maps_has_zoom_levels.empty?
    capabilities << CP_CONTAINED_POSITIONS if self.has_contained_positions?
    capabilities << CP_ARTICLES unless self.articles.empty?
    capabilities << CP_BRAND unless self.brand.nil?
    return capabilities
  end
  
  def count_tags_by_tag(limit = 3)
    unless limit.nil?
      HotSpotTag.find_by_sql(["select tag,count(tag) as ct from hot_spot_tags where hot_spot_id = ? group by tag order by ct desc limit ?", self.id, limit])
    else
      HotSpotTag.find_by_sql(["select tag,count(tag) as ct from hot_spot_tags where hot_spot_id = ? group by tag order by ct desc", self.id])
    end
  end
  
  def comments
    self.member_comments
  end
  
  def has_contained_positions?
    (!self.layout_maps.empty?) and 
    self.layout_maps.each { |map| return true unless map.positions.empty? }
    false
  end
  
  def effective_promotions(options={})
    exp = self.and self.equal(:vendor_type, 'HotSpot'),
                   self.equal(:vendor_id, self.id)
    if self.brand
      brand_exp = self.and(self.equal(:vendor_type, 'Brand'),
                           self.equal(:vendor_id, self.brand_id),
                           self.or(self.equal(:allcity, true), self.exists('select * from cities_events c where c.event_id = events.id and c.city_id = ?', self.city_id)))
      exp = self.or exp, brand_exp
    end
    exp = self.and exp, self.greater_or_equal(:end_date, Date.today)
    options = options.merge :conditions=>exp.conditions, :order=>'begin_date'
    Promotion.paginate options
  end

  def effective_events(options={})
    options = ({:page=>1}).merge options
    exps = [self.and(self.equal(:vendor_type, 'HotSpot'), self.equal(:vendor_id, self.id))]
    if self.brand
      exps << self.and(self.equal(:vendor_type, 'Brand'), 
                       self.equal(:vendor_id, self.brand_id),
                       self.or(self.equal(:allcity, true), self.exists('select * from cities_events c where c.event_id = events.id and c.city_id = ?', self.city_id)))
    end
    if (date = options.delete :on_date)
      date_exp = self.and self.greater_or_equal(:end_date, date),
                          self.less_or_equal(:begin_date, date)
    else
      date_exp = self.greater_or_equal(:end_date, Date.today)
    end
    conditions = self.and(self.or(exps), date_exp).conditions
    options = options.merge :conditions=>conditions, :order=>'begin_date'
    Event.paginate options
  end
  
  def effective_events_count
    return Event.count :conditions=>['vendor_type = ? and vendor_id = ? and end_date >= ?', 'HotSpot', self.id, Date.today ]
  end
  
  def effective_events_in_month(date)
    first_day = date.beginning_of_month
    last_day = date.end_of_month
    exps = [self.and(self.equal(:vendor_type, 'HotSpot'), self.equal(:vendor_id, self.id))]
    if self.brand
      exps << self.and(self.equal(:vendor_type, 'Brand'), 
                       self.equal(:vendor_id, self.brand_id),
                       self.or(self.equal(:allcity, true), self.exists('select * from cities_events c where c.event_id = events.id and c.city_id = ?', self.city_id)))
    end
    conditions = self.and(self.or(exps), 
                          self.greater_or_equal(:end_date, first_day), 
                          self.less_or_equal(:begin_date, last_day)).conditions
    Event.find :all, :conditions=>conditions
  end
  
  def has_products?(include_brand=false)
    return true unless self.products.empty? 
    return (include_brand and self.brand and !self.brand.products.empty?)
  end
  
  def can_publish_event?(user)
    user and (user.has_privilege(:manage_events) or self.owner_id == user.id )
  end
  
  def effective_home_page
    return self.home_page unless self.home_page.nil? or self.home_page.empty?
    return self.brand.home_page if self.brand
    return ''
  end
  
  def recommended(expire_month)
    self.update_attribute_with_validation_skipping(:recommend, true)
    if self.recommend_expire_at.blank?
      self.update_attribute_with_validation_skipping(:recommend_expire_at, Time.now.months_since(expire_month))
    else
      self.update_attribute_with_validation_skipping(:recommend_expire_at, self.recommend_expire_at.months_since(expire_month))
    end    
  end
  
  def cancel_recommended
    self.update_attribute_with_validation_skipping(:recommend, false)
    self.update_attribute_with_validation_skipping(:recommend_expire_at, "")
    cancel_recommended_ontop
  end

  def recommended_ontop(expire_month)
    self.update_attribute_with_validation_skipping(:ontop, true)
    recommended(expire_month) unless self.recommend
  end

  def cancel_recommended_ontop
    self.update_attribute_with_validation_skipping(:ontop, false)
  end

  def avg_score
    self.score/4*5
  end
  
  private
  def self.expression_for_city(city)
    id = city.is_a?(City) ? city.id : city
    self.equal :city_id, id
  end
  
  def self.expression_for_name(keyword)
    return nil if keyword.nil? or keyword.empty?
    self.or self.like('hot_spots.name_zh_cn', keyword), self.like('hot_spots.name_en', keyword)
  end
  
  def self.expression_for_hot_spot_category(category)
    return nil if category.nil?
    unless category.is_a? HotSpotCategory
      return nil if category.to_s.empty?
      category = HotSpotCategory.find category.to_s.to_i 
    end
    ids = category.id_of_all_children_include_self
    self.in :hot_spot_category_id, ids
  end
  
  def self.expression_for_hot_spot_category_name(keyword)
    return nil if keyword.nil? or keyword.empty?
    categories = HotSpotCategory.name_contains keyword
    ids = categories.collect { |cat| cat.id_of_all_children_include_self }
    ids = ids.flatten.uniq
    return self.always_false if ids.empty?
    self.in :hot_spot_category_id, ids    
  end

  def self.expression_for_or(spec)
    self.or(build_expressions(spec))
  end
  
  def self.expression_for_area(area)
    area = Area.find area.to_s.to_i unless area.is_a?(Area)
    self.and(self.between(:x, area.nw_x, area.se_x),
             self.between(:y, area.nw_y, area.se_y))
  end
  
  def self.expression_for_exclude(id)
    self.not_equal :id, id
  end
  
  def self.expression_for_area_name(name)
    return nil if name.nil? or name.empty?
    kw = "%#{name}%"
    self.exists("select * from areas a where ((a.name_zh_cn like ?) or (a.name_en like ?)) and a.nw_x <= hot_spots.x and a.nw_x + a.width >= hot_spots.x and a.nw_y <= hot_spots.y and a.nw_y + a.height >= hot_spots.y", kw, kw)
  end
  
  def self.expression_for_search_in(name)
    self.or(self.expression_for_area_name(name), 
            self.expression_for_road_name(name))
  end
  
  def self.expression_for_tag(tag)
    return nil if tag.nil? or tag.empty?
    self.exists('select * from hot_spot_tags t where t.hot_spot_id = hot_spots.id and t.tag like ? ', "%#{tag}%")
  end
  
  def self.expression_for_nearby(option)
    return nil if option.nil? or option.empty?
    scope = option[:scope] || 0.2
    scope = [[2, scope].min, 0].max
    self.raw "distance(hot_spots.x, hot_spots.y, #{option[:x]}, #{option[:y]}) <= #{scope * 1000}"
  end
  
  def self.expression_for_container(container)
    return nil if container.nil?
    unless container.is_a? HotSpot
      return nil if container.to_s.empty?
      container = HotSpot.find container.to_s.to_i 
    end
    self.equal :container_id, container.id
  end
  
  def self.expression_for_brand(brand)
    return nil if brand.nil?
    brand_id = brand.is_a?(Brand) ? brand.id : brand.to_s.to_i
    self.equal :brand_id, brand_id
  end
  
  def self.expression_for_brand_name(name)
    self.exists 'select * from brands where brands.id = hot_spots.brand_id and (brands.name_zh_cn like ? or brands.name_en like ?)', "%#{name}%", "%#{name}%"
  end
  
  def self.expression_for_container(container_id)
    self.equal :container_id, container_id
  end
  
  def self.expression_for_brand_id(brand_id)
    self.equal :brand_id, brand_id
  end
  
  def self.expression_for_road_name(road_name)
    self.or(self.like(:address_zh_cn, road_name),
            self.like(:address_en, road_name))
  end
  
  def self.expression_for_layout_map(layout_map)
    layout_map_id = layout_map.is_a?(LayoutMap) ? layout_map.id : layout_map
    self.exists 'select * from positions where hot_spot_id = hot_spots.id and layout_map_id = ? ', layout_map_id
  end
  
  def self.expression_for_creator(member)
    member_id = member.is_a?(Member) ? member.id : member.to_s
    self.equal :creator_id, member_id
  end
  
  def self.expression_for_ids(ids)
    self.in :id, ids
  end
  
  def self.build_expressions(spec)
    spec.keys.collect { |key| self.send "expression_for_#{key}".to_sym, spec[key] }
  end
  
  def replace_forbidden_characters_in_name(attr_name)
    attr_value = self.attributes[attr_name.to_s]
    return if attr_value.nil? or attr_value.blank?
    FORBIDDEN_CHARACTERS_IN_NAME.each { |src, dest| attr_value.gsub! src, dest}
    self[attr_name]= attr_value
  end
  
  def has_basic_information?
    result = [:address_zh_cn, :address_en, :phone_number, :price_memo, :parking_slot, :home_page, :introduction_en, :introduction_zh_cn].find { |attr_name| !(self[attr_name].nil? or self[attr_name].to_s.empty?) }
    result or (self.score_count > 0)
  end
  
end

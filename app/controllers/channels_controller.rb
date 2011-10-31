require 'dynamic_query'
class ChannelsController < ApplicationController
  include Imon::DynamicQuery
  
  layout 'default', :only=>:show
  before_filter :find_city
  before_filter :find_channel
  helper 'cities'
  helper 'hot_spots'
  helper 'products'
   helper 'layout_maps'
  
  def show
    @hot_spot_category = get_hot_spot_category
    @area_name = get_area_name
    @keyword = get_keyword
    @sub_category_ids = @hot_spot_category.id_of_all_children_include_self
    do_search @channel.hot_spot_category
    @start_point = @hot_spots.empty? ? @current_city.start_point : @hot_spots[0].coordinate
    @has_merchant = has_merchant?
    if request.xhr?
      render :template=>'channels/show.js.rjs', :layout=>false
    else
      read_comments
      read_posts
      read_articles
      read_tags
      read_recommended_hot_spots
      render :template=>'channels/show.html.erb'
    end
  end
  
  def brands
    @hot_spot_category = get_hot_spot_category
    cat_ids = @hot_spot_category.id_of_all_children_include_self
    @area_name = get_area_name
    @tag = params[:tag]
    exp = [self.in('hot_spot_category_id', cat_ids)];
    exists_exps = [self.in('hot_spots.hot_spot_category_id', cat_ids), 
                 self.equal('hot_spots.city_id', @current_city.id),
                 self.raw('hot_spots.brand_id = brands.id')];
                 
    if @area_name and !@area_name.empty?
      area = Area.find :first, :conditions=>['city_id = ? and (name_en = ? or name_zh_cn = ?)', @current_city.id, @area_name, @area_name];
      if area
        exists_exps << self.greater_or_equal('hot_spots.x', area.nw_x)
        exists_exps << self.greater_or_equal('hot_spots.y', area.nw_y)
        exists_exps << self.less_or_equal('hot_spots.x', area.nw_x + area.width)
        exists_exps << self.less_or_equal('hot_spots.y', area.nw_y + area.height)
      end
    end
    exists_exps << self.exists("select * from hot_spot_tags t where t.hot_spot_id = hot_spots.id and t.tag = ? ", params[:tag]) unless @tag.nil? or @tag.empty?
    unless exists_exps.empty?
      exists_exp = self.and(exists_exps)
      logger.info "select * from hot_spots where #{exists_exp.expression}"
      exp << self.exists("select * from hot_spots where #{exists_exp.expression}", exists_exp.params)
    end
    
    @brands = Brand.paginate :conditions=>self.and(exp).conditions,
                             :order=>"name_#{@current_lang}",
                             :page=>params[:page],
                             :per_page=>20
  end
  
  def tags
    @hot_spot_category = get_hot_spot_category
    cat_ids = @hot_spot_category.id_of_all_children_include_self
    @area_name = get_area_name
    @brand_name = params[:brand_name]
    exists_exps = [self.raw("hot_spots.hot_spot_category_id in (#{cat_ids.join(',')})"), 
                 self.raw("hot_spots.city_id = #{@current_city.id}") ];
                 
    if @area_name and !@area_name.empty?
      area = Area.find :first, :conditions=>['city_id = ? and (name_en = ? or name_zh_cn = ?)', @current_city.id, @area_name, @area_name];
      if area
        exists_exps << self.raw("hot_spots.x >= #{area.nw_x} and hot_spots.y >= #{area.nw_y} and hot_spots.x <= #{area.nw_x + area.width} and hot_spots.y <= #{area.nw_y + area.height}")
      end
    end
    brand_keyword = "%#{@brand_name}%"
    exists_exps << self.raw("exists(select * from brands where brands.id = hot_spots.brand_id and (brands.name_zh_cn like '#{brand_keyword}' or brands.name_en like '#{brand_keyword}'))") unless @brand_name.nil? or @brand_name.empty?
    where_cause = self.and(exists_exps).expression
    @tags = HotSpotTag.paginate_by_sql "select t.tag, count(*) cnt from hot_spot_tags t inner join hot_spots on (t.hot_spot_id = hot_spots.id) where #{where_cause}  group by t.tag order by cnt",
#    @tags = HotSpotTag.paginate_by_sql "select t.tag, count(*) cnt from hot_spot_tags t inner join hot_spots h on (t.hot_spot_id = h.id) where h.city_id = #{@current_city.id} and h.hot_spot_category_id in  (#{@channel.hot_spot_category.id_of_all_children_include_self.join(',')}) group by t.tag order by cnt",
                                       :per_page=>20,
                                       :page=>params[:page]
  end
  
  def contracted_hot_spots
    @hot_spot = HotSpot.find :first,
                              :conditions=>["city_id = ? and hot_spot_category_id in (#{@channel.hot_spot_category.id_of_all_children_include_self.join(',')}) and owner_id is not null", @current_city.id],
                              :order=>'rand()'
    logger.info "@hot_spot = #{@hot_spot}"
  end
  
  def owner_recommended_products
    @products = Product.paginate_by_sql "select p.* from products p, hot_spots h where p.vendor_type = 'HotSpot' and p.vendor_id = h.id and h.city_id = #{@current_city.id} and h.hot_spot_category_id in (#{@channel.hot_spot_category.id_of_all_children_include_self.join(',')}) and p.creator_id = h.owner_id order by name_#{@current_lang}", 
               :page=>params[:page], :per_page=>3
  end
  
  def promotions
    ids = @channel.hot_spot_category.id_of_all_children_include_self.join(',')
    sql = <<-SQL
      select p.* 
      from events p
      where p.end_date >= '#{Date.today.to_formatted_s(:db)}' and 
            p.begin_date <= '#{Date.today.to_formatted_s(:db)}' and 
            ((p.vendor_type = 'HotSpot' and p.vendor_id in (select id from hot_spots h where h.city_id = #{@current_city.id} and h.hot_spot_category_id in (#{ids}))) or 
            (p.vendor_type = 'Brand' and (p.allcity='1' or exists(select * from cities_events cp where cp.city_id = #{@current_city.id} and cp.event_id = p.id)) and 
            (p.vendor_id in (select id from brands where brands.hot_spot_category_id in (#{ids}))))) 
       order by p.created_at desc, p.begin_date, p.end_date
    SQL
    @promotions = Event.paginate_by_sql sql, :page=>params[:page], :per_page=>5
  end
  
  private
  def find_city
    adjust_current_city City.find(params[:city_id])
  end
  
  def do_search(category)
    spec = {:hot_spot_category => @hot_spot_category}
    unless @area_name.nil? or @area_name.empty?
      conditions = ['(name_zh_cn = ? or name_en = ?) and city_id = ?', @area_name, @area_name, @current_city.id]
      if Area.exists? conditions
        spec[:area_name] = @area_name
      elsif Road.exists? conditions
        spec[:road_name] = @area_name
      elsif (center_hot_spot = HotSpot.find(:first,:conditions=>conditions))
        spec[:nearby] = { :x=>center_hot_spot.x, :y=>center_hot_spot.y, :scope=>0.5 }
      end
    end
    spec[:tag] = params[:tag]
    spec[:name] = @keyword unless @keyword.nil?
    if params[:order_by] and !params[:order_by].blank?    
      order_by = params[:order_by]
      order_by += ' desc' unless order_by == "name_#{@current_lang}"
    else
      order_by = "(owner_id is null), score desc"
    end
     @hot_spots = HotSpot.search  @current_city,
                                  spec,
                                  :order=>order_by,
                                  :page=> params[:page],
                                  :per_page=>10 
  end
  
  def read_recommended_hot_spots
    # 原来用的:order => rand() 要改进
    @recommended_hot_spots = HotSpot.find :all, :conditions=>['city_id = ? and hot_spot_category_id in (?)', @current_city.id, @sub_category_ids], :limit=>12, :order=>'recommend_expire_at desc'
  end
  
  def read_comments
    @comments = Comment.find_by_sql "select c.* from comments c, hot_spots h where c.commentable_type = 'HotSpot' and c.commentable_id = h.id and h.city_id = #{@current_city.id} and h.hot_spot_category_id in (#{@sub_category_ids.join(',')}) order by c.created_at desc limit 10" 
  end
  
  def read_posts
    @posts = @channel.forum.latest_posts 10
  end
  
  def read_tags
    @recommended_tags = RecommendedTag.find :all, 
                        :conditions=>["exists (select * from hot_spot_tags t join hot_spots h on (t.hot_spot_id = h.id) where h.city_id = ? and t.tag = recommended_tags.tag and h.hot_spot_category_id in (?))", @current_city.id, @sub_category_ids], 
                        :order=>'recommended_tags.tag'
  end
  
  def read_articles
    @articles = Article.find :all,
                             :include=>:hot_spots,
                             :conditions=>["hot_spots.city_id = ? and hot_spots.hot_spot_category_id in (#{@sub_category_ids.join(',')})", @current_city.id],
                             :order=>'articles.created_at desc',
                             :limit=>10
  end
  
  def get_hot_spot_category
    (params[:hot_spot_category_id] and !params[:hot_spot_category_id].empty?) ? HotSpotCategory.find(params[:hot_spot_category_id]) : @channel.hot_spot_category
  end
  
  def get_area_name
    area_name = params[:area] ? params[:area] : nil
    area_name = nil if area_name == 'Area name, road name, hot spot name' or area_name == _('Area name, road name, hot spot name')
    return area_name
  end
  
  def get_keyword
    keyword = params[:keyword] ? params[:keyword] : nil
    keyword = nil if keyword == 'HotSpot name.' or
                      keyword == _('HotSpot name.') or
                      keyword == ''
    return keyword
  end
  
  def find_channel
    @channel = Channel.find params[:id]
    @selected_menu = @channel
  end

  def has_merchant?
    (HotSpot.count :conditions=>["city_id = ? and hot_spot_category_id in (#{@sub_category_ids.join(',')}) and owner_id is not null", @current_city.id]) > 0
  end

end

class TopicsController < ApplicationController
  layout 'default'
  before_filter :find_city
  before_filter :find_topic, :except => [:index, :expo, :event_calendar]
  
  helper 'cities'
  helper 'hot_spots'
  helper 'photos'
  helper 'promotions'
  helper 'events'

  def index
    order = []
    order << @current_city.id if @current_city
    order << "id desc"
    @topics = Topic.find(:all, :order => "#{order.join(",")}")
  end

  def show
    @articles = @topic.articles
    hot_spot_ids = @topic.hot_spots.collect{|cat| cat.id}
    unless hot_spot_ids.blank?
      do_search hot_spot_ids 
    else
      @hot_spots = ""
    end

    @start_point = @hot_spots.empty? ? @current_city.start_point : @hot_spots[0].coordinate

    if @topic.title == "世博专题"
      redirect_to :action => :expo
    end
    unless @topic.template.blank?
      render :action => "#{@topic.template}"
    else
      @posts = @topic.posts
      @comments = @topic.comments
      
      unless hot_spot_ids.blank?
          hot_spot_ids = hot_spot_ids.join(",")
          @events = Event.find_by_sql("select * from events where vendor_type = 'HotSpot' and end_date >= cast(now() as date) and vendor_id in (#{hot_spot_ids}) and (allcity = 1 or id in
        (select event_id from cities_events where city_id = #{@current_city.id} and event_id in (select id from events where vendor_type = 'HotSpot' and end_date >= cast(now() as date) 
        and vendor_id in (#{hot_spot_ids})))) limit 2")
      end
      
      @back_topics = Topic.back_topics(@current_city)
      if request.xhr?
          render :template=>'topics/show.js.rjs', :layout=>false
      end
    end
  end

  def expo
    @event_category_id = EventCategory.find_by_name_en("Expo") # 世博专题活动的分类ID, EventCategory.create :name_zh_cn=>'世博', :name_en=>'Expo'
    @topic = Topic.find_by_title("世博专题")
    @articles = @topic.articles.find(:all, :limit => 10, :order => "id desc")
    hot_spot_ids = @topic.hot_spots.collect{|cat| cat.id}

    unless hot_spot_ids.blank?
      do_search hot_spot_ids
    else
      @hot_spots = ""
    end

    @start_point = @hot_spots.empty? ? @current_city.start_point : @hot_spots[0].coordinate

    unless @topic.template.blank?
      render :action => "#{@topic.template}"
    else
      @posts = @topic.posts
      @txsbxs = Post.find_all_by_forum_id(10,:limit => 7)
      @comments = @topic.comments

      unless hot_spot_ids.blank?
          hot_spot_ids = hot_spot_ids.join(",")
          @events = Event.find_by_sql("select * from events where vendor_type = 'HotSpot' and end_date >= cast(now() as date) and vendor_id in (#{hot_spot_ids}) and (allcity = 1 or id in
        (select event_id from cities_events where city_id = #{@current_city.id} and event_id in (select id from events where vendor_type = 'HotSpot' and end_date >= cast(now() as date)
        and vendor_id in (#{hot_spot_ids})))) limit 2")
      end

      @back_topics = Topic.back_topics(@current_city)

      @topic_expo = @topic.topic_expo
      @recommend_hot_spots_family = HotSpot.find(@topic_expo.square_ids_family.split(",")) if @topic_expo and @topic_expo.square_ids_family
      @recommend_hot_spots_sweet = HotSpot.find(@topic_expo.square_ids_sweet.split(",")) if @topic_expo and @topic_expo.square_ids_sweet
      @recommend_hot_spots_grandparent = HotSpot.find(@topic_expo.square_ids_grandparent.split(",")) if @topic_expo and @topic_expo.square_ids_grandparent
      @recommend_hot_spots_child = HotSpot.find(@topic_expo.square_ids_child.split(",")) if @topic_expo and @topic_expo.square_ids_child
      
      @food_hot_spots = HotSpot.find(@topic_expo.food_ids.split(",")) if @topic_expo and @topic_expo.food_ids
      @travel_line_family = @topic_expo.travel_line_family.split(",") if @topic_expo and !@topic_expo.travel_line_family.blank?
      @travel_line_sweet = @topic_expo.travel_line_sweet.split(",") if @topic_expo and !@topic_expo.travel_line_sweet.blank?
      @travel_line_grandparent = @topic_expo.travel_line_grandparent.split(",") if @topic_expo and !@topic_expo.travel_line_grandparent.blank?
      @travel_line_child = @topic_expo.travel_line_child.split(",") if @topic_expo and !@topic_expo.travel_line_child.blank?
      if request.xhr?
          render :template=>'topics/show.js.rjs', :layout=>false
      end
    end
  end

  def event_calendar
    @event_category_id = EventCategory.find_by_name_en("Expo") # 世博专题活动的分类ID, EventCategory.create :name_zh_cn=>'世博', :name_en=>'Expo'
    @date = Date.parse(params[:date])
    render :layout=>false
  end
  
  private
  def find_topic
    @topic = Topic.find(params[:id])
    adjust_current_city @topic.city
  end

  def find_city
    adjust_current_city City.find(params[:city_id]) if params[:city_id]
  end
  
  def do_search(ids = nil)
    spec = {:hot_spot_category => @hot_spot_category}
    spec[:tag] = params[:tag]
    spec[:ids] = ids if ids
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

  
  
end

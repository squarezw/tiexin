class Admin::HotelsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  before_filter :initializes, :only => [:search_hot_spot, :create, :new, :edit, :update ]
  layout 'admin'
  Hotel_id = 3
  
  helper :hotels
  
  def index
    unless params[:city].nil? || params[:city][:id].blank?
      @city_select = params[:city][:id].to_i
      conditions = ["city_id = ?",@city_select]
    else
      conditions = nil
    end
    @hotels = Hotel.paginate :order => "id desc", :per_page => 25, :page => params[:page], :conditions => conditions
    @cities = City.find(:all, :select=>"id,name_#{@current_lang}").collect{|p| [localized_description(p, :name),p.id]}
  end
  
  def search_hot_spot
    @cities = City.find(:all, :select=>"id,name_#{@current_lang}").collect{|p| [localized_description(p, :name),p.id]}
    conditions = ["hot_spot_category_id in (select id from hot_spot_categories where parent_id = ? ) and id not in (select hot_spot_id from hotels where hot_spot_id is not null)", Hotel_id]
    unless params[:city].nil? || params[:city][:id].blank?
      @city_select = params[:city][:id].to_i
      conditions.first << " and city_id = ?"
      conditions << @city_select
    end
    unless params[:hot_spot_category_id].nil? || params[:hot_spot_category_id].blank?
      @hot_spot_category_select = params[:hot_spot_category_id].to_i
      conditions.first << " and hot_spot_category_id in (?)"
      conditions << HotSpotCategory.find(@hot_spot_category_select).id_of_all_children_include_self
    end
    unless params[:name].nil? || params[:name].blank? 
      keyword = "%#{params[:name]}%"
      conditions.first << " and (name_en like ? or name_zh_cn like ?)"
      conditions << keyword
      conditions << keyword
    end
    unless params[:member].nil? || params[:member][:nick_name].blank?
      conditions.first << " and creator_id = (select id from members where nick_name = ?)"
      conditions << params[:member][:nick_name]
      @member_select = params[:member][:nick_name]
    end    
    @hot_spots = HotSpot.paginate :conditions => conditions,
      :order => "id desc",
      :per_page => 25,
      :page => params[:page]
  end
  
  def create
      @hotel = Hotel.new(params[:hotel])
      unless params[:hot_spot_id].blank?
        @hot_spot = HotSpot.find(params[:hot_spot_id])
        @hotel.hot_spot = @hot_spot
      end
      if @hotel.save
        if request.xhr?
          render :update do |page|
           page.alert _('Hotel was successfully created')
           page.redirect_to :action => :search_hot_spot
          end
        else
          redirect_to :action => :index
        end
      else
        if request.xhr?
          render :update do |page|
            page.alert @hotel.errors.full_messages.join("\n")
          end
        else
          render :action => "new"
        end        
      end
  end
  
  def new
    @hotel = Hotel.new
  end
  
  def edit
    @hotel = Hotel.find(params[:id])
    @category = @hotel.city
  end
  
  def update
    @hotel = Hotel.find(params[:id])
    if @hotel.update_attributes(params[:hotel])
      flash[:notice] = _('Hotel was successfully updated.')
      redirect_to :action => :index
    else
      render :action=>'edit'
    end
  end
  
  def destroy
    @hotel = Hotel.find(params[:id])
    @hotel.destroy
    redirect_to :action => :index
  end

  private
  def initializes
    @cities = City.find(:all, :select=>"id,name_#{@current_lang}", :conditions => "has_map = false").collect{|p| [localized_description(p, :name),p.id]}
    @districts = District.find(:all, :select=>"id,name_#{@current_lang}").collect{|p| [localized_description(p, :name),p.id]}
    @categories = HotSpotCategory.find_all_by_parent_id(Hotel_id)
  end
  
end

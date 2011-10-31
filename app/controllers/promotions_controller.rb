require 'dynamic_query'

class PromotionsController < ApplicationController
  include Imon::DynamicQuery
  layout 'default'
  before_filter :authenticated, :only=>[:new, :create]
  before_filter :find_vendor, :only=>[:new, :create, :show]
  before_filter :find_or_initialize_promotions, :except => [:index, :create]
  before_filter :check_privilege, :only=>[:new, :create]
  helper 'promotions'  
  
  def index
#    return if params[:vendor_type] == 'brand' && find_city(params[:city_id])
    hot_spot_category_id = params[:hot_spot_category_id]
    vendor_id = params[:vendor_id]
    vendor_type = params[:vendor_type]
    
    unless @mobile_user
      if params[:city_id] && vendor_type == 'brand'
        city_id = params[:city_id]
      else
        city_id = @current_city.id
      end
    end
    
    if hot_spot_category_id
     conditions = "(vendor_type = 'HotSpot' and vendor_id in (select id from hot_spots h where h.city_id = ? and h.hot_spot_category_id in (?))) or (
    ((events.allcity=1 or exists (select * from cities_events c where c.event_id = events.id and c.city_id = ?)) and vendor_type = 'Brand' and vendor_id in (Select id from brands where hot_spot_category_id in (?))))"

      @hot_spot_category = HotSpotCategory.find(hot_spot_category_id)
      @promotions = Promotion.paginate :conditions => ["#{conditions}  and end_date >= ? ", city_id,@hot_spot_category.id_of_all_children_include_self,city_id,@hot_spot_category.id_of_all_children_include_self,Time.now.to_date],
                               :order => 'created_at',
                               :page=>params[:page]
      @category_name = localized_description(@hot_spot_category, :name) if @hot_spot_category
      
    elsif vendor_type && vendor_id
      
      find_vendor
      if vendor_type == 'hot_spot'
        hot_spot = HotSpot.find vendor_id
        adjust_current_city hot_spot.city
        @promotions = hot_spot.effective_promotions :page=>params[:page], :per_page=>10
      else
        conditions = "(events.allcity=1 or exists (select * from cities_events c where c.event_id = events.id and c.city_id = ?)) and vendor_id = ? and vendor_type = 'Brand'"
        @promotions = Promotion.paginate :conditions => ["#{conditions} and end_date >= ?",city_id, vendor_id, Time.now.to_date],
                               :order => 'created_at',
                               :page=>params[:page]
      end
     
      @category_name = localized_description(@vendor, :name)
      
    end

    @vendor_title = vendor_type || "Hot Spot Category"
    
    respond_to do |format|
      format.html{}
      format.xml { 
        if vendor_type == 'hot_spot'
          redirect_to params.merge(:controller=>'events', :action=>'index') 
        else
          render :layout=>false
        end
      }
    end
  end
  
  def create
    @promotion = @vendor.promotions.build(params[:promotion])
    @promotion.member = @current_user
    if @vendor.respond_to? :city
      @promotion.cities << @vendor.city
    else
      @promotion.cities << City.find(params[:cities]) if params[:cities]
    end
    if @promotion.save
      flash[:notice] = _('Promotion was successfully created.')
      redirect_to @vendor
    else
      render :action => "new"
    end
  end

  protected
  def find_or_initialize_promotions
    @promotion = params[:id] ? Promotion.find(params[:id]) : Promotion.new
  end
  
  def find_vendor
    vendor_class = params[:vendor_type].camelize.split("::").inject(Object) { |par, const| par.const_get(const) }
    @vendor = vendor_class.send(:find, params[:vendor_id])
  end
   
  private
  
  def check_privilege
    return true if @current_user == @vendor.owner or @current_user.has_privilege(:manage_events)
    flash[:note] = _('You have no privilege to do this operation.')
    redirect_to @vendor
  end
  
  def find_city(city_id)
     if (city_id.nil? or city_id.empty?)
      respond_to do |format|
        format.html {}        
        format.xml {
          error_xml 206
          return true
        }
      end      
     else
        begin
            City.find(city_id)
        rescue ActiveRecord::RecordNotFound
             error_xml 205
             return true
        end
     end
     return false
  end
end

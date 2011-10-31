require 'dynamic_query'

class HotelsController < ApplicationController
  include Imon::DynamicQuery
  Hotel_id = Admin::HotelsController::Hotel_id
  def categories
    @categories = HotSpotCategory.find_all_by_parent_id(Hotel_id)
    respond_to do |format|
        format.html {
           render :layout=>'default'
        }
        format.xml {
          render :layout=> false
        }         
      end    
  end
  
  def search
   @current_city = City.find params[:city_id]
   exps = []
   unless params[:city_id].nil? or params[:city_id].empty?
     if @current_city.has_map
       exps << [self.raw("a.city_id = #{@current_city.id}")]
     else
       exps << [self.raw("city_id = #{@current_city.id}")]
     end
   end
   unless params[:name].nil? or params[:name].empty?
     if @current_city.has_map
          name = "%%#{params[:name]}%%"
          exps << self.raw("name_zh_cn like '#{name}' ")
     else
          name = "%%#{params[:name]}%%"
          exps << self.raw("name like '#{name}' ")
     end
   end
   unless params[:hot_spot_category_id].nil? or params[:hot_spot_category_id].empty?
     if @current_city.has_map
       exps << self.raw("hot_spot_category_id = #{params[:hot_spot_category_id]} ")
     else
       exps << self.raw("category_id = #{params[:hot_spot_category_id]} ")
     end      
   end
   unless params[:area].nil? or params[:area].empty?
      area = "%%#{params[:area]}%%"
      exps << self.raw("exists (select * from areas ar where ((ar.name_zh_cn like '#{area}') or (ar.name_en like '#{area}')) and ar.nw_x <= a.x and ar.nw_x + ar.width >= a.x and ar.nw_y <= a.y and ar.nw_y + ar.height >= a.y)")
   end
   unless params[:district_id].nil? or params[:district_id].empty?
      district = District.find(params[:district_id])
      if district
        name = "%%#{district.name_zh_cn}"
        if @current_city.has_map
          exps << self.raw("address_zh_cn like  '#{name}' ")
        else
          exps << self.raw("district_id =  #{district.id} ")
        end
      end
   end
   unless params[:price_min].nil? or params[:price_min].empty? or params[:price_max].nil? or params[:price_max].empty?
      @price_min = params[:price_min]
      @price_max = params[:price_max]
      exps << self.raw("hotels.id in (select hotel_id from hotel_rooms where price >#{params[:price_min]} and price < #{params[:price_max]})")
   end   
    
    where_cause = self.and(exps).expression
    
    if @current_city.has_map
      conditions = ["select hotels.*,a.city_id, a.x, a.y, a.name_zh_cn, a.name_en, a.score, a.score_count  from hot_spots a join hotels on a.id = hotels.hot_spot_id where #{where_cause} "]
    else
      conditions = ["select *  from hotels where #{where_cause} "]
    end    
    parse_start_limit
    
    @hotels = Hotel.paginate_by_sql conditions, :page=>@page, :per_page=>@per_page
    
    respond_to do |format|
      format.xml {
          if @hotels.blank?
              error_xml 200
          else
              render :layout=>false
          end
      }    
    end
  end
  
  def contact
    respond_to do |format|
        format.xml {
          render :layout=> false
        }
    end    
  end 
end

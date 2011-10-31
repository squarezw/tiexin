class Admin::TrafficLinesController < ApplicationController
  before_filter :is_admin
  layout 'admin', :except => [:search_hot_spots] 
  
  def index
    @lines = TrafficLine.paginate :conditions=> ['city_id = ?', @current_city.id],  :order => "name_#{@current_lang}",
                             :page=>params[:page]
  end
  
  def new
    @line = TrafficLine.new
  end
  
  def show
    @line = TrafficLine.find params[:id]
  end
  
  def create
    @line = @current_city.traffic_lines.build(params[:line])
    if @line.save
      render :action => "show"
    else
      render :action => "new"
    end
  end
  
  def edit
    @line = TrafficLine.find params[:id]
  end
  
  def update
    @line = TrafficLine.find params[:id]
    if @line.update_attributes(params[:line])
      flash[:note] = _('The traffice line has been modifeid.')
      render :action => "show"
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @traffic_line = TrafficLine.find(params[:id])
    @traffic_line.destroy
    redirect_to manage_traffic_lines_path
  end
  
  def search
    keyword_exp = "%#{params[:keyword]}%"
    order_cause = "name_#{@current_lang}"
    @lines = TrafficLine.paginate :conditions => ['(name_zh_cn like ? or name_en like ?) and city_id = ?', keyword_exp, keyword_exp, @current_city.id],
                                            :order=> order_cause,:page=>params[:page]
    render :action => "index" 
  end
  
  def search_hot_spots
    @line = TrafficLine.find params[:id]
    keyword_exp = "%#{params[:keyword]}%"
    order_cause = "name_#{@current_lang}"
    @hot_spots = HotSpot.find(:all,
                              :conditions=>['(name_zh_cn like ? or name_en like ?) and hot_spot_category_id in (select id from hot_spot_categories where traffic_stop_type = ?) and not exists (select * from traffic_stops where traffic_line_id = ? and hot_spot_id = hot_spots.id) and city_id = ?', keyword_exp, keyword_exp, @line.line_type, @line.id, @current_city.id],
                              :order=>order_cause ) 
    render :inline=>"<li>#{_('No hot spot found.')}</li>" if @hot_spots.empty?                         
  end
end

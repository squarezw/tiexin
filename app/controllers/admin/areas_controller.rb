require 'privilege'
class Admin::AreasController < ApplicationController               
  include XNavi::Privilege
  
  helper 'areas'
  
  require_privilege :manage_area, :new
  require_privilege :manage_area, :create
  require_privilege :manage_area, :edit
  require_privilege :manage_area, :update
  require_privilege :manage_area, :destroy
  require_privilege :manage_area, :reposition
  
  def new
    @area = Area.new(caculate_position)
  end                                                  
  
  def create
    @area = Area.new(params[:area])           
    @area.city = @current_city;
    @area.name[@current_lang] = params[:name]
    unless @area.save
      render  :update do |page|
        page.replace_html 'form_error', @area.errors.full_messages.join("\n")
        page.call 'dialog.show'
      end                      
    end
  end                   
  
  def edit
    @area = Area.find params[:id]
  end
  
  def update
    @area = Area.find params[:id]
    if @area.update_attributes params[:area]
      render :layout=>false
    else
      render  :update do |page|
        page.replace_html 'form_error', @area.errors.full_messages.join("\n")
        page.call 'dialog.show'
      end
    end
  end
  
  def destroy
    @area = Area.find params[:id]
    @area.destroy
  end
  
  def show_marker_info
    @area = Area.find(params[:id])
  end
  
  def reposition
    @area = Area.find(params[:id])
    @area.update_attributes(caculate_position)
    render :update do |page|
      page.call "area_repositioned", "mk_area_#{@area.id}", @area.center[0], @area.center[1], @area.width, @area.height
      page.alert _('The new position of the area has been saved.')
      page.call 'map.set_cursor', 'default'
    end
  end

  def caculate_position
    x0, x1 = params[:x][0].to_i, params[:x][1].to_i
    y0, y1 = params[:y][0].to_i, params[:y][1].to_i 
    return {:nw_x => [x0, x1].min, 
            :nw_y => [y0, y1].min, 
            :width => (x0-x1).abs, 
            :height => (y0-y1).abs}
  end
end

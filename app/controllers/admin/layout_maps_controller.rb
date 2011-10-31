require 'imon_exception'

class Admin::LayoutMapsController < ApplicationController   
  before_filter :is_admin
  before_filter :find_hot_spot
                                                         
  helper 'admin/zoom_levels'
  
  layout 'default', :only=>[:index] 
  
  def index
    @layout_maps = @hot_spot.layout_maps
  end

  def new
    @layout_map = @hot_spot.layout_maps.build()
  end 
  
  def create
    @layout_map = @hot_spot.layout_maps.build(params[:layout_map])
    unless @layout_map.save
      render  :update do |page|
        page.replace_html 'form_error', @layout_map.errors.full_messages.join("\n")
        page.call 'dialog.show'
      end                               
    end
  end     
  
  def edit
    @layout_map = @hot_spot.layout_maps.find(params[:id])
  end             
  
  def update
    @layout_map = @hot_spot.layout_maps.find(params[:id])
    unless @layout_map.update_attributes(params[:layout_map])
      render  :update do |page|
        page.replace_html 'form_error', @layout_map.errors.full_messages.join("\n")
        page.call 'dialog.show'
      end                                
    end
  end          
  
  def destroy
    @layout_map = @hot_spot.layout_maps.find(params[:id])
    begin
      @layout_map.destroy
    rescue Imon::CantDestroyException
      render :update do |page|
        page.alert _('You can not delete this %{obj_name} now.') % { :obj_name => _('layout map') }
      end
    end
  end
  
  private
  def find_hot_spot
    @hot_spot = HotSpot.find(params[:hot_spot_id])
  end             
  
  
end

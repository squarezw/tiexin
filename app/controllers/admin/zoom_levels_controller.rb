class Admin::ZoomLevelsController < ApplicationController
  before_filter :is_admin
  before_filter :find_layout_map
                                      
  helper 'admin/layout_maps'
  
  def index
  end

  def new
    @zoom_level = @layout_map.zoom_levels.build()
  end

  def create          
    @zoom_level = @layout_map.zoom_levels.build(params[:zoom_level])
    logger.info "@zoom_level = #{@zoom_level}"
    if @zoom_level.save
      respond_to_parent do 
        render :action => :create
      end
    else
      respond_to_parent do 
        render :update do |page|
          page.replace_html 'form_error', @zoom_level.errors.full_messages.join("\n")
          page.call 'dialog.show'
        end
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy    
    @zoom_level = @layout_map.zoom_levels.find(params[:id])
    @zoom_level.destroy
  end
  
  private
  def find_layout_map
    @layout_map = LayoutMap.find(params[:layout_map_id])
  end
end

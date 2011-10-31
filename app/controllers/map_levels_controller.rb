class MapLevelsController < ApplicationController
  
  def index
    @city = City.find params[:city_id]
    respond_to do |format|
      format.js {
        @headers['content-type'] = 'text/javascript'   
        render :template=>'layout_maps/levels_data', :layout=>false
      }
    end
  end
end

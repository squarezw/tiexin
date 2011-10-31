class DistrictsController < ApplicationController
  
  def index
    city = City.find(params[:city_id])
    @districts = city.districts
    respond_to  do |format|
      format.xml {render :layout=> false}      
    end
  end

end

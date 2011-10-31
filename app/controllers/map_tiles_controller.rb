class MapTilesController < ApplicationController     
  def show
    file_name = "x#{params[:x]}_y#{params[:y]}.jpg"
    send_file File.join(RAILS_ROOT, 'map', file_name), :filename => file_name
  end
end

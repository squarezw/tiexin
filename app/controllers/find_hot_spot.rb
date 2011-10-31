module FindHotSpot
  def find_container_hot_spot
    @container_hot_spot = HotSpot.find(params[:hot_spot_id])
    adjust_current_city @container_hot_spot.city
  end
end
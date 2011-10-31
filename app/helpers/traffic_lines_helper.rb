module TrafficLinesHelper
  def class_for_traffic_stop(stop)
    return '' unless @near_hot_spot
    (stop.coordinate.distance_to(@near_hot_spot.coordinate)<=500) ? 'nearby_stop' : ''
  end
end

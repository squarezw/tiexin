module ScoresHelper
  def count_in_30day_rate(member_id,hot_spot_id)
    HotSpotScore.count :conditions => ['TO_DAYS(NOW()) - TO_DAYS(created_at)  <=  ? and member_id = ? and hot_spot_id = ?', HotSpotScore::PERIOD_RATE, member_id,hot_spot_id]
  end
end

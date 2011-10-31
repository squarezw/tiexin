class MasterDataController < ApplicationController
  def last_modified_time
    @cities_last_modified_time =  Time.parse ((City.connection.select_one 'select max(updated_at) from cities').values[0])
    @categories_last_modified_time =  Time.parse ((HotSpotCategory.connection.select_one 'select max(updated_at) from hot_spot_categories').values[0])
  end
end

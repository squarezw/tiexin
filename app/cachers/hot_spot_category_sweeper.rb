puts 'HotSpotCategorySweeper loaded'

class HotSpotCategorySweeper < ActionController::Caching::Sweeper
  observe HotSpotCategory
  
  def after_create(object)
    expire_caches    
  end
  
  def after_save(object)
    expire_caches
  end
  
  def after_destroy(object)
    expire_caches
  end
  
  private
  def expire_caches
    expire_fragment 'cities/hot_spot_categories'
  end
end
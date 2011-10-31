module PromotionsHelper 
  def vendor_type(vendor)
    vendor.class.to_s.underscore
  end
  
  def safe_promotion_thumb(promotion)
    promotion.post ? image_tag(promotion.post.thumb.url) : image_tag('nopic.jpg')
  end
  
  def promotion_banner(promotion)
    image_tag(promotion.banner.url)
  end
  
end
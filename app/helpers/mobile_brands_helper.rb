module MobileBrandsHelper
  def safe_mobile_brand_icon(mobile_brand)
    mobile_brand.logo ? image_tag(mobile_brand.logo.normal.url) : image_tag('nopic.jpg')
  end
  
  def safe_mobile_brand_small_icon(mobile_brand)
    mobile_brand.logo ? image_tag(mobile_brand.logo.small.url) : image_tag('nopic.jpg')
  end  
end

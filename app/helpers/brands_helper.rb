module BrandsHelper
  def safe_brand_icon(brand)
    brand.pic ? image_tag(brand.pic.url) : image_tag('nopic.jpg')
  end
end

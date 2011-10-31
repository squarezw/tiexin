(NaviPhoto.find :all).each do |photo|
  photo.photo = File.new(photo.photo.path)
  photo.save
end

(Brand.find :all).each do |brand|
  if brand.pic
    brand.pic = File.new(brand.pic.path)
    brand.save
  end
end

(Product.find :all).each do |product|
  if product.photo
    product.photo = File.new(product.photo.path)
    product.save_with_validation false
  end
end
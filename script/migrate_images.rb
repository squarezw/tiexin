require 'fileutils'

products = Product.find :all
products.each do |product|
  unless product.photo.nil?
    if product.photo.exists?
      product.photo = File.new(product.photo.path) 
      puts product.photo.small_thumb.path
      product.save_with_validation false
    end
  end
end
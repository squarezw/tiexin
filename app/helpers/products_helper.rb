module ProductsHelper 
  def product_div_id(product)
    "div_product_#{product.id}"
  end                               
  
  def vendor_type(vendor)
    vendor.class.to_s.underscore
  end
  
  def show_vendor_path(vendor)
    "/#{vendor.class.to_s.underscore}s/#{vendor.id}"
  end
  
  def class_for_owner_recommended(product)
    product.owner_recommended? ? 'owner_recommended' : ''
  end
end

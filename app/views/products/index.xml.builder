xml.result(:code=>100) do
  @products.each do |product|
    xml.product(:id => product.id, :name => localized_description(product, :name), :official => product.official?) do
      xml.price product.price
      xml.photo(product.photo.mobile.url) if product.photo
      xml.introduction(localized_description(product, :introduction))
    end
  end
end
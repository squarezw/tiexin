if params[:city_id] and !params[:city_id].empty?
xml.result(:code=>'100') do
      xml.brand(@brand.intro, :name => localized_description(@brand,:name), :product_count => @brand.products.count, :promotion_count => @brand.count_promotions_for_city(params[:city_id].to_i) )
end
else
  xml.result(:code=>'206')
end

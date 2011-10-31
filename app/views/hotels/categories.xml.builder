xml.result(:code=>100) do
  @categories.each do |category|
    xml.hot_spot_category(:id=>category.id, :name => category.name_zh_cn) 
  end
end
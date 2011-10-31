xml.result :code=>100 do 
  xml.brand :id=>@brand.id, :capabilities=>@brand.capabilities(params[:city_id]).join(',')
end
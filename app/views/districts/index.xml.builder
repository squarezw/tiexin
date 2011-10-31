xml.result :code=>100 do 
  @districts.each do |district|
    xml.district :id=>district.id, :name=>district.name_zh_cn
  end
end
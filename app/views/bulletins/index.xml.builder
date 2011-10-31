xml.result(:code=>100) do
  @bulletins.each do |bulletin|
    xml.bulletin(bulletin.content, :id=>bulletin.id, :title => bulletin.title) 
  end
end
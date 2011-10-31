xml.result(:code => 100) do
  @roots.each do |category|
    to_xml(xml, category, 1)
  end
end
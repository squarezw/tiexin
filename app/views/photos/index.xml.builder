xml.result(:code => 100 ) do 
  @photos.each do |photo|
    xml.photo(photo.photo.mobile.url, :id => photo.id, :subject => photo.subject, :upload_time => format_time(photo.created_at))
  end
end
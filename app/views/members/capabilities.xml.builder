xml.result :code=>100 do 
  xml.member :id=>@current_user.id, :capabilities=>@capabilities.join(',')
end
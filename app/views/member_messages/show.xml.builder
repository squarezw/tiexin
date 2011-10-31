xml.result :code=>100 do 
  xml.message strip_bbcode(@message.content), :id=>@message.id 
end
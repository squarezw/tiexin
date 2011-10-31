xml.result :code=>100 do 
  @messages.each do |message|
    xml.message message.title, :id=>message.id, :sender=>message.member_from.nick_name, :send_at=>format_time_for_xml(message.created_at), :read=>format_boolean_for_xml(message.readed)
  end
end
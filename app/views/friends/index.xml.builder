xml.result :code=>100 do 
  xml.result_number :number=>@friends.total_entries
  for friend in @friends do
    xml.friend :id=>friend.id, :member_id=>friend.member_id, :nick_name=>friend.member.nick_name
  end
end
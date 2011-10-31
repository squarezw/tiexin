xml.result :code=>(@friend.pending ? 103 : 100) do 
  xml.friend :id=>@friend.id, :member_id=>@friend.member_id, :nick_name=>@friend.member.nick_name
end
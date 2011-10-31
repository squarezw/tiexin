xml.result(:code=>100) do 
  xml.result_number :number=>@count
  @comments.each do |comment|
    xml.comment (strip_bbcode(comment.content), :author => comment.member.nick_name, :posted_at => format_time_for_xml(comment.created_at) )
  end
end
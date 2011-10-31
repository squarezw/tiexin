xml.result(:code=>'100') do
  if @start == 0
    xml.result_number :number=>@articles.total_entries
  end
    @articles.each do |article|
      xml.article(:id =>article.id, :title => article.subject, :created_at => format_time_for_xml(article.created_at), :comment_count => article.comments.count)
    end    
end
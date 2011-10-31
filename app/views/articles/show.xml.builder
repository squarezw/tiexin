xml.result(:code=>'100') do
      xml.article(@article.content, :id =>@article.id, :title => @article.subject, :created_at => format_time(@article.created_at), :comment_count => @article.comments.count)
end
#before days
days = ARGV[0].to_i

posts = Post.find(:all,:conditions => ["created_at < ? ",DateTime.now - days])

begin
  posts.each do |t|
    p "ID:#{t.id} #{t.created_at.strftime("20%y-%m-%d")} ok" if t.update_attributes :content => BBCodeizer.bbcodeize(t.content)
  end
rescue => ex
  p ex.backtrace.join("\n")
end


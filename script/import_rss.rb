RssSource.find(:all).each do |ch|
  begin
    ch.syndicate!
  rescue Exception => ex
    puts ex.message
  end
  puts "channel #{ch.title} syndicate finished."
end
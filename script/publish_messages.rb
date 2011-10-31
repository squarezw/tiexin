pwd = FileUtils.pwd
FileUtils.cd File.join(RAILS_ROOT, 'tmp')
lock_file = 'publish_message.lck'
if File.exists? lock_file and 1.days.since(File.new(lock_file).ctime) < Time.now
    File.delete lock_file
end
unless File.exists? lock_file
  puts 'lock file is not exists.'
  FileUtils.touch lock_file
  begin
    (SubscriptionMessage.find :all, :conditions=>['sent = ?', false], :order=>'created_at').each do |message|
      message.publish
    end
  rescue => ex
    puts ex.message
    print ex.backtrace.join("\n")
  ensure
    File.delete lock_file
  end
else
    puts 'another publish messages job is running. I will quit.'
end
FileUtils.cd pwd

require 'rss'
require 'open-uri'

class RssSource < ActiveRecord::Base
  belongs_to :blog
  has_many :articles
  
  def self.syndicate_all
    RssSource.find(:all).each do |ch|
      begin
        ch.syndicate!
      rescue Exception => ex
        puts ex.message
      end
      puts "channel #{ch.title} syndicate finished."
    end
  end
  
  def retrieve(source=nil)
    self.rss = source || self.rss
    rss = get_rss
    update_channel(rss)
    return self
  end
  
  def syndicate!
    begin
      rss = get_rss
      update_channel(rss)
      rss.items.each do |it|
        old_item = self.articles.find_by_link(it.link)
        date = format_time_for_xml(it.date)
        unless old_item
          item = self.articles.create(
            :subject => it.title,
            :link => it.link,
            :summary => it.title,
            :content => it.description,
            :synch_date => date,
            :member_id => self.blog.owner.id,
            :folder_id => self.folder_id
          )
        else
          old_item.update_attributes(
            :subject => it.title,
            :content => it.description,
            :synch_date => date
          ) if old_item.older_than(it)
        end
      end
      #self.syndicate_logs.create(:succeed=>true)
      return rss      
    rescue Exception => e
      #self.syndicate_logs.create(:succeed=>false, :message => e.message )
      raise e
    end
  end
  
  def before_create
    self.score = 0
  end
  
  private 
  def get_rss
    content = ""
    open(self.rss) do |s|
      content = s.read
    end
    RSS::Parser::parse(content, false)
  end

  def update_channel(rss)
    ch = rss.channel
    self.title = ch.title
    self.description = ch.description
    self.link = ch.link
    if ch.image
      self.icon_url = ch.image.url
      self.icon_title = ch.image.title
      self.icon_link = ch.image.link
    end
  end
  
  def format_time_for_xml(time)
    time.nil? ? '' : time.strftime('%Y%m%d %H:%M:%S')    
  end
end

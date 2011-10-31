require 'net/http'
require 'uri'
require 'rexml/document'

categories_map= { 0 => 1,
                  1 => 2,
                  2 => 4,
                  3 => 3 }
response = Net::HTTP.get 'tickets.gatacare.com', '/events.xml'
doc = REXML::Document.new response
root = doc.root
doc.elements.each 'events/event' do |event|
  hot_spot_id = event.attributes['theater_hot_spot_id']
  unless hot_spot_id.nil? or hot_spot_id.empty?
    puts event.attributes
      global_id = event.attributes['global_id']
      puts "global_id = '#{global_id}'"
      begin
        event_in_sys = Event.find_by_global_id global_id
        if event_in_sys
          unless event_in_sys.updated_at > event_in_sys.created_at
            event_in_sys.update_attributes :summary_zh_cn=>event.attributes['name'],
                                    :summary_en => '',
                                   :content_zh_cn=>event.text,
                                   :begin_date=>event.attributes['start_date'],
                                   :end_date=>event.attributes['end_date'],
                                   :reference_url=>event.attributes['reference_url'],
                                   :event_category_id => categories_map[event.attributes['channel']]
            puts "Event modified."
          end
        else
          hot_spot = HotSpot.find hot_spot_id
          start_date = Date.parse event.attributes['start_date']
          end_date = Date.parse event.attributes['end_date'] if event.attributes['end_date']
          end_date = start_date if end_date.nil? or end_date < start_date
          hot_spot.events.create! :summary_zh_cn=>event.attributes['name'],
                                  :summary_en => '',
                                 :content_zh_cn=>event.text,
                                 :begin_date=>start_date,
                                 :end_date=>end_date,
                                 :reference_url=>event.attributes['reference_url'],
                                 :global_id=>global_id,
                                 :event_category_id => categories_map[event.attributes['channel']]
          puts "event has been created."
        end
      rescue ActiveRecord::RecordNotFound
        puts "hot_spot #{hot_spot_id} has not been found."
      end
    
  end
#  begin
#    hot_spot = HotSpot.find 
#  rescue ActiveRecord::RecordNotFound
    
#  end
  
end
#puts res.body
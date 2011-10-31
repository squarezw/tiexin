require 'csv'

containers = {}
categories = {}

admin = Member.find 1

CSV.open ARGV[0], 'r' do |row|
  container_id, category_name, brand_name = row[0].to_i, row[8], row[9]
  if containers.has_key? container_id
    container = containers[container_id]
  else
    container = HotSpot.find container_id
    containers[container_id] = container
  end

  hot_spot = container.hot_spots.create :name_zh_cn => row[1],
                                       :name_en => row[2],
                                       :address_zh_cn => row[3],
                                       :address_en => row[4],
                                       :phone_number => row[5],
                                       :operation_time_zh_cn => row[6],
                                       :introduction_zh_cn => row[7],
                                       :home_page=> row[18],
                                       :x=>container.x,
                                       :y=>container.y

  hot_spot.city = container.city
  hot_spot.creator = admin
  
  unless category_name.blank?
    unless categories.has_key?(category_name)
      categories[category_name] = HotSpotCategory.find_by_name_zh_cn(category_name)
    end
    hot_spot.hot_spot_category = categories[category_name]
  else
  end
  
  unless brand_name.blank?
    hot_spot.brand = Brand.find_by_name_zh_cn(brand_name)
  end
  
  if hot_spot.save
    [10, 12, 14, 16].each do |idx|
      if row.length > idx
        tag, tag_description = row[idx], row[idx+1]
        unless tag.blank?
          hot_spot.hot_spot_tags.create! :tag=>tag, :description=>tag_description, :member_id=>1
        end
      end
    end
  else
    puts "Error when create hot spot #{hot_spot.name[:zh_cn]}"
    puts "Detail:" + hot_spot.errors.full_messages.join("\n")
  end
  
end

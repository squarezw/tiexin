module Admin::HotelRoomsHelper
  def safe_hotel_room_icon(hotel_room)
    hotel_room.pic ? image_tag(hotel_room.pic.url) : image_tag('nopic.jpg')
  end
end

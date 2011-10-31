class HotelRoomsController < ApplicationController
  def index
    @hotel = Hotel.find(params[:hotel_id])
    @hotel_rooms = @hotel.hotel_rooms
    respond_to do |format|
      format.xml {
          render :layout=>false
      }    
    end    
  end
  
  def show
    @hotel_room = HotelRoom.find(params[:id])
    respond_to do |format|
      format.xml {
          render :layout=>false
      }    
    end
  end

end

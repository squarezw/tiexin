class Admin::HotelRoomsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  before_filter :find_hotel
  layout 'admin'
  
  def index
    @hotel_rooms = @hotel.hotel_rooms if @hotel
  end
  
  def new
    @hotel_room = HotelRoom.new    
  end
  
  def create
    @hotel_room = HotelRoom.new(params[:hotel_room])
    @hotel_room.hotel = @hotel
    
    if @hotel_room.save
        flash[:notice] = _('Hotel room was successfully created.')
        redirect_to admin_hotel_hotel_rooms_path(@hotel)
    else
        render :action => 'new'
    end
  end
  
  def edit
    @hotel_room = HotelRoom.find(params[:id])
    @breakfast = @hotel_room.breakfast.to_s
    @network = @hotel_room.network.to_s
  end
  
  def update
    @hotel_room = HotelRoom.find(params[:id])
    if @hotel_room.update_attributes(params[:hotel_room])
        flash[:notice] = _('Hotel room was successfully updated.')
        redirect_to admin_hotel_hotel_rooms_path(@hotel)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @hotel_room = HotelRoom.find(params[:id])
    @hotel_room.destroy
    redirect_to admin_hotel_hotel_rooms_path(@hotel)
  end
  
  private
  def find_hotel
    @hotel = Hotel.find(params[:hotel_id])
  end

end

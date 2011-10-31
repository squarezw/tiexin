class HotelReservationsController < ApplicationController
  def index
    if params[:member_id]
      member = Member.find(params[:member_id])
      @hotel_rs = member.hotel_reservations
    end
    respond_to do |format|
        format.xml
    end
  end
  
  def create
    hotel = Hotel.find(params[:hotel_id])
    hotel_room_id = params[:hotel_room_id]
    number = params[:hotel_reservations][:number]
    params[:hotel_reservations].delete(:number)
    params[:hotel_reservations].delete_if {|k,v| v.is_a? Hash}
    @hotel_r = HotelReservation.new(params[:hotel_reservations])
    @hotel_r.hotel = hotel

    member = Member.find(params[:member_id]) if params[:member_id]
    @hotel_r.member = member if member

    unless @hotel_r.save
      @errors = @hotel_r.errors
    else
      if hotel_room_id.is_a? Hash
        hotel_room_id.each_pair do |key,value|
          if number.is_a? Hash
            n = number[key]
          end
            hotel_reservation_detail_before_save(value,n)
            unless @hotel_reservation_detail.save
              @errors = @hotel_reservation_detail.errors
            end
        end
      else
        hotel_reservation_detail_before_save(hotel_room_id,number)
        unless @hotel_reservation_detail.save
           @errors = @hotel_reservation_detail.errors
        end
      end
    end
    
    respond_to do |format|
        format.xml {
          if @errors
            render :template=>'/active_record_error', :layout=>false
          end
        }
    end
  end
  
  def show
    @hotel_r = HotelReservation.find(params[:id])
    respond_to do |format|
        format.xml
    end
  end
  
  def destroy
    @hotel_r = HotelReservation.find(params[:id])    
    respond_to do |format|
        format.xml {
          if @hotel_r.destroy
             render :layout=>false
          else
             @error = @hotel_r.errors.full_messages.join("\n")
             render :template => "error.rxml", :layout=>false
          end
        }
    end    
  end
  
  private
  def hotel_reservation_detail_before_save(id, n = "")
        hotel_room = HotelRoom.find(id)
        @hotel_reservation_detail = HotelReservationDetail.new
        @hotel_reservation_detail.number = n
        @hotel_reservation_detail.hotel_reservation = @hotel_r
        @hotel_reservation_detail.hotel_room = hotel_room
        if @hotel_r.member
          price = hotel_room.discount_price
        else
          price = hotel_room.price
        end
        @hotel_reservation_detail.price = price
  end
 
end

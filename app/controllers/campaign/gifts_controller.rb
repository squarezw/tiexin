class Campaign::GiftsController < ApplicationController
  layout 'default', :except=>:photos
  
  def index
    @gifts = Gift.find :all, :conditions=>['on_sale = ?', true], :order=>'created_at'
  end
  
  def available_point
    render :template=>'/campaign/gifts/_available_point', :layout=>false
  end
  
  def show
    @gift = Gift.find params[:id]
  end
  
  def photos
    @photos = NaviPhoto.paginate :conditions=>['owner_type = ? and owner_id = ?', Gift.to_s, params[:id]],
                                 :order=>'created_at',
                                 :page=>params[:page],
                                 :per_page=>5
  end
end

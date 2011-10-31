class Admin::GiftsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  layout 'admin'
  
  helper '/campaign/gifts'
  
  def index
    @gifts = Gift.find :all
  end
  
  def show
    @gift = Gift.find params[:id]
  end
  
  def new
    @gift = Gift.new
  end
  
  def create
    @gift = Gift.new params[:gift]
    if @gift.save
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  def edit
    @gift = Gift.find params[:id]
  end

  def update
    @gift = Gift.find params[:id]
    if @gift.update_attributes params[:gift]
      redirect_to admin_gift_path(@gift)
    else
      render :action => "edit"
    end
  end

end

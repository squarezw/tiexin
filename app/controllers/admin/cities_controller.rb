class Admin::CitiesController < ApplicationController
  before_filter :is_admin
  layout 'admin'
  
  def index
    @cities = City.find(:all, :order => "name_#{@current_lang}" )
  end
  
  def new
    @city = City.new
  end
  
  def create
    @city = City.new(params[:city])
    if @city.save
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  def edit
    @city = City.find(params[:id])
  end
  
  def update
    @city = City.find params[:id]
    if @city.update_attributes(params[:city])
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end
end

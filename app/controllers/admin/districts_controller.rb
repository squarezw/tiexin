class Admin::DistrictsController < ApplicationController
  before_filter :is_admin
  before_filter :init_cities, :except => [:index]
  layout 'admin'
  
  def index
    @districts = District.find(:all, :order => "city_id,name_#{@current_lang}" )
  end
  
  def new
    @district = District.new
  end
  
  def create
    @district = District.new(params[:district])
    if @district.save
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  def edit
    @district = District.find(params[:id])
  end
  
  def update
    @district = District.find params[:id]
    if @district.update_attributes(params[:district])
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end
  
  private
  def init_cities
    @cities = City.find(:all, :select=>"id,name_#{@current_lang}").collect{|p| [localized_description(p, :name),p.id]}
  end

end

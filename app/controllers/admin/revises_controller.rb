class Admin::RevisesController < ApplicationController
  
  before_filter :authenticated
  before_filter :is_admin

  layout "admin"

  def index
    @revises = Revise.paginate :conditions => ['hot_spots.city_id = ? and status = ?',@current_city.id,Revise::STATUS_PENDING],:include => :hot_spot,:per_page=>20, :page=>params[:page]
  end
end
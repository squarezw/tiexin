class Admin::PartnersController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  
  layout 'admin'
  
  def index
    @partners = Partner.find :all
  end
  
  def new
    @partner = Partner.new
  end
  
  def show
    @partner = Partner.find params[:id]
  end
  
  def create
    @partner = Partner.new params[:partner]
    if @partner.save
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  def edit
    @partner = Partner.find params[:id]
  end
  
  def update
    @partner = Partner.find params[:id]
    if params[:partner].has_key?(:password) and params[:partner][:password].empty? and params[:partner].has_key?(:password_confirmation) and params[:partner][:password_confirmation].empty?
      params[:partner].delete :password
      params[:partner].delete :password_confirmation
    end
    
    if @partner.update_attributes params[:partner]
      redirect_to :action => "show"
    else
      render :action => "edit"
    end
  end
end

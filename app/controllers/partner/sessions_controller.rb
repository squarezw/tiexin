class Partner::SessionsController < ApplicationController
  layout 'partner'
  
  before_filter :is_from_person, :only=>['create']
  
  def create
    @partner = Partner.login params[:code], params[:password]
    if @partner
      session[:partner_id] = @partner.id
      redirect_to partner_gift_orders_path
    else
      flash.now[:note]=_('Partner login failed. Incorrect code or password.') 
      render :action => "new"
    end
  end
  
  def destroy
    session[:partner_id] = nil
    redirect_to :action => "new" 
  end
end

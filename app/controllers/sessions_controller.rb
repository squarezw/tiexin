require 'captcha'

class SessionsController < ApplicationController      
  REMBER_ME_EXPIRE_TIMES=[15,30,90,180]
  layout 'default', :except=>[:index]                          
  
  before_filter :is_from_person, :only=>['create']
  before_filter :generate_captcha, :only=>['new']
  
  def new
    @forward_to = params[:forward_to] || request.env['HTTP_REFERER']
    respond_to do |format|
      format.html
      format.xhtmlmp {render :layout=>'wap'}
    end
  end

  def create     
    @forward_to = params[:forward_to]
    @current_user = Member.login(params[:login_name], params[:password])
    if @current_user.nil? 
      flash.now[:note]=_('Login failed. Incorrect nick name or password.') 
#      generate_captcha
      if request.xhr?
        render :template=>'/alert.js.rjs', :layout=>false
      else
        respond_to do |format|
          format.html { render :action=>:new }
          format.xhtmlmp { render :action=>:new, :layout=>'wap'}
        end
      end
    elsif @current_user.locked?
      session[:captcha] = nil
      if request.xhr?
        flash.now[:note]=_('Your account has been locked. You can not login now')
        render :template=>'/alert.js.rjs', :layout=>false
      else
        flash[:note]=_('Your account has been locked. You can not login now')
        redirect_to city_path(@current_city)
      end
    else                                
      remember_user(@current_user, REMBER_ME_EXPIRE_TIMES[params[:expire_time].to_i]) if '1' == params[:remember_me]
      logged_in(@current_user)
      session[:captcha]=nil
      unless request.xhr?
        if params[:forward_to]
          redirect_to params[:forward_to]
        else
          redirect_to city_path(@current_city)          
        end
      end
    end
  end       
  
  def destroy   
    if cookies[:user_id]
      cookies.delete :user_id       
#      Session.logout cookies[:user_id], session.session_id
    end      
    session[:member_id] = nil
    cookies.delete :remember_me         
    redirect_to city_path(@current_city)
  end 
                   
  private 
  def remember_user(user, expire_time=15)
    cookies[:remember_me]={ :value=>"#{user.id}:#{user.digest}",
                            :expires=>expire_time.days.from_now }
  end 
  
end

class Admin::FriendLinksController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  before_filter :find_channel, :except=>[:index]

  layout 'default'

  def index
    @friend_links = FriendLink.paginate :order=>'created_at desc',:page => params[:page]
  end
  
  def new
    @friend_link = FriendLink.new
  end

  def create
    @friend_link = FriendLink.new params[:friend_link]
    unless @friend_link.save
      render :action => "new"
    else
      redirect_to :action => "index"
    end
  end

  def edit
    @friend_link = FriendLink.find params[:id]
    @v_type = @friend_link.vendor_type
  end

  def update
    params[:friend_link][:vendor_type] = nil if params[:friend_link][:vendor_type].nil?
    @friend_link = FriendLink.find params[:id]
    if @friend_link.update_attributes params[:friend_link]
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end

  def destroy
    @friend_link = FriendLink.find params[:id]
    @friend_link.destroy
    redirect_to :action => "index"
  end

  protected
  def find_channel
    @channels = Channel.find(:all,:select=>"id,name_#{@current_lang}").collect{|p| [localized_description(p, :name),p.id]}
  end
end

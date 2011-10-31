require 'privilege'

class ChannelDailyContentsController < ApplicationController
  include XNavi::Privilege
  before_filter :authenticated, :except=>[:show, :index]
  before_filter :find_channel
  layout 'default'
  
  require_privilege :new, :edit_daily_content
  require_privilege :create, :edit_daily_content
  require_privilege :edit, :edit_daily_content
  require_privilege :update, :edit_daily_content
  require_privilege :destroy, :edit_daily_content
  
  def index
    if @current_user and @current_user.has_privilege(:edit_daily_content)
      conditions= ['channel_id = ?', @channel.id]
    else
      conditions = ['channel_id = ? and display_at <= ?', @channel.id, Date.today]
    end
    @channel_daily_contents = ChannelDailyContent.paginate :conditions=>conditions, :order=>'display_at desc', :page=>params[:page]
  end
    
  def show
    @daily_content = @channel.channel_daily_contents.find params[:id]
  end
  
  def new
    @channel_daily_content = ChannelDailyContent.new
    @channel_daily_content.display_at = Date.today
  end
  
  def edit
    @channel_daily_content = @channel.channel_daily_contents.find params[:id]
  end
  
  def create
    @channel_daily_content = @channel.channel_daily_contents.build params[:channel_daily_content]
    if @channel_daily_content.save
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  def update
    @channel_daily_content = @channel.channel_daily_contents.find params[:id]
    if @channel_daily_content.update_attributes params[:channel_daily_content]
      redirect_to :action => "show"
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @channel_daily_content = @channel.channel_daily_contents.find params[:id]
    @channel_daily_content.destroy
    redirect_to :action => "index"
  end
  private
  def find_channel
    @channel = Channel.find params[:channel_id]
    @selected_menu = @channel
  end
end

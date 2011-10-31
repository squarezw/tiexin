class Admin::ChannelsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  before_filter :find_forums, :only=>[:new, :edit]
  
  layout 'admin'
  
  def index
    @channels = Channel.find :all
  end
  
  def new
    @channel = Channel.new
  end
  
  def create
    @channel = Channel.new params[:channel]
    if @channel.save
      redirect_to :action => "index"
    else
      find_forums
      render :action => "new"
    end
  end
  
  def edit
    @channel = Channel.find params[:id]
  end
  
  def update
    @channel = Channel.find params[:id]
    if @channel.update_attributes params[:channel]
      redirect_to :action => "index"
    else
      find_forums
      render :action => "edit"
    end
  end
  
  def destroy
    @channel = Channel.find params[:id]
    @channel.destroy
    redirect_to :action => "index"
  end
  
  private
  def find_forums
    @forums = Forum.find :all
  end
end

class Admin::BulletinsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  layout 'default'
  
  def index
    @bulletins = Bulletin.paginate :order=>'created_at desc',:page => params[:page]
  end
  
  def new
    @bulletin = Bulletin.new
    @bulletin.language = 'zh_cn'
  end
  
  def create
    @bulletin = Bulletin.new params[:bulletin]
    unless @bulletin.save
      render :action => "new"
    else
      redirect_to :action => "index"
    end
  end
  
  def edit
    @bulletin = Bulletin.find params[:id]
  end
  
  def update
    @bulletin = Bulletin.find params[:id]
    if @bulletin.update_attributes params[:bulletin]
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @bulletin = Bulletin.find params[:id]
    @bulletin.destroy
    redirect_to :action => "index"
  end
  
  def publish
    bulletin = Bulletin.find params[:id]
    topic = SubscriptionTopic.find_or_create_by_name :bulletin
    topic.subscription_messages.create! :content_object=>bulletin, :sent=>false
    flash[:note] = _('Email will be sent to all members to inform this bulletin.')
    redirect_to :action => "index"
  end
end

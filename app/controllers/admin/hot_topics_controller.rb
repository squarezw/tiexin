class Admin::HotTopicsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  layout 'default'

  def index
    @hot_topics = HotTopic.paginate :order=>'created_at desc',:page => params[:page]
  end

  def new
    @hot_topic = HotTopic.new
  end

  def create
    @hot_topic = HotTopic.new(params[:hot_topic])
    if @hot_topic.save
      redirect_to :action => :index
    else
      render :action => :new
    end
  end

  def edit
    @hot_topic = HotTopic.find(params[:id])
  end

  def update
    @hot_topic = HotTopic.find(params[:id])
    if @hot_topic.update_attributes(params[:hot_topic])
        redirect_to :action => :index
    else
      render :action => 'edit'
    end
  end

  def destroy
    @hot_topic = HotTopic.find(params[:id])
    @hot_topic.destroy
    redirect_to :action => :index
  end

end

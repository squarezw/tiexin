require 'scores'

class RevisesController < ApplicationController
  include XNavi::Score
  
  before_filter :authenticated, :except=>[:index, :show]
  before_filter :is_admin, :only=>[:check, :show]
  before_filter :find_hot_spot
  
  helper :hot_spots
  helper :comments
  helper :photos
  helper :products
  helper :layout_maps
  
  def index
    @revises = Revise.paginate_by_hot_spot_id_and_status @hot_spot.id, Revise::STATUS_PENDING,
                               :order => 'created_at', :page=>params[:page], :per_page=>10
    new
  end
  
  def show
    @revise = @hot_spot.revises.find(params[:id])
    render :layout => 'simple' 
  end
  
  def new
    @revise = @hot_spot.revises.build
  end
  
  def create
    @revise = @hot_spot.revises.build(params[:revise])
    logger.info "@hot_spot = #{@hot_spot}"
    @revise.status = Revise::STATUS_PENDING
    @revise.member = @current_user      
    logger.info "@revise.hot_spot = #{@revise.hot_spot}"                                                     
    if @revise.save
        score :submit_revise_advice
        @last_page = (@hot_spot.pending_revises_count - 1) / 10 + 1
    else
      render :update do |page|
        page.replace_html 'form_error', @revise.errors.full_messages.join("\n")
      end
    end
  end
  
  def check
    @revise = @hot_spot.revises.find(params[:id])
    if (@revise.status == Revise::STATUS_PENDING)
      @revise.update_attributes(params[:revise].merge({:administrator=>@current_user}))
      score(:revise_advice_accepted, @revise.member) if @revise.status == Revise::STATUS_ACCEPTED
    end
    render :action=>:show, :layout=>'simple'
  end
  
  private
  def find_hot_spot
    @hot_spot = HotSpot.find(params[:hot_spot_id])
  end
end

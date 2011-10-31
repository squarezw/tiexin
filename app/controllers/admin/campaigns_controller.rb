class Admin::CampaignsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  layout 'admin'
  
  def index
    @campaigns = Campaign.find :all, :order=>'expire_date desc'
  end
  
  def show
    @campaign = Campaign.find params[:id]
  end
  
  def new
    @campaign = Campaign.new
    @campaign.bonus_experience = 0
    @campaign.bonus_credit = 0
  end
  
  def create
    @campaign = Campaign.new params[:campaign]
    if @campaign.save
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end
  
  def edit
    @campaign = Campaign.find params[:id]
  end
  
  def update
    @campaign = Campaign.find params[:id]
    if @campaign.update_attributes params[:campaign]
      redirect_to admin_campaign_path(@campaign)
    else
      render :action => "edit"
    end
  end
end

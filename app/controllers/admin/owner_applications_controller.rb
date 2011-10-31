class Admin::OwnerApplicationsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin, :except=>:create
  layout 'admin', :except=>[:create, :assign]
  
  def index
    @applications = OwnerApplication.paginate :conditions=> ['status = ?', OwnerApplication::STATUS_PENDING],
                                    :order => 'created_at', :page=> params[:page], :per_page => 25
  end
  
  def show
    @application = OwnerApplication.find params[:id]
  end
  
  def create
    @target = find_target
    unless @target.owner or @current_user.has_pending_owner_applications(@target)
      @current_user.owner_applications.create :target => @target, :member => @current_user  
    end
  end
  
  def update
    @application = OwnerApplication.find params[:id]
    unless @application.pending?
      flash[:note] = _('This application has already been reviewed.')
      redirect_to :action => "index"
      return
    end
    
    status = params[:status].to_i
    status = OwnerApplication::STATUS_DISAPPROVED unless [OwnerApplication::STATUS_APPROVED, OwnerApplication::STATUS_DISAPPROVED].include?(status)
    OwnerApplication.transaction do 
      if @application.update_attributes :status => status, :opinion=>params[:application][:status], :admin=>@current_user
        if status == OwnerApplication::STATUS_APPROVED
          @application.target.update_attribute_with_validation_skipping :owner_id, @application.member_id 
          @application.member.make_merchant!
          if @application.target_type == "HotSpot"
              renew_score(@application.target_id,@application.member_id)
              recommend(@application.target_id)
          end
          @application.member.receive_message Member.find(1), 
                                              'Application to be owner has been approved.',
                                              'Your application to be owner of %{name} has been approved.',
                                              :name=>@application.target.name[@current_lang]
        end
        redirect_to :action => "index"
      else
        render :show
      end
    end
  end
  
  N_('Application to be owner has been approved.')
  N_('Your application to be owner of %{hot_spot} has been approved.')
  
  def assign
    if params[:member].nil? or params[:member][:nick_name].nil?
      alert _('Please input nick name of the owner.')
      return
    end
    nick_name = params[:member][:nick_name]
    @target = find_target
    if nick_name.empty?
      @error_message = _('Please input nick name of the owner.')
      render :action=>'assign_error'
    else
      member = Member.find_by_nick_name nick_name
      @target.owner = member
      @target.save_with_validation false
    end
  end
  
  private 
  def find_target
    target_class = params[:target_type].camelize.split("::").inject(Object) { |par, const| par.const_get(const) }
    target_class.send(:find, params[:target_id])
  end

  def renew_score(hot_spot_id,member_id)
    HotSpotScore.ownership_score_sweep!(hot_spot_id,member_id)
    quality_score = HotSpotScore.avg("quality",hot_spot_id) || 0
    service_score = HotSpotScore.avg("service",hot_spot_id) || 0
    environment_score = HotSpotScore.avg("environment",hot_spot_id) || 0
    price_score = HotSpotScore.avg("price",hot_spot_id) || 0
    
    score = quality_score + service_score + environment_score + price_score
    
    HotSpot.update(hot_spot_id,:quality_score =>quality_score,:service_score => service_score, :environment_score => environment_score,:price_score => price_score,:score => score)
  end
  
  def recommend(hot_spot_id)
    hot_spot = HotSpot.find(hot_spot_id)
    hot_spot.recommended(1)
  end
  
end

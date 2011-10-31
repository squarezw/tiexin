require 'dynamic_query'
require 'scores'
require 'privilege'

class MembersController < ApplicationController   
  include Imon::DynamicQuery
  include XNavi::Score
  include XNavi::Privilege
  
  before_filter :authenticated, :only=>[:index, :grant_admin, :revoke_admin, :lock, :unlock, :add_as_friend, :capabilities]
  before_filter :is_admin, :only=>[:index, :grant_admin, :revoke_admin, :lock, :unlock, :owned_privileges, :modify_privileges]
  
  before_filter :find_current_city
  
  require_privilege :index, :manage_member
  require_privilege :lock, :manage_member
  require_privilege :unlock, :manage_member
  require_privilege :grant_admin, :manage_member
  require_privilege :revoke_admin, :manage_member
  require_privilege :grant_staff, :manage_member
  require_privilege :revoke_staff, :manage_member  
  require_privilege :modify_privileges, :manage_member
  
  layout 'default', :except=>:capabilities
  
  helper 'articles'
  helper 'hot_spots'
  helper 'brands'
  helper 'layout_maps'
  
  def index
    @members = Member.paginate :order=>'id desc', :per_page => 30, :page => params[:page]
  end         
  
  def show
    @member = Member.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @member.confirmed or @current_user.is_admin?
    respond_to do |format|
      format.html {
        #render :action=>'my_xnavi' if @current_user == @member
        if @member.blog and @current_user != @member
          redirect_to @member.blog.url
        elsif @member == @current_user
          render :action=>'my_xnavi'
        end 
      }
      format.rss {  
        @articles = @member.articles.latest_articles
        render :template=>'/members/feed', :layout=>false
      }
    end
  end
  
  def capabilities
    @capabilities = @current_user.capabilities
	respond_to do |format|
		format.xml {render :layout=>false}
	end
  end
  
  def detail
    logger.info "@current_user.id = #{@current_user.id}"
    unless @current_user and (params[:id] == @current_user.id.to_s or @current_user.is_admin )
      redirect_to :action=>:show
    else
      if @current_user.is_admin
        @member = Member.find params[:id]
      else
        @member = @current_user
      end
    end
  end
   
  def new
    @member = Member.new
    @campaigns = Campaign.active_campaigns_for Campaign::TRIGGER_REGISTER
    if params[:invitation_id]
      begin
        @member.invitation = Invitation.find params[:invitation_id]
        @member.mail = @member.invitation.mail
      rescue ActiveRecord::RecordNotFound
      end
    elsif params[:inviter_id]
      begin
        @member.inviter = Member.find params[:inviter_id]
      rescue ActiveRecord::RecordNotFound
      end
    end
  end                      
  
  def create
    @member = Member.new(params[:member])    
    unless params[:accept_user_term] == '1' or @mobile_user
      flash.now[:note] = _('You must read and accept user terms before register.')
      render :action => "new"
      return
    end
    @member.favorite_lang = @current_lang.to_s
    if @mobile_user
      @member.mobile_register = (@mobile_user == true)
      @member.confirmed = true
    end
    if @member.save
      apply_register_campaign(@member) if @mobile_user
      respond_to do |format|
        format.html {
          flash[:note]=_('after registration prompt')          
          MemberMailer.deliver_confirm_registration(@member)
          invitation_accepted(params[:invitation_id]) if params[:invitation_id]
          redirect_to '/'
        }
        format.xml { render :layout=>false }
      end
    else
      respond_to do |format|
        format.html {
          render :action => "new"
        }
        format.xml {
          @errors = @member.errors
          render :template=>'/active_record_error', :layout=>false
        }         
      end
    end
  end       
  
  def edit
    @member = Member.find params[:id]
    unless @member.modifiable_to?(@current_user)
      flash.now[:note]=_('You have no privilege to do this operation.')
      render :action => "show"
    end
  end
  
  def update
    @member = Member.find(params[:id])
    unless @member.modifiable_to?(@current_user)
      flash.now[:note]=_('You have no privilege to do this operation.')
      render :action => "show"
      return
    end

    if params[:member].has_key?(:password) and params[:member][:password].empty? and params[:member].has_key?(:password_confirmation) and params[:member][:password_confirmation].empty?
      params[:member].delete :password
      params[:member].delete :password_confirmation
    end
    
    if params[:member].has_key?(:mail) and params[:member][:mail] != @member.mail
      @member.mail_confirm = params[:member][:mail]
      @member.generate_mail_confirm_code
      params[:member].delete :mail
      MemberMailer.deliver_confirm_mail_edit(@member)
    end

    old_logo = @member.logo.dup if @member.logo
    if @member.update_attributes(params[:member])      
      render :action => "detail"
    else
      @member.logo = old_logo unless @member.errors[:logo].nil?
      render :action => "edit"
    end
  end
  
  def confirm_registration
    @member=Member.find(params[:id])
  	if @member.confirmed
  		redirect_to '/'
  		return
  	end

    if @member.confirm_code == params[:confirm_code] || (current_is_admin? and @current_user.has_privilege :manage_member)
      @campaigns = []
      Member.transaction do 
        @member.confirmed!
        @member.save
        @campaigns = apply_register_campaign(@member)
        if @member.invitation or @member.inviter
          invitation_accepted @member
        end
      end
      if @campaigns.empty?
        flash[:note]=_('Your registration has been confirmed. You can login to the system now.')
        redirect_to new_session_url
      end
    else                             
      flash[:note]=_('The confirmation code is incorrect.')
      redirect_to city_path(@current_city)
    end
  end

  def confirm_mail_edit
    @member=Member.find(params[:id])
    if @member.mail_confirm_code == params[:mail_confirm_code]
        @member.confirmed_mail!
        if @member.save
          flash[:note]=_('Your mail has been confirmed. You can login to checking.')
        else
          flash[:note]=_('Your mail has been registered.')
        end
        redirect_to new_session_url
    else                             
      flash[:note]=_('The mail confirmation code is incorrect.')
      redirect_to city_path(@current_city)
    end    
  end
  
  def grant_admin
    @member = Member.find(params[:id])
    @member.update_attribute_with_validation_skipping(:is_admin, true)
    redirect_to :action => :detail
  end     
  
  def revoke_admin
    @member = Member.find(params[:id])
    @member.update_attribute_with_validation_skipping(:is_admin, false)
    redirect_to :action => :detail
    
  end

  def grant_staff
    @member = Member.find(params[:id])
    @member.update_attribute_with_validation_skipping(:is_staff, true)
    redirect_to :action => :detail
  end     
  
  def revoke_staff
    @member = Member.find(params[:id])
    @member.update_attribute_with_validation_skipping(:is_staff, false)
    redirect_to :action => :detail
    
  end
  
  def lock
    @member = Member.find params[:id]
    @member.lock!(params[:time].to_i)
    render :action => "detail"
  end
  
  def unlock
    @member = Member.find params[:id]
    @member.unlock!
    render :action => "detail"
  end
  
  def check_password
    unless @mobile_user
      redirect_to '/' 
      return
    end
    @member = Member.find_by_login_name params[:login_name]
    respond_to do |format|
      format.xml {
        if @member and @member.is_password_correct?(params[:password]) and @member.confirmed
          render :layout=>false
        else
          error_xml 209
        end
      }
    end
  end
  
  def check_login_name
    logger.info "#{params[:login_name]}"
    cnt = Member.count(:conditions => ['login_name = ?', params[:login_name]])
    if cnt > 0
      render :text=>_('This user name has been used.'), :layout => false 
    else
      render :text=>_('This user name has not been used.'), :layout => false
    end
  end
  
  def check_nick_name
    cnt = Member.count(:conditions => ['nick_name = ? and id <> ?', params[:nick_name], params[:id]])
    if cnt > 0
      render :text=> _('This nick name has been used.'), :layout => false 
    else
      render :text=> _('This nick name has not been used.'), :layout => false
    end
  end

  def search
    exps = []
    exps << self.or (like(:login_name, params[:keyword]), like(:nick_name, params[:keyword])) if params.has_key?(:keyword) 
    if params[:is_admin] and !(params[:is_admin].empty?)
      exps << equal (:is_admin, (params[:is_admin] =~ /(yes)|(true)/i) ? 1 : 0 )        
    end
    if params[:is_staff] and !(params[:is_staff].empty?)
      exps << equal (:is_staff, (params[:is_staff] =~ /(yes)|(true)/i) ? 1 : 0 )        
    end
    
    if params[:is_locked] and !(params[:is_locked].empty?)
      if params[:is_locked] =~ /(yes)|(true)/i
        logger.info "self.is_not_null: #{self.is_not_null(:locked_until)}"
        logger.info "self.greater: #{self.greater(:locked_until, Time.now)}"
        exps << self.and(self.not(self.is_null(:locked_until)),
                         self.greater(:locked_until, Time.now))
      else
        exps << self.or(self.is_null(:locked_until), 
                         self.less_or_equal(:locked_until, Time.now))
      end
    end
    conditions = self.and(exps).conditions
    @members = Member.paginate :conditions => conditions, :order=> 'login_name',
                               :per_page => 30, :page => params[:page]
    render :action => "index"
  end
  
  def reset_password
    @current_user = Member.find_by_login_name params[:login_name]
    if @current_user and @current_user.mail == params[:mail]
      @current_user.reset_password
      if @current_user.save
        MemberMailer.deliver_reset_password(@current_user, @current_user.password)
        flash[:note]= _('Password has been resetted, and an E-mail contains new password has been sent to your registered E-mail address.')
        redirect_to new_session_url
      else          
        flash.now[:note]= _(@current_user.errors.full_messages.join('\n'))                           
        render :action=>'forget_password'
      end
    else
      flash.now[:note]= _('Incorrect nick name or email address.')
      render :action=>'forget_password'
    end
  end
  
  def resend_confirmation_code
    @user = Member.find_by_login_name params[:login_name]
    if @user.nil?
      flash.now[:note] = _('Unknown login name.')
      render :action => "request_confirmation_code"
      return
    end
    
    if @user.confirmed
      flash[:note] = _('The registration of this user has already been confirmed.')
      redirect_to new_session_url
      return
    end
    
    unless params[:mail].nil? or params[:mail].empty?
      unless @user.mail == params[:mail] 
        m = Member.find_by_mail(params[:mail])
        if m.nil?
          @user.update_attributes :mail=>params[:mail]
        else
          flash.now[:note] = _('The email has already been used.')
          render :action => "request_confirmation_code"
          return
        end
      end
    end
    MemberMailer.deliver_confirm_registration(@user)
    flash[:note] = _('The email contains confirmation code has been sent to your registered email address.')
    redirect_to new_session_url
  end
  
  def to_invite
    @inviter = params[:inviter] || @current_user.login_name
    @receiver = params[:receiver] || ''
  end
  
  def invite
    @errors = []
    error_emails = []
    partial_sent = false
    if params[:receiver].nil? or params[:receiver].empty?
      @errors << _('You must input at least on email address')
    end
    if params[:inviter].nil? or params[:inviter].empty?
      @errors << _(%q/'inviter' is required./)
    end
    
    add_friends = params[:add_to_friends] == '1'
    if @errors.empty?
      (params[:receiver].split /\s*,\s*/ ).each do |receiver_email|
        if receiver_email =~ /(.*)@.*/
          if Member.find_by_mail(receiver_email).nil?
            receiver = $1
            invitation = Invitation.create! :member=>@current_user, :mail=>receiver_email, :add_friends=>add_friends
            MemberMailer.deliver_invite_friend receiver, invitation, params[:note], params[:inviter]
            partial_sent = true
          else
            @errors << _('%{email} has already been registered.') % { :email => receiver_email }
          end
        else
          error_emails << receiver_email
          @errors << _('%{email} is not a valid email address, ignore it.') % { :email=>receiver_email }
        end
      end
    end
    
    if @errors.empty?
      flash[:note] = _('The invitation email has been sent.')
      redirect_to city_url(@current_city)
    else
      logger.info "errors = #{@errors.join (',')}"
      @receiver = partial_sent ? error_emails.join(',') : params[:receiver]
      @inviter = params[:inviter] || @current_user.login_name
      render :action=>'to_invite'
    end
  end
  
  def add_as_friend
    @member = Member.find params[:id]
    unless @current_user == @member or
           @current_user.has_friend? @member or
           @current_user.has_pending_friend? @member
        friend = @current_user.add_friend @member
        if friend.pending
          @member.receive_message @current_user, 
                                'Request to add you as friend',
                                '"%{owner}" want to add you to his(her) friend list. You can accept or reject it. You can click [url=%{url}]here[/url] for detail information.',
                                { :owner=>@current_user.login_name, :url=>friend_path(friend)}
        end
    end
    render  :partial=>'/members/friend_infor_area', :locals=>{:member=>@member}
  end
  
  def open_option
    @member = Member.find params[:id]
    @member.open_option!(params[:open_option].to_i)
    render :action => "detail"
  end
  
  def owned_hot_spots
    @member = Member.find params[:id]
    if params[:city_id]
      @hot_spots = @member.owned_hot_spots.find :all, :conditions=>['city_id = ?', params[:city_id]]
    else
      @hot_spots = @member.owned_hot_spots
    end
    respond_to do |format|
      format.html 
      format.xml {render :layout=>false }
    end
  end
  
  def owned_brands
    @member = Member.find params[:id]
    @brands = Brand.paginate :conditions => ['owner_id = ?', @member.id],  :page => params[:page], :per_page => 9
  end
  
  def created_brands
    @member = Member.find params[:id]
    @brands = Brand.paginate :conditions => ['creator_id = ?', @member.id],  :page => params[:page], :per_page => 9
    render  :action => :owned_brands
  end
  
  def owned_privileges
    @member = Member.find(params[:id])
    @privileges = @member.member_privileges
    render :layout => false
  end
  
  def modify_privileges
    member = Member.find(params[:id])
    old_privileges = member.member_privileges.collect!{ |item| item.privilege }
    new_privileges = params[:privilege]? params[:privilege]:[]
    
    p_intersect_add, p_intersect_del = [],[]    
    
    p_intersect_add = new_privileges - old_privileges
    p_intersect_del = old_privileges - new_privileges
    
    for privilege in p_intersect_add
          member.member_privileges.create :member_id=>member.id, :privilege=>privilege
    end
    
    unless p_intersect_del.blank?
          MemberPrivilege.delete_all(["member_id = ? and privilege in (?)",member.id,p_intersect_del])
    end
    render :nothing => true
  end
  
  N_('Request to add you as friend')
  N_('"%{owner}" want to add you to his(her) friend list. You can accept or reject it. You can click [url=%{url}]here[/url] for detail information.')
  
  def auto_complete_for_member_login_name
    name = params[:member][:login_name]
    @members = Member.find :all, 
                           :conditions=>['login_name like ? and confirmed = ? ', "%#{name}%", true], 
                           :order=>'login_name', 
                           :limit=>10
    render :inline => "<%= auto_complete_result @members, 'login_name' %>"
  end
  
  def auto_complete_for_member_nick_name
    name = params[:member][:nick_name]
    @members = Member.find :all, 
                           :conditions=>['nick_name like ? and confirmed = ? ', "%#{name}%", true], 
                           :order=>'nick_name', 
                           :limit=>10
    render :inline => "<%= auto_complete_result @members, 'nick_name' %>"
  end

  private
  def invitation_accepted(new_member)
    if new_member.invitation
	invitation = new_member.invitation
      score :invite_member, invitation.member
      new_member.update_attribute_with_validation_skipping :inviter_id, invitation.member.id
      if invitation.add_friends
        invitation.member.add_friend new_member, false
        new_member.add_friend invitation.member, false
        invitation.member.receive_message new_member, _('Your friend registered'),
          _('Your friend "%{name}" have accepted your invitation and registered into XNavi. He(She) has been added to your friend list as your wish.'),
          {:name=>new_member.login_name}
        new_member.invitation = nil
        invitation.destroy
      end
    elsif new_member.inviter
      begin
        score :invite_member, new_member.inviter
      rescue ActiveRecord::RecordNotFound
      end
    end
  end
  
  def apply_register_campaign(member)
    campaigns = Campaign.active_campaigns_for Campaign::TRIGGER_REGISTER
    campaigns.each { |campaign|
      campaign.apply member
      member.reload
    }
    return campaigns
  end
end

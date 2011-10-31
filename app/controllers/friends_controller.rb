class FriendsController < ApplicationController
  before_filter :authenticated
  layout 'default', :except=>:destroy

  def index
    if @mobile_user
      parse_start_limit
      page = @start / @limit + 1
      per_page = @limit
      logger.info "start: #{@start}, limit:#{@limit}, page:#{page}, per_page: #{per_page}"
    else
      page = params[:page]
      per_page = 30
    end
    
    @friends = Friend.paginate_by_owner_id_and_pending @current_user.id, false,
                               :include=>:member,
                               :order=>'members.nick_name',
                               :per_page=>per_page, 
                               :page => page
    respond_to do |format|
      format.html
      format.xml { render :layout=>false }
    end
  end
  
  def show
    @friend = Friend.find params[:id]
    if @friend.member == @current_user
      if @friend.pending
        @member = @current_user
        render :action => "invitation"
      else
        flash[:note] = "This request has already been processed."
        redirect_to member_path(@current_user)
      end
    elsif @friend.owner = @current_user
      if @friend.pending
        logger.info ("friend is pending.")
        @member = @current_user
        render :action => "pending_invitation"
      else
        flash[:note] = "This request has already been processed."
        redirect_to member_path(@friend.member)
      end
    else
      render :nothing=>true, :status=>401
    end
  end
  
  def update
    @friend = Friend.find params[:id]
    unless @friend.member == @current_user
      flash[:note] = _('You have no privilege to do this operation.')
      redirect_to member_path(@current_user)
      return
    end
    
    unless @friend.pending
      flash[:note] = _('This request has already been agreed.')
      redirect_to member_path(@current_user)
      return
    end

    case params[:option]
    when 'agree'
      @friend.confirm!  
      @friend.owner.receive_message @current_user, _('Request to add friend has been agreed.'),
        _('Your request to add "%{name}" to your friend list has been agreed.'),
        {:name=>@current_user.nick_name}
    
    when 'agree_and_add'
      @friend.confirm!
      @current_user.add_friend @friend.owner, false
      @friend.owner.receive_message @current_user, _('Request to add friend has been agreed.'),
        _('Your request to add "%{name}" to your friend list has been agreed, and "%{name}" has added you to his(her) friend list.'),
        {:name=>@current_user.nick_name}      
        
     when 'reject'
       @friend.destroy
       @friend.owner.receive_message @current_user, _('Request to add friend has been rejected.'),
         _('Your request to add "%{name}" to your friend list has been rejected.'),
         {:name=>@current_user.nick_name}
      
      else
        flash[:note] = _("Invalid option.")
        @member = @current_user
        render :action => "invitation"
    end
    
    redirect_to member_path(@current_user)
  end
  
  def destroy
    @friend = Friend.find params[:id]
    if @friend.owner == @current_user
      @friend.destroy
      respond_to do |format|
        format.js
        format.xml
      end
    else
      respond_to do |format|
        format.js {
          render :update do |page|
            page.alert _('You have no privilege to do this operation.')
          end
        } 
        
        format.xml {
          error_xml 208
        }
      end
    end
  end
  
  def pending
    @member = @current_user
    @friends = @current_user.pending_be_friends
  end
  
  def quick_add
    @to_add = Member.find_by_nick_name params[:member][:nick_name]
    if @to_add.nil?
      @error_message = _('There are no such user has login name "%{name}"') % { :name=>params[:member][:nick_name] }
    elsif @current_user == @to_add
      @error_message = _('You can not add yourself to friend list.')
    elsif @current_user.has_friend? @to_add
      @error_message = _('You already has this friend.')
    elsif @current_user.has_pending_friend? @to_add
      @error_message = _('Your request to add him(her) to your friend list are waiting approve.')
    else
      @friend = @current_user.add_friend @to_add
      if @friend.pending
        @to_add.receive_message @current_user, 
                              'Request to add you as friend',
                              '"%{owner}" want to add you to his(her) friend list. You can accept or reject it. You can click [url=%{url}]here[/url] for detail information.',
                              { :owner=>@current_user.nick_name, :url=>friend_path(@friend)}
        alert _('Your request to add him(her) to your friend list are waiting approve.') unless @mobile_user
      end
    end
    logger.info @error_message
    respond_to do |format|
      format.js { alert @error_message unless @error_message.nil? or @error_message.empty? }
      format.xml {
        unless @error_message.nil? or @error_message.empty?
          error_xml 210
        else
          render :layout=>false          
        end
      }
    end
  end
end

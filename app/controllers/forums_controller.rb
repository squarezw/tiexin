class ForumsController < ApplicationController
  layout 'default'
  before_filter :is_moderator, :only => [:add_blacklist, :to_add_blacklist, :del_blacklist]
  
  auto_complete_for :member, :nick_name, :limit => 10

  def index
    @forums = Forum.find :all, :order=>'order_sequence'
    @selected_menu = :forums
  end
  
  def show
    redirect_to forum_posts_url(Forum.find(params[:id]))
  end
  
  def add_blacklist
    @forum = Forum.find(params[:id])
    render :layout => false
  end
  
  def to_add_blacklist
    if params[:id]
      @forum = Forum.find params[:id]
    end
    
    if params[:member] and params[:member][:nick_name]
        @member = Member.find_by_nick_name(params[:member][:nick_name])
         unless @member
           @error = _('Can not find nick name')
        end
    else
      @error = _('Please input nick name')
    end
    
    if @member and @forum
        unless  @forum.blacklist_to_members.include?(@member)
          @forum.blacklist_after_lock_post(@member)
          @forum.blacklist_to_members <<  @member

          OperationLog.create(:member=>@current_user, 
                             :related_object=>@forum, 
                             :operation=>'add_user_to_blacklist',
                             :message_key=>_('move user to blacklist'))
        end
    end
    
    if @error
      render :update do |page|
                  page.replace_html 'error_msgs', @error
                  page.show 'error_msgs'
                  page.call 'panel.show'
      end
    else
      render  :update do |page|
           page.replace_html "blacklist", :partial => "blacklist", :object =>@forum.blacklist_to_members
      end      
    end
  end

  def del_blacklist
    @member = Member.find(params[:member_id])
    @forum = Forum.find params[:id]
    if @forum and @forum.blacklist_to_members.delete @member
      render  :update do |page|
           page.replace_html "blacklist", :partial => "blacklist", :object =>@forum.blacklist_to_members
      end
    end
  end   
  
  private
  
  def is_moderator
     return true if @current_user and (@current_user.is_admin or @current_user.is_moderator?(@forum))
     flash[:note] = _('You have no privilege to do this operation.')
     redirect_to main_path
  end
end

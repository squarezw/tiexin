require 'privilege'

class Admin::ForumsController < ApplicationController
  include XNavi::Privilege
  
  before_filter :authenticated
  before_filter :is_admin
  
  require_privilege :index, :manage_forum
  require_privilege :new, :manage_forum  
  require_privilege :create, :manage_forum
  require_privilege :edit, :manage_forum
  require_privilege :update, :manage_forum  
  require_privilege :destroy, :manage_forum    
  
  layout 'admin'
  
  auto_complete_for :member, :nick_name, :limit => 10
  
  def index
    @forums = Forum.find :all, :order=>'order_sequence'
  end
  
  def new
    @forum = Forum.new
  end
  
  def create
    @forum = Forum.new params[:forum]
    @forum.order_sequence = Forum.count
    if @forum.save
      redirect_to :action => "index"
    else
      render :action=>:new  
    end    
  end
  
  def edit
    @forum = Forum.find params[:id]
  end
  
  def update
    @forum = Forum.find params[:id]
    if @forum.update_attributes params[:forum]
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end
  
  def destroy
    @forum = Forum.find params[:id]
    if @forum.can_delete?
      @forum.destroy
    else
      flash[:note] = _('You can not delete this %{obj_name} now.') % { :obj_name => _('forum') }
    end
    redirect_to :action => "index"
  end

  def moderator
    index
    render :action => 'moderator'
  end
  
  def add_moderator
    render :layout => false
  end
  
  def to_add_moderator
    if params[:id]
      @forum = Forum.find params[:id]
    end
    
    if params[:member] and params[:member][:nick_name]
        @member = Member.find_by_nick_name(params[:member][:nick_name])
         unless @member
           @error = _('Can not find login name')
        end
    else
      @error = _('Please input login name')
    end
    
    if @member and @forum
        unless  @forum.members.include?(@member)
          @forum.members <<  @member
        end
    end
    
    if @error
      render :update do |page|
                  page.replace_html 'error_msgs', @error
                  page.show 'error_msgs'
                  page.call 'panel.show'
      end
    end
  end
  
  def del_moderator
    @member = Member.find(params[:member_id])
    @forum = Forum.find params[:id]
    @forum.members.delete @member
    redirect_to :action => "moderator"
  end
  
end
require 'scores'

class Admin::PostsController < ApplicationController
  include XNavi::Score
  
  before_filter :authenticated
  before_filter :is_admin, :except=>[:put_to_top,:remove_from_top,:lock,:remove_lock, :move]
  before_filter :find_post, :except=>[:index]
  before_filter :is_moderator, :only => [:put_to_top,:remove_from_top,:lock,:remove_lock, :move]
  layout 'admin', :except=>:show_in_homepage
  helper 'posts'
  
  def index
    @posts= Post.paginate  :conditions => "deleted = false", :order => 'check_status,updated_at desc', :per_page => 30, :page => params[:page]
  end
  
  def show
  end
  
  def check
    check_status = params[:check_status].to_i    
    if Post::ALL_CHECK_STATUS.include? check_status
      Post.transaction do 
        old_status = @post.check_status
        @post.update_attribute_with_validation_skipping :check_status, check_status
        OperationLog.create (:member=>@current_user, 
                             :related_object=>@post, 
                             :operation=>'check_post',
                             :message_key=>'Change check status from "%{old_status}" to "%{new_status}"',
                             :message_parameters=>{:old_status=>"post_check_status|#{old_status}",
                                                   :new_status=>"post_check_status|#{check_status}"} )
      end
    end
    redirect_to :action => "show"
  end
  
  def destroy
    subtract_credit = params[:subtract_credit].to_i
    if subtract_credit > 0
      score :delete_post, @post.member, -subtract_credit
    end
    Post.transaction do 
      @post.deleted!
      OperationLog.create :member=>@current_user,
                          :related_object =>@post,
                          :operation=>'delete_post',
                          :message_key=>'Delete post %{post}',
                          :message_parameters=>{ :post=> @post.title },
                          :memo => params[:delete_reson]
    end
    flash.now[:note] = _('The post has been deleted.')
    render :template=>'/simple_message', :layout=>'simple'
  end
  
  def put_to_top
    old_status = @post.always_on_top
    @post.put_to_top!
    @post.save_with_validation false
    check_status = @post.always_on_top
    OperationLog.create(:member=>@current_user, 
                             :related_object=>@post, 
                             :operation=>'put_to_top',
                             :message_key=>'Change always_on_top from "%{old_status}" to "%{new_status}"',
                             :message_parameters=>{:old_status=>"always_on_top|#{old_status}",
                                                   :new_status=>"always_on_top|#{check_status}"} )    
    render :partial => "top_oper_area", :layout=>false
  end
  
  def remove_from_top
    old_status = @post.always_on_top
    @post.remove_from_top!
    @post.save_with_validation false
    check_status = @post.always_on_top
    OperationLog.create(:member=>@current_user, 
                             :related_object=>@post, 
                             :operation=>'remove_to_top',
                             :message_key=>'Change always_on_top from "%{old_status}" to "%{new_status}"',
                             :message_parameters=>{:old_status=>"always_on_top|#{old_status}",
                                                   :new_status=>"always_on_top|#{check_status}"} )        
    render :partial => "top_oper_area", :layout=>false    
  end
  
  def lock
    old_status = @post.lock
    @post.lock!
    @post.save_with_validation false
    check_status = @post.lock
    OperationLog.create(:member=>@current_user, 
                             :related_object=>@post, 
                             :operation=>'lock',
                             :message_key=>'Change lock from "%{old_status}" to "%{new_status}"',
                             :message_parameters=>{:old_status=>"lock|#{old_status}",
                                                   :new_status=>"lock|#{check_status}"} )        
    redirect_to forum_post_path(@post.forum, @post)
  end

  def remove_lock
    old_status = @post.lock
    @post.remove_lock!
    @post.save_with_validation false
    check_status = @post.lock
    OperationLog.create(:member=>@current_user, 
                             :related_object=>@post, 
                             :operation=>'lock',
                             :message_key=>'Change lock from "%{old_status}" to "%{new_status}"',
                             :message_parameters=>{:old_status=>"lock|#{old_status}",
                                                   :new_status=>"lock|#{check_status}"} )     
    redirect_to forum_post_path(@post.forum, @post)
  end  
  
  def show_in_homepage
    @post.flip_show_in_homepage!
  end
  
  def move
    old_forum = @post.forum_id
    if params[:forum_id]
        forum = Forum.find(params[:forum_id])
        if forum and @post.update_attribute_with_validation_skipping :forum_id, params[:forum_id].to_i
            OperationLog.create(:member=>@current_user, 
                             :related_object=>@post, 
                             :operation=>'move_post',
                             :message_key=>'Move post from "%{old_forum}" to "%{new_forum}"',
                             :message_parameters=>{:old_forum=>"#{old_forum}",
                                                   :new_forum=>"#{params[:forum_id].to_i}"} )             
            redirect_to forum_post_path(params[:forum_id].to_i, @post)
        else
            flash[:note] = _('Can not find forum')
            redirect_to forum_post_path(@post.forum, @post)
        end
    else
       redirect_to forum_post_path(@post.forum, @post)
    end   
  end
  
  private 
  def find_post
    @post = Post.find params[:id]    
  end
  
  def is_moderator
     return true if @current_user and (@current_user.is_admin or @current_user.is_moderator?(@post.forum))
     flash[:note] = _('You have no privilege to do this operation.')
     redirect_to main_path
  end
  
  N_('check_post')
  N_('Change check status from "%{old_status}" to "%{new_status}"')
  N_('Change lock from "%{old_status}" to "%{new_status}"')
  N_('Change always_on_top from "%{old_status}" to "%{new_status}"')
  N_('Move post from "%{old_forum}" to "%{new_forum}"')
end
